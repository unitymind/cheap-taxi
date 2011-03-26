class CreateCarGroups < ActiveRecord::Migration
  def self.up
    create_table :car_groups do |t|
      t.string :name
    end
  end

  def self.down
    drop_table :car_groups
  end
end
