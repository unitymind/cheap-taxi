class CreateRoutes < ActiveRecord::Migration
  def self.up
    create_table :routes do |t|
      t.integer :from_region_id
      t.integer :to_region_id
      t.string :path
      t.integer :routes_count
      t.float :distance
    end
    add_index :routes, [:from_region_id, :to_region_id], :unique => true
  end

  def self.down
    drop_table :routes
  end
end
