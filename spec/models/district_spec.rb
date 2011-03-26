require 'spec_helper'

module CheapTaxi::Models
  describe District do
    subject { District.new }

    it { should validate_uniqueness_of(:name) }
    it { should have_many(:regions) }
  end
end
