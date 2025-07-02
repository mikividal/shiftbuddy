class AddAttendingReferenceToCase < ActiveRecord::Migration[7.1]
  def change
    add_reference :cases, :attending, null: true, foreign_key: { to_table: :users }
  end
end
