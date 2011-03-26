class CompanyAddSourceIdField < ActiveRecord::Migration
  def self.up
    add_column(:companies, :source_id, :integer)
  end

  def self.down
    remove_column(:companies, :source_id)
  end
end
