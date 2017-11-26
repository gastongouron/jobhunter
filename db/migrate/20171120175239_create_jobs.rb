class CreateJobs < ActiveRecord::Migration[5.1]
  def change
    create_table :jobs do |t|
      t.string :heading
      t.string :date_posted
      t.string :slug
      t.string :municipality_name
      t.string :export_image_url
      t.string :company_name
      t.string :descr
      t.string :latitude
      t.string :longitude
      t.string :area_name
      t.timestamps
    end
  end
end
