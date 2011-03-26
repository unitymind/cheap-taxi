require 'spec_helper'

module CheapTaxi::Models
  describe Region do
    subject { Region.new }

    it { should belong_to(:district) }
    it { should have_and_belong_to_many(:companies) }
    it { should have_and_belong_to_many(:metro_stations) }
    it { should have_many(:to_regions) }
    it { should have_many(:from_regions) }

    it { should validate_uniqueness_of(:name) }
  end
end
