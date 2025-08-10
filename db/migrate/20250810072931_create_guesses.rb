class CreateGuesses < ActiveRecord::Migration[8.0]
  def change
    create_table :guesses do |t|
      t.references :game, null: false, foreign_key: true
      t.references :option, null: false, foreign_key: true
      t.index [ :game_id, :option_id ], unique: true
      t.timestamps
    end
  end
end
