#encoding: utf-8
require "spec_helper"
require "utils"

describe CheapTaxi::Utils::Parser.to_s.cyan do
  include CheapTaxi::Utils

  it "should be singleton" do
    expect { Parser.new }.to raise_error(NoMethodError)
    Parser.instance.should be(Parser.instance)
  end
  
  describe "#" + "grab_company_profile_urls".blue.bold do
    let(:urls) { Parser.instance.grab_company_profile_urls }

    it "should be correct and expected" do
      urls.should be_kind_of(Array)
      urls.should_not be_empty
      urls.each do |u|
        u.should be_a_kind_of(String)
        u.should_not be_empty
        u.should match Parser::COMPANY_PROFILE_URL_REG_MATCH
      end
    end
  end

  describe "#" +"parse_company_profile".blue.bold do
    let(:company_a) { Parser.instance.parse_company_profile('http://www.taxodrom.ru/taxi-moscow/155') }
    let(:company_b) { Parser.instance.parse_company_profile('http://www.taxodrom.ru/taxi-moscow/546') }
    let(:company_c) { Parser.instance.parse_company_profile('http://www.taxodrom.ru/taxi-moscow/297') }
    let(:company_d) { Parser.instance.parse_company_profile('http://www.taxodrom.ru/taxi-moscow/4') }
    let(:company_not_found) { Parser.instance.parse_company_profile('http://www.taxodrom.ru/taxi-moscow/29') }
    let(:company_not_taxodrom) { Parser.instance.parse_company_profile('http://ya.ru') }
    let(:company_not_profile) { Parser.instance.parse_company_profile('http://www.taxodrom.ru/taxi-moscow/') }

    it "should be correct and expected" do
      company_a[:name].should eq 'Такси 788'
      company_b[:name].should eq 'Элит Такси'
      company_c[:name].should eq 'Такси-МАКСИ'
      company_d[:name].should eq 'Городское такси'

      company_a[:phones].should eq '(495) 788-788-0'
      company_b[:phones].should eq '(495) 768-68-13'
      company_c[:phones].should eq "(495) 665-05-45\n(903) 550-40-50"
      company_d[:phones].should be_empty

      company_a[:url].should eq 'http://www.7887880.ru'
      company_b[:url].should eq 'http://www.elitataxi.ru'
      company_c[:url].should eq 'http://www.taxi-maxi.ru'
      company_d[:url].should be_nil

      company_a[:car_types].keys.sort.should eq [:e_class, :b_class].sort
      company_b[:car_types].keys.sort.should eq [:b_class, :v_class].sort
      company_c[:car_types].keys.sort.should eq [:e_class, :b_class, :v_class].sort
      company_d[:car_types].should be_empty
    end

    it "should be empty if got 404 page" do
      company_not_found.should be_empty
    end

    it "should be raise ArgumentError for non taxodrom.ru company's profile url" do
      expect { company_not_profile }.to raise_error(ArgumentError)
      expect { company_not_taxodrom }.to raise_error(ArgumentError)
    end
  end

  describe "#" + "parse_districts".blue.bold do
    subject { Parser.instance.parse_districts }

    it "should be correct and expected" do
      should be_a_kind_of(Hash)
      should_not be_empty

      subject.keys.each do |key|
        key.should match Parser::DISTRICT_URL_REG_MATCH
        key.should_not match /zelao$/
      end

      subject.values.each do |value|
        value.should be_a_kind_of(Hash)

        value.should be_has_key(:name)
        value[:name].should be_a_kind_of(String)
        value[:name].should_not be_empty

        value.should be_has_key(:regions)
        value[:regions].should be_a_kind_of(Hash)
        value[:regions].should_not be_empty
        value[:regions].each do |region_url, region_name|
          region_url.should match Parser::REGION_URL_MATCH
          region_name.should be_a_kind_of(String)
          region_name.should_not be_empty
        end
      end
    end
  end

  describe "#" + "parse_region".blue.bold do
    subject { Parser.instance.parse_region('http://mosopen.ru/region/arbat') }

    it "should be correct and expected" do
     should be_a_kind_of(Hash)
     should_not be_empty

      subject[:metro_stations].should be_kind_of(Hash)
      subject[:metro_stations].each do |key, value|
        key.should match Parser::METRO_URL_REG_MATCH
        value.should be_a_kind_of(String)
        value.should_not be_empty
      end

      subject[:nearest_regions].should be_kind_of(Array)
      subject[:nearest_regions].should_not be_empty
      subject[:nearest_regions].each { |value| value.should match Parser::REGION_URL_MATCH }

      subject[:area].should be_kind_of(Integer)
      (subject[:area] > 0).should be_true

      subject[:population].should be_kind_of(Integer)
      (subject[:population] > 0).should be_true
    end
  end
end