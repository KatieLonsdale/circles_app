class AddNotificationsTokenToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :notifications_token, :string
  end
end
