class Company < ActiveRecord::Base
  has_and_belongs_to_many :regions
  has_and_belongs_to_many :car_types
  has_many :rates

  scope :by_car_group, lambda { |car_group_id|
    joins(:car_types).where('car_types.car_group_id = ?', car_group_id).group('companies.id') }

  scope :by_region, lambda { |region_id|
    joins(:regions).where('regions.id = ?', region_id).group('companies.id') }
end
