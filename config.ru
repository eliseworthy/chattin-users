$:.unshift File.expand_path("..", __FILE__)

require 'active_record'
use ActiveRecord::ConnectionAdapters::ConnectionManagement

require 'config'
require 'bundler'
require 'rack'
require 'sinatra/base'
require 'omniauth'
require 'omniauth-google-oauth2'
require 'service'

use Rack::Session::Cookie
run ChattinAuth
