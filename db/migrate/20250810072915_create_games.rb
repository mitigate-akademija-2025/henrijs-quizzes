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

    add_index :games, :share_token, unique: true
  end
end
