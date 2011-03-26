class CarTypeAddNameIndex < ActiveRecord::Migration
  def self.up
    add_index(:car_types, :name, :unique => true)
  end

  def self.down
    remove_index(:car_types, :name)
  end

end
