require 'spec_helper'

describe CarGroup do
  subject { CarGroup.new }

  it { have_many(:car_types) }
end
