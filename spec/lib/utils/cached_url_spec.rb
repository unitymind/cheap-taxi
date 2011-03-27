require "spec_helper"
require "utils"

describe CheapTaxi::Utils::CachedUrl do
  include CheapTaxi::Utils

  it "should be singleton" do
    expect { CachedUrl.new }.to raise_error(NoMethodError)
    CachedUrl.instance.should be(CachedUrl.instance)
  end
end

