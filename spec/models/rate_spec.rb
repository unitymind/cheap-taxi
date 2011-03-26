require 'spec_helper'

module CheapTaxi::Models
  describe Rate do
    subject { Rate.new }

    it { should belong_to(:car_type) }
    it { should belong_to(:company) }
    it { should belong_to(:route) }
  end
end
