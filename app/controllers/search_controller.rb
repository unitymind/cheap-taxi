class SearchController < ApplicationController
  autocomplete :district, :name
  autocomplete :metro_station, :name, :filter_by => :by_district, :limit => 200
  autocomplete :region, :name, :limit => 200
  autocomplete :car_type, :name, :filter_by => :by_car_group, :full => true, :limit => 200

  def find
    postfix = (8..22).include?(params[:date]['hour'].to_i) ? 'day' : 'night'
    route = Route.where(:from_region_id => params[:from_region_id], :to_region_id => params[:to_region_id]).first

    if route
      @result = []
      Company.by_car_group(params[:car_group][:id]).by_region(params[:from_region_id]).\
        includes(:rates).where('rates.car_group_id = ?', params[:car_group][:id]).each do |company|
          rate = company.rates[0]
          @result.push([company.name, company.site_url, company.phones, rate.pick_up_time, calculate_cost(route, rate, postfix)])
          @from_region = Region.where(:id => params[:from_region_id]).first
          @to_region = Region.where(:id => params[:to_region_id]).first
          @distance = route.distance
      end
    else
      render :nothing =>  true
    end
  end

  private
    def calculate_cost(route, rate, postfix)
      cost = rate.send("min_price_#{postfix}".to_sym)
      pay_for = route.distance - rate.send("min_price_#{postfix}_distance".to_sym)
      if pay_for > 0
        cost += pay_for * rate.send("price_#{postfix}".to_sym)
      end
      cost.to_i
    end

end
