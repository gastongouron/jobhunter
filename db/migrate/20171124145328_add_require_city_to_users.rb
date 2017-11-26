class AddRequireCityToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :require_city, :boolean, default: true
  end
end
