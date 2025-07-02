class Case < ApplicationRecord
  # Relaciones
  belongs_to :user # residente asignado
  belongs_to :attending, class_name: 'User', optional: true
  has_many :tasks, dependent: :destroy

  # Validaciones
  validates :accession_number, presence: true, uniqueness: true
  validates :patient_name, presence: true
  validates :modality, inclusion: {
    in: %w[CT MRI XR US NM PET Mammo Fluoro DEXA Angio]
  }
  validates :body_part, inclusion: {
    in: ['Head/Brain', 'Neck', 'Chest', 'Abdomen', 'Pelvis', 'Spine',
         'Upper Extremity', 'Lower Extremity', 'Breast', 'Cardiac', 'Whole Body']
  }
  validates :study_status, inclusion: {
    in: %w[pending in_progress reported signed]
  }
  validates :priority, inclusion: {
    in: %w[routine urgent stat]
  }

  # Enums
  enum study_status: { pending: 0, in_progress: 1, reported: 2, signed: 3 }
  enum priority: { routine: 0, urgent: 1, stat: 2 }

  # Scopes
  scope :unread, -> { where(study_status: :pending) }
  scope :in_progress, -> { where(study_status: :in_progress) }
  scope :completed, -> { where(study_status: [:reported, :signed]) }
  scope :by_priority, -> { order(priority: :desc, created_at: :asc) }
  scope :recent, -> { where('created_at > ?', 7.days.ago) }
  scope :today, -> { where(study_date: Date.current.all_day) }

  # Métodos de instancia
  def display_name
    "#{modality} #{body_part} - #{patient_name}"
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
    case study_status
    when 'pending'
      'badge-light'
    when 'in_progress'
      'badge-primary'
    when 'reported'
      'badge-info'
    when 'signed'
      'badge-success'
    end
  end

  def time_since_created
    time_ago_in_words(created_at)
  end

  def overdue?
    return false if completed?

    case priority
    when 'stat'
      created_at < 1.hour.ago
    when 'urgent'
      created_at < 4.hours.ago
    when 'routine'
      created_at < 24.hours.ago
    end
  end

  def has_teaching_cases?
    tasks.any?(&:marked_for_teaching?)
  end

  def has_qa_cases?
    tasks.any?(&:marked_for_qa?)
  end

  def main_interpretation_task
    tasks.interpretation.first
  end

  # Método para crear automáticamente la tarea de interpretación
  def create_interpretation_task!
    return if tasks.interpretation.exists?

    tasks.create!(
      title: "Interpretar #{modality} #{body_part}",
      task_type: :interpretation,
      priority: self.priority,
      user: self.user,
      due_date: calculate_due_date
    )
  end

  private

  def calculate_due_date
    case priority
    when 'stat'
      1.hour.from_now
    when 'urgent'
      4.hours.from_now
    when 'routine'
      24.hours.from_now
    end
  end
end
