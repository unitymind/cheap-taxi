class CreateDistricts < ActiveRecord::Migration
  def self.up
    create_table :districts do |t|
      t.string :name
    end
    add_index(:districts, :name, :unique => true)
  end

  def self.down
    drop_table :districts
  end
end
