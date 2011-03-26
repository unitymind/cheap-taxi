#encoding: utf-8
require "utils/parser"

namespace :parser do
  desc "Parse Moscow's districts, area, metro's stations and areas relations. Parse Moscow's taxi companies"
  task(:all => [ "parser:moscow", "parser:companies" ])

  desc "Parse Moscow's districts, area, metro's stations and areas relations."
  task :moscow => :environment do

  end

  desc "Parse Moscow's taxi companies"
  task :companies => :environment do
    puts "Парсим taxodrom.ru..."
    e_class = CarType.find_or_create_by_name('Эконом-класс')
    b_class = CarType.find_or_create_by_name('Бизнес-класс')
    v_class = CarType.find_or_create_by_name('VIP-класс')

    ActiveRecord::Base.transaction do
      CheapTaxi::Utils::Parser.instance.parse_company_profile_urls.each do |url|
        id = url.gsub('http://www.taxodrom.ru/taxi-moscow/', '').to_i
        company = CheapTaxi::Utils::Parser.instance.parse_company_profile(url)
        if !company.empty? && !Company.where(:source_id => id).exists? && company[:phones] != '' && !company[:url].nil?
          new_company = Company.create(:name => company[:name], :phones => company[:phones], :source_id => id)
          e_class.companies << new_company if company[:car_types].include? 'e'
          b_class.companies << new_company if company[:car_types].include? 'b'
          v_class.companies << new_company if company[:car_types].include? 'v'
          puts "\t#{company[:name]} (#{url}) добавлена"
        else
          puts "\t#{url} не найден или пропущен"
        end
      end
    end
  end
end