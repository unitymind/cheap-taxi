class CreateRegions < ActiveRecord::Migration
  def self.up
    create_table :regions do |t|
      t.string :name
      t.integer :area
      t.integer :population
      t.string :sha1_hash
      t.string :url
      t.references :district
    end
    add_index(:regions, :name, :unique => true)
    add_index(:regions, :district_id)
    add_index(:regions, :sha1_hash)
  end

  def self.down
    drop_table :regions
  end
end
