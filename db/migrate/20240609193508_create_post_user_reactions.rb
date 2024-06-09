class CreatePostUserReactions < ActiveRecord::Migration[7.0]
  def change
    create_table :post_user_reactions do |t|
      t.references :post, null: false, foreign_key: true
      t.integer :user_id, null: false
      t.integer :reaction_id, null: false

      t.timestamps
    end
  end
end
