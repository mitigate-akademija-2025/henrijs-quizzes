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

ActiveRecord::Schema[8.0].define(version: 2025_08_10_134318) do
  create_table "feedbacks", force: :cascade do |t|
    t.integer "quiz_id", null: false
    t.integer "user_id", null: false
    t.text "comment"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["quiz_id"], name: "index_feedbacks_on_quiz_id"
    t.index ["user_id"], name: "index_feedbacks_on_user_id"
  end

  create_table "games", force: :cascade do |t|
    t.integer "user_id"
    t.integer "quiz_id", null: false
    t.integer "score"
    t.string "share_token"
    t.datetime "finished_at"
    t.datetime "started_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["quiz_id"], name: "index_games_on_quiz_id"
    t.index ["share_token"], name: "index_games_on_share_token", unique: true
    t.index ["user_id"], name: "index_games_on_user_id"
  end

  create_table "guesses", force: :cascade do |t|
    t.integer "game_id", null: false
    t.integer "question_id", null: false
    t.integer "option_id"
    t.text "answer_text"
    t.string "type", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["game_id", "option_id"], name: "idx_guesses_unique_game_option_choice", unique: true, where: "type = 'ChoiceGuess'"
    t.index ["game_id", "question_id"], name: "idx_guesses_unique_game_question_text", unique: true, where: "type = 'TextGuess'"
    t.index ["game_id"], name: "index_guesses_on_game_id"
    t.index ["option_id"], name: "index_guesses_on_option_id"
    t.index ["question_id"], name: "index_guesses_on_question_id"
    t.check_constraint "CASE WHEN type = 'ChoiceGuess' THEN option_id IS NOT NULL AND answer_text IS NULL ELSE TRUE END", name: "guesses_choice_shape"
    t.check_constraint "CASE WHEN type = 'TextGuess' THEN option_id IS NULL AND answer_text IS NOT NULL ELSE TRUE END", name: "guesses_text_shape"
  end

  create_table "options", force: :cascade do |t|
    t.text "content"
    t.boolean "correct", default: false, null: false
    t.integer "question_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["question_id"], name: "index_options_on_question_id"
  end

  create_table "questions", force: :cascade do |t|
    t.text "content"
    t.string "type", default: "ChoiceQuestion", null: false
    t.integer "points", default: 1, null: false
    t.integer "max_selections"
    t.string "image_path"
    t.integer "position"
    t.integer "quiz_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["quiz_id"], name: "index_questions_on_quiz_id"
    t.index ["type"], name: "index_questions_on_type"
  end

  create_table "quizzes", force: :cascade do |t|
    t.string "title"
    t.text "description"
    t.integer "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_quizzes_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", null: false
    t.string "encrypted_password", null: false
    t.string "username", null: false
    t.boolean "admin", default: false, null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.integer "failed_attempts", default: 0, null: false
    t.string "unlock_token"
    t.datetime "locked_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["admin"], name: "index_users_on_admin", unique: true
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["unlock_token"], name: "index_users_on_unlock_token", unique: true
    t.index ["username"], name: "index_users_on_username", unique: true
  end

  add_foreign_key "feedbacks", "quizzes", on_delete: :cascade
  add_foreign_key "feedbacks", "users", on_delete: :cascade
  add_foreign_key "games", "quizzes", on_delete: :cascade
  add_foreign_key "games", "users", on_delete: :cascade
  add_foreign_key "guesses", "games", on_delete: :cascade
  add_foreign_key "guesses", "options", on_delete: :cascade
  add_foreign_key "guesses", "questions", on_delete: :cascade
  add_foreign_key "options", "questions", on_delete: :cascade
  add_foreign_key "questions", "quizzes", on_delete: :cascade
  add_foreign_key "quizzes", "users", on_delete: :cascade
end
