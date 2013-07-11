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
  property :channel, Text
end

DataMapper.finalize

Message.auto_upgrade!

# Methods

def parse_title (unparsed_title)
  unparsed_title.gsub("_", " ").capitalize << '?'
end

# Routes
get '/' do
  @title = "Sabihin mo na."
  @unparsed_title = "sabihin_mo_na"
  haml :index 
end

get '/save/:channel/:offset' do
  content_type :json
  channel = params[:channel]
  offset = params[:offset].to_i
  message = Message.all(:channel => channel, :limit => 20, :order => [:created_at.desc], :offset => offset)
  message.to_json
end

post '/save' do
  content_type :json
  message = Message.create(:message => Sanitize.clean(params[:message]), :created_at => Time.now, :channel => params[:channel])
  if message.saved?
    message_to_faye = {message: message.message, created_at: message.created_at}
    return message_to_faye.to_json
  else
    return false
  end
end

get '/question/*' do
  @unparsed_title = params[:splat].first
  @title = parse_title(@unparsed_title)
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
