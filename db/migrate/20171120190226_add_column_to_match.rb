class AddColumnToMatch < ActiveRecord::Migration[5.1]
  def change
    add_column :matches, :user_id, :integer
    add_column :matches, :job_id, :integer
  end
end
