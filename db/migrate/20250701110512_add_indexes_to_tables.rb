class AddIndexesToTables < ActiveRecord::Migration[7.1]
  def change
    add_index :tasks, :status
    add_index :tasks, :priority
    add_index :tasks, :task_type
    add_index :tasks, :due_date
    add_index :tasks, :marked_for_teaching
    add_index :tasks, :marked_for_qa
    add_index :tasks, [:user_id, :status]
    add_index :tasks, [:case_id, :task_type]

    # Índices para Case
    add_index :cases, :study_status
    add_index :cases, :priority
    add_index :cases, :modality
    add_index :cases, :study_date
    add_index :cases, :accession_number, unique: true
    add_index :cases, [:user_id, :study_status]
    add_index :cases, [:attending_id, :study_status]

    # Índices para User
    add_index :users, :year_of_training
    add_index :users, :current_rotation
  end
end
