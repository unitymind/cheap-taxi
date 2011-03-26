require 'spec_helper'

module CheapTaxi::Models
  describe RegionLink do
    subject { RegionLink.new }

    it { should belong_to(:from_region) }
    it { should belong_to(:to_region) }

    it { should validate_uniqueness_of(:from_region_id, :scope => :to_region_id) }
  end
end
