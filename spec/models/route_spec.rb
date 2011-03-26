require 'spec_helper'

module CheapTaxi::Models
  describe Route do
    subject { Route.new }

    it { should have_many(:rates) }
  end
end
