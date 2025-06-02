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

ActiveRecord::Schema[8.0].define(version: 2025_06_02_150624) do
  create_table "evaluation_participants", force: :cascade do |t|
    t.integer "evaluation_id", null: false
    t.integer "user_id", null: false
    t.integer "role", default: 0, null: false
    t.integer "status", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["evaluation_id", "user_id"], name: "index_evaluation_participants_on_evaluation_id_and_user_id", unique: true
    t.index ["evaluation_id"], name: "index_evaluation_participants_on_evaluation_id"
    t.index ["user_id"], name: "index_evaluation_participants_on_user_id"
  end

  create_table "evaluations", force: :cascade do |t|
    t.string "title", null: false
    t.text "description"
    t.integer "organization_id", null: false
    t.integer "evaluator_id", null: false
    t.integer "status", default: 0, null: false
    t.datetime "due_date"
    t.datetime "start_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["evaluator_id"], name: "index_evaluations_on_evaluator_id"
    t.index ["organization_id"], name: "index_evaluations_on_organization_id"
  end

  create_table "memberships", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "organization_id", null: false
    t.integer "role", null: false
    t.integer "status", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "invitation_token"
    t.datetime "invitation_sent_at"
    t.string "email_address"
    t.index ["invitation_token"], name: "index_memberships_on_invitation_token", unique: true
    t.index ["organization_id"], name: "index_memberships_on_organization_id"
    t.index ["user_id", "organization_id"], name: "index_memberships_on_user_id_and_organization_id", unique: true
    t.index ["user_id"], name: "index_memberships_on_user_id"
  end

  create_table "organizations", force: :cascade do |t|
    t.string "name", null: false
    t.text "description"
    t.integer "owner_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_organizations_on_name"
    t.index ["owner_id"], name: "index_organizations_on_owner_id"
  end

  create_table "questions", force: :cascade do |t|
    t.integer "evaluation_id", null: false
    t.text "content", null: false
    t.integer "question_type", default: 0, null: false
    t.integer "order_number", null: false
    t.boolean "is_required", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["evaluation_id", "order_number"], name: "index_questions_on_evaluation_id_and_order_number"
    t.index ["evaluation_id"], name: "index_questions_on_evaluation_id"
  end

  create_table "responses", force: :cascade do |t|
    t.integer "question_id", null: false
    t.integer "participant_id", null: false
    t.text "content"
    t.integer "score"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["participant_id"], name: "index_responses_on_participant_id"
    t.index ["question_id", "participant_id"], name: "index_responses_on_question_id_and_participant_id", unique: true
    t.index ["question_id"], name: "index_responses_on_question_id"
  end

  create_table "sessions", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "ip_address"
    t.string "user_agent"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email_address", null: false
    t.string "password_digest", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email_address"], name: "index_users_on_email_address", unique: true
  end

  add_foreign_key "evaluation_participants", "evaluations"
  add_foreign_key "evaluation_participants", "users"
  add_foreign_key "evaluations", "organizations"
  add_foreign_key "evaluations", "users", column: "evaluator_id"
  add_foreign_key "memberships", "organizations"
  add_foreign_key "memberships", "users"
  add_foreign_key "organizations", "users", column: "owner_id"
  add_foreign_key "questions", "evaluations"
  add_foreign_key "responses", "evaluation_participants", column: "participant_id"
  add_foreign_key "responses", "questions"
  add_foreign_key "sessions", "users"
end
