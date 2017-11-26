class AddRequirePreferenceToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :require_preference, :boolean, default: true
  end
end
