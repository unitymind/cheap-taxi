#encoding: utf-8
class CarType < ActiveRecord::Base
  belongs_to :car_group
  has_and_belongs_to_many :companies

  validates_uniqueness_of :name

  scope :foreign, where('name != ? AND name != ?', 'ВАЗ', 'ГАЗ')
  scope :by_car_group, lambda { |car_group_id| where(:car_group_id => car_group_id) }
end
