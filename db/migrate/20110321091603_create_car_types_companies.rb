class CreateCarTypesCompanies < ActiveRecord::Migration
  def self.up
    create_table :car_types_companies, :id => false do |t|
      t.references :company
      t.references :car_type
    end
    add_index(:car_types_companies, [:company_id, :car_type_id])
  end

  def self.down
    drop_table :car_types_companies
  end
end
