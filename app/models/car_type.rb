class CarType < ActiveRecord::Base
  belongs_to :car_group
  has_and_belongs_to_many :companies

  validates_uniqueness_of :name
end
