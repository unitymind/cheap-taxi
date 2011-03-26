class RenamePriceToPriceDayAddPriceNight < ActiveRecord::Migration
  def self.up
    rename_column :rates, :price, :price_day
    add_column :rates, :price_night, :float
  end

  def self.down
    remove_column :rates, :price_night
    rename_column :rates, :price_day, :price_night
  end
end
