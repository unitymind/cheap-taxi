require 'spec_helper'

module CheapTaxi::Models
  describe Rate do
    subject { Rate.new }

    it { should belong_to(:car_group) }
    it { should belong_to(:company) }
  end
end
