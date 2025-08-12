class CreateQuestions < ActiveRecord::Migration[8.0]
  def change
    create_table :questions do |t|
      t.text :content
      t.text :type, null: false, default: "MultipleChoice"
      t.integer :points, null: false, default: 1
      t.references :quiz, null: false, foreign_key: true

      t.timestamps
    end
  end
end
