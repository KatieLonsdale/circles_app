class CreateContents < ActiveRecord::Migration[7.0]
  def change
    create_table :contents do |t|
      t.references :post, null: false, foreign_key: true
      t.string :video_url
      t.string :image_url

      t.timestamps
    end
  end
end
