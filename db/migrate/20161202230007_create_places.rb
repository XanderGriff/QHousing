class CreatePlaces < ActiveRecord::Migration[5.0]
  def change
    create_table :places do |t|
      t.string :title
      t.string :address
      t.integer :rent
      t.integer :bedrooms
      t.string :place_type
      t.string :link
      t.float :latitude
      t.float :longitude

      t.timestamps
    end
  end
end
