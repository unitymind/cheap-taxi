class CreateRegionLinks < ActiveRecord::Migration
  def self.up
    create_table :region_links do |t|
      t.integer :from_region_id
      t.integer :to_region_id
    end
    add_index :region_links, [:from_region_id, :to_region_id], :unique => true
  end

  def self.down
    drop_table :region_links
  end
end
