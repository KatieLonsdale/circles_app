class CreateReactions < ActiveRecord::Migration[7.0]
  def change
    create_table :reactions do |t|
      t.string :image_url, null: false

      t.timestamps
    end
  end
end
