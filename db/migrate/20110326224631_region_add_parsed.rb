class RegionAddParsed < ActiveRecord::Migration
  def self.up
    add_column(:regions, :parsed, :boolean, :default => false)
  end

  def self.down
    remove_column(:regions, :parsed)
  end
end
