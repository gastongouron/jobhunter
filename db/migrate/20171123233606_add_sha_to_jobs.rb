class AddShaToJobs < ActiveRecord::Migration[5.1]
  def change
    add_column :jobs, :sha, :string
  end
end
