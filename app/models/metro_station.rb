class MetroStation < ActiveRecord::Base
  has_and_belongs_to_many :regions
  validates_uniqueness_of :name

  scope :by_district, lambda { |district_id|
    joins(:regions).where('regions.district_id = ?', district_id).group('metro_stations.id') }
end
