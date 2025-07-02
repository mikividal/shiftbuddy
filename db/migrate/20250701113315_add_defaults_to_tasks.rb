class AddDefaultsToTasks < ActiveRecord::Migration[7.1]
  def change
    change_column_default :tasks, :status, 0              # pending
    change_column_default :tasks, :marked_for_teaching, false
    change_column_default :tasks, :marked_for_qa, false
  end
end
