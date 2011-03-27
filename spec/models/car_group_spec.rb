require 'spec_helper'

module CheapTaxi::Models
  describe CarGroup do
    subject { CarGroup.new }

    it { should have_many(:car_types) }
    it { should have_many(:rates) }
  end
end
