require 'sinatra'
require 'sass'
require 'haml'
require 'data_mapper'
require 'json'
require 'faye'
require 'sanitize'

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

# Methods

def parse_title (unparsed_title)
  unparsed_title.gsub!("_", " ")
  unparsed_title.capitalize!
  unparsed_title << '?'
end

# Routes
get '/' do
  @title = "Sabihin mo na."
  haml :index 
end

get '/save' do
  content_type :json
  message = Message.all
  message.to_json
end

post '/save' do
  content_type :json
  message = Message.create(:message => Sanitize.clean(params[:message]), :created_at => Time.now)
  if message.saved?
    message_to_faye = {message: message.message, created_at: message.created_at}
    return message_to_faye.to_json
  else
    return false
  end
end

get '/question/*' do
  unparsed_title = params[:splat].first
  @title = parse_title(unparsed_title)
  haml :index
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

#Start Faye Server

use Faye::RackAdapter, :mount => '/faye', :timeout => 25
Faye::WebSocket.load_adapter('thin')
