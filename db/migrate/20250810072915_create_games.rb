class CreateGames < ActiveRecord::Migration[8.0]
  def change
    create_table :games do |t|
      t.references :user, null: true, foreign_key: true
      t.references :quiz, null: false, foreign_key: true
      t.integer :score
      t.string  :share_token, index: { unique: true }
      t.datetime :finished_at
      t.datetime :started_at
      t.timestamps
    end
  end
end
