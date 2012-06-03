$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'bundler'
require 'rack'
require 'sinatra/base'
require 'active_record'
require 'omniauth'
require 'omniauth-google-oauth2'
require 'service'

GOOGLE_ID = ENV['CHATTIN_GOOGLE_CLIENT_ID']
GOOGLE_SECRET = ENV['CHATTIN_GOOGLE_SECRET']

use Rack::Session::Cookie

use OmniAuth::Builder do
  provider :google_oauth2, "605746141208.apps.googleusercontent.com", "sHNsU1y5e5fjKoCII17n6xaR'
end

run service.rb