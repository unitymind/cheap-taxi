class CreateRates < ActiveRecord::Migration
  def self.up
    create_table :rates do |t|
      t.references :car_type
      t.references :company
      t.references :route
      t.integer :travel_time
      t.integer :pick_up_time
      t.float :price
    end
  end

  def self.down
    drop_table :rates
  end
end
