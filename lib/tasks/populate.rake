#encoding: utf-8
require "utils/graph"

namespace :db do
  namespace :populate do

    desc "Populate and generate (randomly) needed data"
    task(:all => ["db:populate:routes", "db:populate:companies_to_regions", "db:populate:rates"])

    desc "Create graph from RegionLinks and Regions. Find shortest path from one region to another and save them to database"
    task :routes => :environment do
      puts "\n" + "** ".bold + "Создаем карту кратчайших маршрутов...".green.bold
      graph = CheapTaxi::Utils::Graph.new
      result_graph = []
      created = 0
      RegionLink.all.each { |link| graph.add_edge(link.from_region_id, link.to_region_id, Region.where(:id => [link.from_region_id, link.to_region_id]).average(:area).to_i) }
      Region.select("id").all.each { |r| result_graph.concat graph.shortest_paths(r.id) }
      ActiveRecord::Base.transaction do
        result_graph.each do |route|
          unless Route.where(:from_region_id => route[:from], :to_region_id => route[:to]).exists?
            Route.create(:from_region_id => route[:from], :to_region_id => route[:to],
                         :path => route[:path].join(','), :routes_count => (route[:path].size-1),
                         :distance => (route[:distance] * 0.01 * 0.5).round(2).to_f)
            created += 1
          end
        end
      end
      puts "   -->".bold + "  Создано новых маршрутов: ".green + created.to_s.bold
    end

    desc "Random bind companies to regions. Can be re-run many times"
    task :companies_to_regions => :environment do
      puts "\n" + "**  ".bold + "Распределяем компании по районам в случайном порядке...".green.bold
      regions = []
      Region.all.each { |r| regions.push r }

      ActiveRecord::Base.transaction do
        Company.all.each do |c|
          c.regions.delete_all
        end
      end

      ActiveRecord::Base.transaction do
        Company.all.each do |c|
          c.region_ids = []
          c.save
          c.regions << regions.shuffle.slice(0, Random.new.rand(30..35))
          puts "    -->".bold + "  обработан  ".green + c.name
        end
      end
    end

    desc "Generate random rates for companies. For different car_group - different rates"
    task :rates => :environment do
      CAR_GROUP_RATES = {
        'e_class' => {
          :pick_up_time => 10..20,
          :price_day => 10..15,
          :price_night_plus => 2..4,
          :min_price_day => [250, 300, 350],
          :min_distance_mult => 0.9,
          :min_price_night_step => 50
        },
        'b_class' => {
          :pick_up_time => 10..15,
          :price_day => 15..20,
          :price_night_plus => 2..5,
          :min_price_day => [400, 500, 600],
          :min_distance_mult => 0.8,
          :min_price_night_step => 100
        },
        'v_class' => {
          :pick_up_time => 5..15,
          :price_day => 20..30,
          :price_night_plus => 5..10,
          :min_price_day => [600, 800, 1000],
          :min_distance_mult => 0.7,
          :min_price_night_step => 200
        }
      }

      puts "\n" + "**  ".bold + "Генерируем случайные тарифы для компаний...".green.bold
      Rate.delete_all
      ActiveRecord::Base.transaction do
        Company.all.each do |company|
          company.car_types.select('distinct car_group_id').map { |t| t.car_group }.each do |car_group|

            pick_up_time = Random.new.rand(CAR_GROUP_RATES[car_group.tag][:pick_up_time])
            price_day = Random.new.rand(CAR_GROUP_RATES[car_group.tag][:price_day])
            price_night = price_day + Random.new.rand(CAR_GROUP_RATES[car_group.tag][:price_night_plus])
            min_price_day = CAR_GROUP_RATES[car_group.tag][:min_price_day].shuffle.pop
            min_price_day_distance = ((min_price_day / price_day) * CAR_GROUP_RATES[car_group.tag][:min_distance_mult]).to_i
            min_price_night = min_price_day + CAR_GROUP_RATES[car_group.tag][:min_price_night_step]
            min_price_night_distance = ((min_price_night / price_night) * CAR_GROUP_RATES[car_group.tag][:min_distance_mult]).to_i

            Rate.create(:car_group => car_group, :company => company, :pick_up_time => pick_up_time,
                        :price_day => price_day, :price_night => price_night, :min_price_day => min_price_day,
                        :min_price_day_distance => min_price_day_distance, :min_price_night => min_price_night,
                        :min_price_night_distance => min_price_night_distance)
          end
          puts "    -->".bold + "  тариф сгенерирован  ".green + company.name
        end
      end
    end
  end
end
