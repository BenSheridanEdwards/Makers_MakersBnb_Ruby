require 'sinatra/base'
require 'date'
require 'json'
require_relative './lib/user.rb'
require_relative './lib/bookings.rb'
require_relative './lib/requests.rb'
require_relative './lib/user.rb'
require_relative './lib/property.rb'
require_relative './lib/holidays.rb'

class MakersAirBnB < Sinatra::Base

  enable :sessions

  get '/' do
    erb :index
  end

  post '/' do
    @@user = User.new(params['name'], params['password'], params['email'])
  end
  
  post '/sign_up' do
    user = User.sign_up(name: params['name'], email: params['email'], password: params['password'])
    session[:user_id] = user.id
    redirect '/spaces'
  end

  post '/' do
    @@user = User.new(params['name'], params['password'], params['email'])
    redirect '/spaces'
  end

  get '/sessions/new' do
    erb :sign_in
  end

  post '/sessions' do
    user = User.authenticate(email: params[:email], password: params[:password])
    session[:user_id] = user.id
    redirect('/spaces')
  end

  get '/spaces' do 
    erb :'spaces'
    @properties = Property.all
    erb :spaces
  end

  get '/spaces/new' do

  end

  get '/spaces/dates' do
    erb :calendar
  end

  post '/dates' do
    $holiday = Holidays.new(params['startdate'], params['enddate'], 1)
    redirect '/spaces'
  end

  get '/requests' do
    @bookings = Bookings.new
    @user_id = 1
    @requests = Requests.new(@user_id)
    erb :requests
  end

  get '/requests/confirm' do
    erb :confirmation
  end

  get '/api/properties' do
    from = DateTime.parse(params[:datefrom])
    to = DateTime.parse(params[:dateto])
    requested_dates = Array(from..to)
    
    available_properties = Property.all.select do |p|
      prop_start_date = DateTime.parse(p.startdate)
      prop_end_date = DateTime.parse(p.enddate)
      available_dates = Array(prop_start_date..prop_end_date)
      
      requested_dates.all? { |date| available_dates.include? date }
    end

    available_properties.map(&:to_hash).to_json
  end

  run! if app_file == $0
end