require 'spec_helper'

module CheapTaxi::Models
  describe CarType do
    subject { CarType.new }

    it { should have_and_belong_to_many(:companies) }
  end
end

