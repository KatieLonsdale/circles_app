class CreateNotifications < ActiveRecord::Migration[7.0]
  def change
    create_table :notifications do |t|
      t.references :user, null: false, foreign_key: true
      t.references :notifiable, polymorphic: true, null: false
      t.string :message, null: false
      t.boolean :read, default: false, null: false
      t.string :action, null: false
      t.references :circle, null: true, foreign_key: true

      t.timestamps
    end
    
    add_index :notifications, :read
  end
end
