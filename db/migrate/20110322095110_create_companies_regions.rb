class CreateCompaniesRegions < ActiveRecord::Migration
  def self.up
    create_table :companies_regions, :id => false do |t|
      t.references :company
      t.references :region
    end
    add_index :companies_regions, [:company_id, :region_id]
  end

  def self.down
    drop_table :companies_regions
  end
end
