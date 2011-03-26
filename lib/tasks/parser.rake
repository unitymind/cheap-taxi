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
    puts "Парсим taxodrom.ru...".green

    car_groups = {
      :e_class => CarGroup.find_or_create_by_name('Эконом-класс'),
      :b_class => CarGroup.find_or_create_by_name('Бизнес-класс'),
      :v_class => CarGroup.find_or_create_by_name('VIP-класс')
    }

    ActiveRecord::Base.transaction do
      CheapTaxi::Utils::Parser.instance.parse_company_profile_urls.each do |url|
        id = url.gsub('http://www.taxodrom.ru/taxi-moscow/', '').to_i
        company = CheapTaxi::Utils::Parser.instance.parse_company_profile(url)
        if !company.empty? && !Company.where(:source_id => id).exists? && company[:phones] != '' && !company[:url].nil?
          new_company = Company.create(:name => company[:name], :phones => company[:phones], :source_id => id)

          car_groups.each do |group_key, group_class|
            if company[:car_types].keys.include? group_key
              company[:car_types][group_key].each do |car_name|
                car_rel = CarType.where(:name => car_name)
                unless car_rel.exists?
                  car = CarType.create(:name => car_name)
                  group_class.car_types << car
                else
                  car = car_rel.first
                end
                new_company.car_types << car
              end
            end
          end
          puts "  -->".bold + "  добавлено".green + " \t#{url}\t#{new_company.name.bold}"
        else
          puts "  -->".bold + "  #{'проигнорировано'.red}\t#{url}"
        end
      end
    end
  end
end