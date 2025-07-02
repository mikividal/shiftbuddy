class AddRadiologyFieldsToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :first_name, :string
    add_column :users, :last_name, :string
    add_column :users, :year_of_training, :integer
    add_column :users, :current_rotation, :string
    add_column :users, :pager_number, :string
    add_column :users, :preferred_modalities, :text
  end
end
