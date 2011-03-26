class RegionLink < ActiveRecord::Base
  belongs_to :from_region, :class_name => 'Region', :foreign_key => 'from_region_id'
  belongs_to :to_region, :class_name => 'Region', :foreign_key => 'to_region_id'
  validates_uniqueness_of :from_region_id, :scope => :to_region_id, :case_sensitive => true
end