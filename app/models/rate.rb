class Rate < ActiveRecord::Base
  belongs_to :car_type
  belongs_to :company
  belongs_to :route
end
