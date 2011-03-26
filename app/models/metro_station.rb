class MetroStation < ActiveRecord::Base
  has_and_belongs_to_many :regions
  validates_uniqueness_of :name
end
