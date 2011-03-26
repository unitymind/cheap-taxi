require 'spec_helper'

module CheapTaxi::Models
  describe Company do
    subject { Company.new }

    it { should have_and_belong_to_many(:regions) }
    it { should have_and_belong_to_many(:car_types) }
  end
end
