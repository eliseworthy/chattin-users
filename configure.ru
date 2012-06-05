$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'bundler'
require 'rack'
require 'sinatra/base'
require 'active_record'
require 'omniauth'
require 'omniauth-google-oauth2'
require 'service'

use Rack::Session::Cookie

run ChattinAuth