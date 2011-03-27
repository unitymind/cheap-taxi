class Company < ActiveRecord::Base
  has_and_belongs_to_many :regions
  has_and_belongs_to_many :car_types
  has_many :rates
end
