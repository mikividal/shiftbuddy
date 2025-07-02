class AddDefaultsToCases < ActiveRecord::Migration[7.1]
  def change
    change_column_default :cases, :study_status, 0  # pending
    change_column_default :cases, :priority, 0      # routine
  end
end
