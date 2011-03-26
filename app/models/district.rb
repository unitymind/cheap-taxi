class District < ActiveRecord::Base
  has_many :regions
  validates_uniqueness_of :name
end
