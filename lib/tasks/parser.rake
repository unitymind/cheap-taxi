#encoding: utf-8
require "utils"
require "digest/sha1"

class String
  def sha1
    Digest::SHA1.hexdigest(self)
  end
end

namespace :db do
  namespace :parser do
    namespace :moscow do
      desc "Parse Moscow's districts, area, metro's stations and areas relations. Parse Moscow's taxi companies"
      task(:all => [ "db:parser:moscow:city", "db:parser:moscow:companies" ])

      desc "Parse Moscow's districts, area, metro's stations and areas relations."
      task :city => :environment do
        puts "\n" + "** ".bold + "Парсим Mosopen.ru...".green.bold

        def parse_districts
          ActiveRecord::Base.transaction do
            CheapTaxi::Utils::Parser.instance.parse_districts.each do |district_url, district_info|
              unless District.where(:sha1_hash => district_url.sha1).exists?
                district = District.create(:name => district_info[:name], :sha1_hash => district_url.sha1)
                puts "    -->".bold + "  добавлен  ".green + district_info[:name].bold
                district_info[:regions].each do |region_url, region_name|
                  district.regions << Region.create(:name => region_name, :sha1_hash => region_url.sha1,
                                                    :url => region_url)
                  puts "         -->".bold + "  добавлен район  ".blue + region_name
                end
              else
                puts "    -->".bold + "  уже обработан  ".red + district_info[:name].bold
              end
            end
          end
        end

        def parse_regions
          ActiveRecord::Base.transaction do
            Region.all.each do |region|
              puts "    -->".bold + "  обрабатываем  ".green + region.name.bold

              unless region.parsed
                region_info = CheapTaxi::Utils::Parser.instance.parse_region(region.url)

                region.area = region_info[:area]
                region.population = region_info[:population]
                region.save

                region_info[:metro_stations].each do |metro_url, metro_name|
                  metro_rel = MetroStation.where(:sha1_hash => metro_url.sha1)
                  if metro_rel.exists?
                    region.metro_stations << metro_rel.first
                  else
                    region.metro_stations << MetroStation.create(:name => metro_name, :sha1_hash => metro_url.sha1)
                  end
                  puts "         -->".bold + "  станция метро   ".yellow + metro_name
                end

                region_info[:nearest_regions].each do |nearest_region_url|
                  nearest_region = Region.where(:sha1_hash => nearest_region_url.sha1).first
                  if nearest_region
                    RegionLink.create(:from_region_id => region.id, :to_region_id => nearest_region.id)
                    puts "         -->".bold + "  соседний район  ".blue + nearest_region.name
                  end
                end
                region.parsed = true
                region.save
              else
                puts "         уже обработан".red
              end
            end
          end
        end

        def patch_region_links
          has_errors = false
          Region.all.each do |from_region|
            from_region.to_regions.each do |to_region|
              unless to_region.to_regions(true).include? from_region
                has_errors = true
                RegionLink.create(:from_region => to_region, :to_region => from_region)
                puts "    -->".bold + "  " + to_region.name.bold + "  не ссылается на  ".red + from_region.name.bold + '. ' + 'Исправлено!'.green
              end
            end
          end
          puts "    -->".bold + "  ошибок не найдено  ".green unless has_errors
        end

        puts "\n  Парсим округа Москвы...\n".cyan.bold
        parse_districts

        puts "\n  Парсим районы Москвы...\n".cyan.bold
        parse_regions

        puts "\n  Корректируем карту соседних райнов...\n".cyan.bold
        patch_region_links
      end

      desc "Parse Moscow's taxi companies"
      task :companies => :environment do
        puts "\n" + "** ".bold +  "Парсим Taxodrom.ru...\n".green.bold

        CAR_GROUPS = {
          :e_class => CarGroup.find_or_create_by_name_and_tag('Эконом-класс', 'e_class'),
          :b_class => CarGroup.find_or_create_by_name_and_tag('Бизнес-класс', 'b_class'),
          :v_class => CarGroup.find_or_create_by_name_and_tag('VIP-класс', 'v_class')
        }

        has_new = false

        ActiveRecord::Base.transaction do
          CheapTaxi::Utils::Parser.instance.grab_company_profile_urls.each do |url|
            id = url.gsub('http://www.taxodrom.ru/taxi-moscow/', '').to_i
            company = CheapTaxi::Utils::Parser.instance.parse_company_profile(url)
            if !company.empty? && !Company.where(:source_id => id).exists? && company[:phones] != '' && !company[:url].nil?

              new_company = Company.create(:name => company[:name], :phones => company[:phones],
                                           :site_url => company[:url], :source_id => id)

              CAR_GROUPS.each do |group_key, group_class|
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
              has_new = true
              puts "    -->".bold + "  добавлено  ".green + new_company.name.bold
              puts "         #{url}"
            end
          end
        end
        puts "    -->".bold + "  новых компаний не найдено  ".green unless has_new
      end
    end
  end
end