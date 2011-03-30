class Region < ActiveRecord::Base
  belongs_to :district
  has_and_belongs_to_many :companies
  has_and_belongs_to_many :metro_stations

  has_many :to_regions_links, :class_name => 'RegionLink', :foreign_key => 'from_region_id'
  has_many :to_regions, :through => :to_regions_links

  has_many :from_regions_links, :class_name => 'RegionLink', :foreign_key => 'to_region_id'
  has_many :from_regions, :through => :from_regions_links

  validates_uniqueness_of :name

  scope :by_district, lambda { |district_id| where(:district_id => district_id) }
  scope :by_metro_station, lambda { |metro_station_id| joins(:metro_stations).where('metro_stations.id = ?', metro_station_id)}
end
