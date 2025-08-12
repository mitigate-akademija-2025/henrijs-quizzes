class CreateGuesses < ActiveRecord::Migration[8.0]
  def change
    create_table :guesses do |t|
      t.references :game,     null: false, foreign_key: true
      t.references :question, null: false, foreign_key: true
      t.references :option,   null: true,  foreign_key: true
      t.text    :answer_text
      t.string  :type, null: false

      t.index [ :game_id, :option_id ],
              unique: true,
              where: "type = 'ChoiceGuess'",
              name: "idx_guesses_unique_game_option_choice"

      t.index [ :game_id, :question_id ],
              unique: true,
              where: "type = 'TextGuess'",
              name: "idx_guesses_unique_game_question_text"

      t.timestamps
    end

    add_check_constraint :guesses,
      "CASE WHEN type = 'ChoiceGuess' THEN option_id IS NOT NULL AND answer_text IS NULL ELSE TRUE END",
      name: "guesses_choice_shape"

    add_check_constraint :guesses,
      "CASE WHEN type = 'TextGuess' THEN option_id IS NULL AND answer_text IS NOT NULL ELSE TRUE END",
      name: "guesses_text_shape"
  end
end
