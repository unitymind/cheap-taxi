require 'spec_helper'

module CheapTaxi::Models
  describe CarType do
    subject { CarType.new }

    it { should have_and_belong_to_many(:companies) }
    it { should belong_to(:car_group) }
    it { should validate_uniqueness_of(:name) }
  end
end

