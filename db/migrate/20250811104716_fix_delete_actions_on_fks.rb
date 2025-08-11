class FixDeleteActionsOnFks < ActiveRecord::Migration[8.0]
  def up
    # options → questions (cascade)
    remove_foreign_key :options, :questions
    add_foreign_key    :options, :questions, on_delete: :cascade

    # questions → quizzes (cascade)
    remove_foreign_key :questions, :quizzes
    add_foreign_key    :questions, :quizzes, on_delete: :cascade

    # guesses → options (cascade)
    remove_foreign_key :guesses, :options
    add_foreign_key    :guesses, :options, on_delete: :cascade

    # games → quizzes (cascade)
    remove_foreign_key :games, :quizzes
    add_foreign_key    :games, :quizzes, on_delete: :cascade

    # feedbacks → quizzes (cascade)
    remove_foreign_key :feedbacks, :quizzes
    add_foreign_key    :feedbacks, :quizzes, on_delete: :cascade
  end

  def down
    # revert to plain FKs (no cascade)
    remove_foreign_key :options,   :questions
    add_foreign_key    :options,   :questions

    remove_foreign_key :questions, :quizzes
    add_foreign_key    :questions, :quizzes

    remove_foreign_key :guesses,   :options
    add_foreign_key    :guesses,   :options

    remove_foreign_key :games,     :quizzes
    add_foreign_key    :games,     :quizzes

    remove_foreign_key :feedbacks, :quizzes
    add_foreign_key    :feedbacks, :quizzes
  end
end
