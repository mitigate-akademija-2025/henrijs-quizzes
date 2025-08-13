class CreateOptions < ActiveRecord::Migration[8.0]
  def change
    create_table :options do |t|
      t.text :content
      t.boolean :correct, null: false, default: false
      t.references :question, null: false, foreign_key: { on_delete: :cascade }
      t.timestamps
    end
  end
end
