class CreatePosts < ActiveRecord::Migration[7.0]
  def change
    create_table :posts do |t|
      t.references :circle, null: false, foreign_key: true
      t.string :caption
      t.integer :author_id, null: false

      t.timestamps
    end
  end
end
