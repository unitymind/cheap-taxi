class DistrictAddSha1HashAndUrl < ActiveRecord::Migration
  def self.up
    add_column(:districts, :sha1_hash, :string)
    add_index(:districts, :sha1_hash)
  end

  def self.down
    remove_column(:districts, :sha1_hash)
  end
end
