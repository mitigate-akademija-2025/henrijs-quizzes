class CreateOptions < ActiveRecord::Migration[8.0]
  def change
    create_table :options do |t|
      t.text :content
      t.boolean :correct, null: false, default: false
      t.references :question, null: false, foreign_key: { on_delete: :cascade }
      t.timestamps
    end

    add_index :options, [:id, :question_id],
              unique: true,
              name: "idx_options_id_question_unique"
    add_index :options, [ :question_id, :correct ], name: "index_options_on_question_and_correct"
  end
end
