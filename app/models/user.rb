class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

   # Relaciones
  has_many :tasks, dependent: :destroy
  has_many :cases, dependent: :destroy
  has_many :supervised_cases, class_name: 'Case', foreign_key: 'attending_id'
  belongs_to :attending, class_name: 'User', optional: true

  # Validaciones
  validates :first_name, :last_name, presence: true
  validates :year_of_training, inclusion: { in: 1..5 }, allow_nil: true
  validates :current_rotation, inclusion: {
    in: %w[chest abdomen neuro musculoskeletal breast cardiac interventional emergency pediatric]
  }, allow_nil: true
  validates :pager_number, format: { with: /\A\d{3,6}\z/ }, allow_nil: true

  # Métodos de instancia
  def full_name
    "#{first_name} #{last_name}"
  end

  def resident?
    year_of_training.present?
  end

  def attending?
    year_of_training.nil? && supervised_cases.any?
  end

  def training_level
    return "Attending" unless resident?
    case year_of_training
    when 1
      "R1 (Primer año)"
    when 2
      "R2 (Segundo año)"
    when 3
      "R3 (Tercer año)"
    when 4
      "R4 (Cuarto año)"
    when 5
      "R5 (Quinto año)"
    end
  end

  def preferred_modalities_list
    preferred_modalities&.split(',')&.map(&:strip) || []
  end

  def preferred_modalities_list=(modalities)
    self.preferred_modalities = modalities.join(', ')
  end

  # Estadísticas del día
  def daily_stats(date = Date.current)
    {
      cases_read: cases.where(updated_at: date.all_day, study_status: ['reported', 'signed']).count,
      reports_completed: tasks.completed.where(updated_at: date.all_day).count,
      avg_report_time: tasks.completed.where(updated_at: date.all_day).where.not(actual_time: nil).average(:actual_time)&.round(1),
      pending_stat_cases: cases.stat.where(study_status: ['pending', 'in_progress']).count
    }
  end
end
