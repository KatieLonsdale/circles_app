class CreateCircles < ActiveRecord::Migration[7.0]
  def change
    create_table :circles do |t|
      t.string :name, null: false
      t.references :user, null: false, foreign_key: true
      t.string :description, null: false

      t.timestamps
    end
  end
end
