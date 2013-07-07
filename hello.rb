require 'sinatra'
require 'data_mapper'
DataMapper.setup(:default, ENV['DATABASE_URL'] || 'postgres://localhost/mydb')

get '/' do
  haml :index 
end

get '/stylesheets/*.css' do
  content_type 'text/css', :charset => 'utf-8'
  filename = params[:splat].first
  sass filename.to_sym, :views => "#{settings.root}/public/stylesheets"
end

get '/javascripts/*.js' do
  content_type 'text/javascript', :charset => 'utf-8'
  filename = params[:splat].first
  coffee filename.to_sym, :views => "#{settings.root}/public/javascripts"
end
