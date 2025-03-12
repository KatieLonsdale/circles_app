class CreateFriendships < ActiveRecord::Migration[7.0]
  def change
    create_table :friendships do |t|
      t.references :user, null: false, foreign_key: { to_table: :users }
      t.references :friend, null: false, foreign_key: { to_table: :users }
      t.integer :status, null: false, default: 0

      t.timestamps
    end

    add_index :friendships, [:user_id, :friend_id], unique: true
  end
end
