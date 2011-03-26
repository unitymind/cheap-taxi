class CompanyRenamePhoneField < ActiveRecord::Migration
  def self.up
    rename_column(:companies, :phone, :phones)
  end

  def self.down
    rename_column(:companies, :phones, :phone)
  end
end
