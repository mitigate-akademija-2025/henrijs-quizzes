class CreateGames < ActiveRecord::Migration[8.0]
  def change
    create_table :games do |t|
      t.references :user, null: true, foreign_key: { on_delete: :cascade }
      t.references :quiz, null: false, foreign_key: { on_delete: :cascade }
      t.integer :score
      t.string :share_token
      t.datetime :finished_at
      t.datetime :started_at
      t.timestamps
    end
  end

  add_index :games, :share_token, unique: true
  add_index :games, :user_id
  add_index :games, :quiz_id
  add_index :games, [ :id, :quiz_id ],
            unique: true,
            name: "idx_games_id_quiz_unique"
end
