class ModifyRate < ActiveRecord::Migration
  def self.up
    remove_column(:rates, :route_id)
    remove_column(:rates, :travel_time)
    rename_column(:rates, :car_type_id, :car_group_id)
    add_column(:rates, :min_price_day, :float)
    add_column(:rates, :min_price_day_distance, :integer)
    add_column(:rates, :min_price_night, :float)
    add_column(:rates, :min_price_night_distance, :integer)
  end

  def self.down
    remove_column(:rates, :min_price_night_distance)
    remove_column(:rates, :min_price_night)
    remove_column(:rates, :min_price_day_distance)
    remove_column(:rates, :min_price_day)
    rename_column(:rates, :car_group, :car_type_id)
    add_column(:rates, :travel_time, :integer)
    add_column(:rates, :route_id, :integer)
  end
end
