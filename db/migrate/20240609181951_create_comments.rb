class CreateComments < ActiveRecord::Migration[7.0]
  def change
    create_table :comments do |t|
      t.references :post, null: false, foreign_key: true
      t.integer :parent_comment_id
      t.integer :author_id, null: false
      t.string :comment_text, null: false

      t.timestamps
    end
  end
end
