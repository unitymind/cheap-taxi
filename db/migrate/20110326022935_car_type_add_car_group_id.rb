class CarTypeAddCarGroupId < ActiveRecord::Migration
  def self.up
    add_column(:car_types, :car_group_id, :integer)
    add_index(:car_types, :car_group_id)
  end

  def self.down
    remove_column(:car_types, :car_group_id)
  end
end
