class CarGroup < ActiveRecord::Base
  has_many :car_types
  has_many :rates
end
