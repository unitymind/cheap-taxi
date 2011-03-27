class Rate < ActiveRecord::Base
  belongs_to :car_group
  belongs_to :company
end
