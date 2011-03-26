class CreateMetroStationsRegions < ActiveRecord::Migration
  def self.up
    create_table :metro_stations_regions, :id => false do |t|
      t.references :region
      t.references :metro_station
    end
    add_index(:metro_stations_regions, [:region_id, :metro_station_id])
  end

  def self.down
    drop_table :metro_stations_regions
  end
end
