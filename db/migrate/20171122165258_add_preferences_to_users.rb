class AddPreferencesToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :preferences, :string
  end
end
