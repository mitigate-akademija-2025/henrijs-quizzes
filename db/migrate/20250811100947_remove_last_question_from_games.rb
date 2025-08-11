class RemoveLastQuestionFromGames < ActiveRecord::Migration[8.0]
  def up
    if foreign_key_exists?(:games, :questions, column: :last_question_id)
      remove_foreign_key :games, :questions, column: :last_question_id
    end

    remove_index :games, :last_question_id if index_exists?(:games, :last_question_id)

    remove_column :games, :last_question_id if column_exists?(:games, :last_question_id)
  end

  def down
    add_column :games, :last_question_id, :bigint
    add_index  :games, :last_question_id
    add_foreign_key :games, :questions, column: :last_question_id
  end
end
