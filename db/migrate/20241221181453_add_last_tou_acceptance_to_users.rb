class AddLastTouAcceptanceToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :last_tou_acceptance, :datetime
  end
end
