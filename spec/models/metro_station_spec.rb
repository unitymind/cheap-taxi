require 'spec_helper'

module CheapTaxi::Models
  describe MetroStation do
    subject { MetroStation.new }

    it { should have_and_belong_to_many(:regions)}

    it { should validate_uniqueness_of(:name) }
  end
end
