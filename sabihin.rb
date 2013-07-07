require 'sinatra'
require 'sass'
require 'haml'
require 'coffee-script'
require 'data_mapper'
require 'json'

DataMapper.setup(:default, ENV['DATABASE_URL'] || 'postgres://localhost/sabihin')

# Models

class Message 
  include DataMapper::Resource
  property :id, Serial
  property :message, Text
  property :created_at, DateTime
end

DataMapper.finalize

Message.auto_upgrade!

# Routes
get '/' do
  haml :index 
end

get '/save' do
  content_type :json
  message = Message.all
  message.to_json
end

post '/save' do
  message = Message.create(:message => params[:message], :created_at => Time.now)
  if message.saved?
    true.to_json
  else
    false.to_json
  end
end

# Compile Resources
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
