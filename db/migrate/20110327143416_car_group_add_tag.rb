class CarGroupAddTag < ActiveRecord::Migration
  def self.up
    add_column(:car_groups, :tag, :string)
  end

  def self.down
    remove_column(:car_groups, :tag)
  end
end
