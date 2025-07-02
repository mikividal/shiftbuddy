class CreateCases < ActiveRecord::Migration[7.1]
  def change
    create_table :cases do |t|
      t.string :accession_number
      t.string :patient_name
      t.string :patient_mrn
      t.string :modality
      t.string :body_part
      t.datetime :study_date
      t.integer :priority
      t.integer :study_status
      t.text :clinical_history
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
