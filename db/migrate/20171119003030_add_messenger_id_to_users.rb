class AddMessengerIdToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :messenger_id, :integer, :limit => 8
  end
end
