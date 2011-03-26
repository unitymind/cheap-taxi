class CreateMetroStations < ActiveRecord::Migration
  def self.up
    create_table :metro_stations do |t|
      t.string :name
      t.string :url
      t.string :sha1_hash
    end
    add_index(:metro_stations, :name, :unique => true)
    add_index(:metro_stations, :sha1_hash)
  end

  def self.down
    drop_table :metro_stations
  end
end
