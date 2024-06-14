class CreateCircleMembers < ActiveRecord::Migration[7.0]
  def change
    create_table :circle_members do |t|
      t.references :circle, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
