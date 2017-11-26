class AddSubscriptionsToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :subscribed, :boolean, default: false
  end
end
