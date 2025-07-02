class MakeCaseOptionalForTasks < ActiveRecord::Migration[7.1]
  def change
    change_column_null :tasks, :case_id, true
  end
end
