class Task < ApplicationRecord
  # Relaciones
  belongs_to :user
  belongs_to :case, optional: true  # Los procedimientos pueden no tener caso asociado

  # Validaciones básicas
  validates :title, presence: true

  # Enums
  enum priority: { routine: 0, urgent: 1, stat: 2 }
  enum status: { pending: 0, in_progress: 1, completed: 2, needs_attending_review: 3 }
  enum task_type: {
    interpretation: 0,
    reporting: 1,
    protocoling: 2,
    procedure: 3
  }

  # Callbacks
  before_save :set_default_values
  after_update :update_case_status, if: :saved_change_to_status?

  # Scopes básicos
  scope :marked_for_teaching, -> { where(marked_for_teaching: true) }
  scope :marked_for_qa, -> { where(marked_for_qa: true) }
  scope :stat_cases, -> { where(priority: :stat) }
  scope :pending_reports, -> { where(status: :pending, task_type: [:interpretation, :reporting]) }
  scope :overdue, -> { where('due_date < ?', Time.current) }
  scope :by_priority, -> { order(priority: :desc, created_at: :asc) }
  scope :today, -> { where(created_at: Date.current.all_day) }
  scope :this_week, -> { where('created_at > ?', 1.week.ago) }

  # Método básico para mostrar la tarea
  def display_name
    if title.present?
      title
    elsif self.case.present?
      "#{task_type.humanize} - #{self.case.display_name}"
    else
      task_type.humanize
    end
  end

  def priority_badge_class
    case priority
    when 'stat'
      'badge-danger'
    when 'urgent'
      'badge-warning'
    when 'routine'
      'badge-secondary'
    end
  end

  def status_badge_class
    case status
    when 'pending'
      'badge-light'
    when 'in_progress'
      'badge-primary'
    when 'completed'
      'badge-success'
    when 'needs_attending_review'
      'badge-info'
    end
  end

  def task_type_icon
    case task_type
    when 'interpretation'
      '📖'
    when 'reporting'
      '📝'
    when 'protocoling'
      '🔬'
    when 'procedure'
      '💉'
    end
  end

  def overdue?
    due_date.present? && due_date < Time.current && !completed?
  end

  def time_spent
    return 0 unless actual_time.present?
    actual_time
  end

  def start_timer!
    update!(
      status: :in_progress,
      started_at: Time.current
    ) if pending?
  end

  def stop_timer!
    return unless in_progress? && started_at.present?

    time_spent = ((Time.current - started_at) / 1.minute).round
    update!(
      actual_time: time_spent,
      completed_at: Time.current
    )
  end

  def complete!
    stop_timer! if in_progress?
    update!(
      status: :completed,
      completed_at: Time.current
    )
  end

  # Métodos para marcar casos especiales
  def mark_for_teaching!(notes = nil)
    update!(
      marked_for_teaching: true,
      notes_for_teaching: notes
    )
  end

  def mark_for_qa!(notes = nil)
    update!(
      marked_for_qa: true,
      notes_for_qa: notes
    )
  end

  def unmark_for_teaching!
    update!(
      marked_for_teaching: false,
      notes_for_teaching: nil
    )
  end

  def unmark_for_qa!
    update!(
      marked_for_qa: false,
      notes_for_qa: nil
    )
  end

  # Métodos de clase
  def self.teaching_library_for_user(user)
    user.tasks.marked_for_teaching
        .includes(:case)
        .group_by { |task| task.case }
        .keys
        .compact
  end

  def self.qa_cases_for_user(user)
    user.tasks.marked_for_qa
        .includes(:case)
        .group_by { |task| task.case }
        .keys
        .compact
  end

  private

  def set_default_values
    self.marked_for_teaching = false if marked_for_teaching.nil?
    self.marked_for_qa = false if marked_for_qa.nil?
  end

  def update_case_status
    return unless self.case.present?

    task_case = self.case
    current_status = status
    current_task_type = task_type

    if current_status == 'completed'
      if current_task_type == 'interpretation'
        task_case.update(study_status: :reported)
      end
    elsif current_status == 'in_progress'
      task_case.update(study_status: :in_progress) if task_case.pending?
    end
  end
end
