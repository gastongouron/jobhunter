class AddMarkAsSeenToMatches < ActiveRecord::Migration[5.1]
  def change
    add_column :matches, :seen, :boolean, default: false
  end
end
