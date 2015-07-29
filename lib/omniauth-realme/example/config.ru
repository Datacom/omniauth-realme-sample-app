require 'bundler/setup'
require 'omniauth-realme'
require './app.rb'

use OmniAuth::Builder do
  provider :realme#, ENV['APP_ID'], ENV['APP_SECRET'], :scope => 'email,read_stream'
end

run Sinatra::Application
