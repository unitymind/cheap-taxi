# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20110325231435) do

  create_table "car_types", :force => true do |t|
    t.string "name"
  end

  create_table "car_types_companies", :id => false, :force => true do |t|
    t.integer "company_id"
    t.integer "car_type_id"
  end

  add_index "car_types_companies", ["company_id", "car_type_id"], :name => "index_car_types_companies_on_company_id_and_car_type_id"

  create_table "companies", :force => true do |t|
    t.string  "name"
    t.string  "site_url"
    t.string  "phones"
    t.integer "source_id"
  end

  add_index "companies", ["name"], :name => "index_companies_on_name"

  create_table "companies_regions", :id => false, :force => true do |t|
    t.integer "company_id"
    t.integer "region_id"
  end

  add_index "companies_regions", ["company_id", "region_id"], :name => "index_companies_regions_on_company_id_and_region_id"

  create_table "districts", :force => true do |t|
    t.string "name"
  end

  add_index "districts", ["name"], :name => "index_districts_on_name", :unique => true

  create_table "metro_stations", :force => true do |t|
    t.string "name"
    t.string "url"
    t.string "sha1_hash"
  end

  add_index "metro_stations", ["name"], :name => "index_metro_stations_on_name", :unique => true
  add_index "metro_stations", ["sha1_hash"], :name => "index_metro_stations_on_sha1_hash"

  create_table "metro_stations_regions", :id => false, :force => true do |t|
    t.integer "region_id"
    t.integer "metro_station_id"
  end

  add_index "metro_stations_regions", ["region_id", "metro_station_id"], :name => "index_metro_stations_regions_on_region_id_and_metro_station_id"

  create_table "rates", :force => true do |t|
    t.integer "company_id"
    t.integer "route_id"
    t.integer "travel_time"
    t.integer "pick_up_time"
    t.float   "price_day"
    t.float   "price_night"
  end

  create_table "region_links", :force => true do |t|
    t.integer "from_region_id"
    t.integer "to_region_id"
  end

  add_index "region_links", ["from_region_id", "to_region_id"], :name => "index_region_links_on_from_region_id_and_to_region_id", :unique => true

  create_table "regions", :force => true do |t|
    t.string  "name"
    t.integer "area"
    t.integer "population"
    t.string  "sha1_hash"
    t.string  "url"
    t.integer "district_id"
  end

  add_index "regions", ["district_id"], :name => "index_regions_on_district_id"
  add_index "regions", ["name"], :name => "index_regions_on_name", :unique => true
  add_index "regions", ["sha1_hash"], :name => "index_regions_on_sha1_hash"

  create_table "routes", :force => true do |t|
    t.integer "from_region_id"
    t.integer "to_region_id"
    t.string  "path"
    t.integer "routes_count"
    t.float   "distance"
  end

  add_index "routes", ["from_region_id", "to_region_id"], :name => "index_routes_on_from_region_id_and_to_region_id", :unique => true

end
