class CreateTasks < ActiveRecord::Migration[7.1]
  def change
    create_table :tasks do |t|
      t.string :title
      t.text :description
      t.integer :priority
      t.integer :status
      t.integer :task_type
      t.datetime :due_date
      t.integer :estimated_time
      t.integer :actual_time
      t.text :findings
      t.text :impression
      t.boolean :marked_for_teaching
      t.boolean :marked_for_qa
      t.text :notes_for_teaching
      t.text :notes_for_qa
      t.datetime :started_at
      t.datetime :completed_at
      t.references :user, null: false, foreign_key: true
      t.references :case, null: false, foreign_key: true

      t.timestamps
    end
  end
end
