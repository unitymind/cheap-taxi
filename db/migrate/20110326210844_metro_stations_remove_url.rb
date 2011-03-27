class MetroStationsRemoveUrl < ActiveRecord::Migration
  def self.up
    remove_column(:metro_stations, :url)
  end

  def self.down
    add_column(:metro_stations, :url, :string)
  end
end
