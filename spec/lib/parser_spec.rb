#encoding: utf-8
require "spec_helper"
require "utils"

describe CheapTaxi::Utils::Parser do
  include CheapTaxi::Utils

  it "should be singleton" do
    expect { Parser.new }.to raise_error(NoMethodError)
    Parser.instance.should be(Parser.instance)
  end
  
  describe "#parse_company_profile_urls" do
    let(:urls) { Parser.instance.parse_company_profile_urls }

    it "should be array of urls linked to companies profiles" do
      urls.should_not == []
      urls.each { |u| u.should match Parser::PROFILE_REG_MATCH }
    end
  end

  describe "#parse_company_profile via http://www.taxodrom.ru/" do
    let(:company_a) { Parser.instance.parse_company_profile('http://www.taxodrom.ru/taxi-moscow/155') }
    let(:company_b) { Parser.instance.parse_company_profile('http://www.taxodrom.ru/taxi-moscow/546') }
    let(:company_c) { Parser.instance.parse_company_profile('http://www.taxodrom.ru/taxi-moscow/297') }
    let(:company_d) { Parser.instance.parse_company_profile('http://www.taxodrom.ru/taxi-moscow/4') }
    let(:company_not_found) { Parser.instance.parse_company_profile('http://www.taxodrom.ru/taxi-moscow/29') }
    let(:company_not_taxodrom) { Parser.instance.parse_company_profile('http://ya.ru') }
    let(:company_not_profile) { Parser.instance.parse_company_profile('http://www.taxodrom.ru/taxi-moscow/') }

    it ":name should be expected" do
      company_a[:name].should == 'Такси 788'
      company_b[:name].should == 'Элит Такси'
      company_c[:name].should == 'Такси-МАКСИ'
      company_d[:name].should == 'Городское такси'
    end

    it ":phones should be expected" do
      company_a[:phones].should == '(495) 788-788-0'
      company_b[:phones].should == '(495) 768-68-13'
      company_c[:phones].should == "(495) 665-05-45\n(903) 550-40-50"
      company_d[:phones].should == ''
    end

    it ":url should be expected" do
      company_a[:url].should == 'http://www.7887880.ru'
      company_b[:url].should == 'http://www.elitataxi.ru'
      company_c[:url].should == 'http://www.taxi-maxi.ru'
      company_d[:url].should be_nil
    end

    it ":car_types should be expected" do
      company_a[:car_types].sort.should == ['e', 'b'].sort
      company_b[:car_types].sort.should == ['b', 'v'].sort
      company_c[:car_types].sort.should == ['e', 'b', 'v'].sort
      company_d[:car_types].should == []
    end

    it "should be empty if got 404 page" do
      company_not_found.should == {}
    end

    it "should be raise ArgumentError for not taxodrom.ru company's profile url" do
      expect { company_not_profile }.to raise_error(ArgumentError)
      expect { company_not_taxodrom }.to raise_error(ArgumentError)
    end
  end

end

