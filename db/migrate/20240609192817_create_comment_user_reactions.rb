class CreateCommentUserReactions < ActiveRecord::Migration[7.0]
  def change
    create_table :comment_user_reactions do |t|
      t.references :comment, null: false, foreign_key: true
      t.integer :user_id, null: false
      t.integer :reaction_id, null: false

      t.timestamps
    end
  end
end
