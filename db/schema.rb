# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.1].define(version: 2025_07_01_120802) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "cases", force: :cascade do |t|
    t.string "accession_number"
    t.string "patient_name"
    t.string "patient_mrn"
    t.string "modality"
    t.string "body_part"
    t.datetime "study_date"
    t.integer "priority", default: 0
    t.integer "study_status", default: 0
    t.text "clinical_history"
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "attending_id"
    t.index ["accession_number"], name: "index_cases_on_accession_number", unique: true
    t.index ["attending_id", "study_status"], name: "index_cases_on_attending_id_and_study_status"
    t.index ["attending_id"], name: "index_cases_on_attending_id"
    t.index ["modality"], name: "index_cases_on_modality"
    t.index ["priority"], name: "index_cases_on_priority"
    t.index ["study_date"], name: "index_cases_on_study_date"
    t.index ["study_status"], name: "index_cases_on_study_status"
    t.index ["user_id", "study_status"], name: "index_cases_on_user_id_and_study_status"
    t.index ["user_id"], name: "index_cases_on_user_id"
  end

  create_table "tasks", force: :cascade do |t|
    t.string "title"
    t.text "description"
    t.integer "priority"
    t.integer "status", default: 0
    t.integer "task_type"
    t.datetime "due_date"
    t.integer "estimated_time"
    t.integer "actual_time"
    t.text "findings"
    t.text "impression"
    t.boolean "marked_for_teaching", default: false
    t.boolean "marked_for_qa", default: false
    t.text "notes_for_teaching"
    t.text "notes_for_qa"
    t.datetime "started_at"
    t.datetime "completed_at"
    t.bigint "user_id", null: false
    t.bigint "case_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["case_id", "task_type"], name: "index_tasks_on_case_id_and_task_type"
    t.index ["case_id"], name: "index_tasks_on_case_id"
    t.index ["due_date"], name: "index_tasks_on_due_date"
    t.index ["marked_for_qa"], name: "index_tasks_on_marked_for_qa"
    t.index ["marked_for_teaching"], name: "index_tasks_on_marked_for_teaching"
    t.index ["priority"], name: "index_tasks_on_priority"
    t.index ["status"], name: "index_tasks_on_status"
    t.index ["task_type"], name: "index_tasks_on_task_type"
    t.index ["user_id", "status"], name: "index_tasks_on_user_id_and_status"
    t.index ["user_id"], name: "index_tasks_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "first_name"
    t.string "last_name"
    t.integer "year_of_training"
    t.string "current_rotation"
    t.string "pager_number"
    t.text "preferred_modalities"
    t.bigint "attending_id"
    t.index ["attending_id"], name: "index_users_on_attending_id"
    t.index ["current_rotation"], name: "index_users_on_current_rotation"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["year_of_training"], name: "index_users_on_year_of_training"
  end

  add_foreign_key "cases", "users"
  add_foreign_key "cases", "users", column: "attending_id"
  add_foreign_key "tasks", "cases"
  add_foreign_key "tasks", "users"
  add_foreign_key "users", "users", column: "attending_id"
end
