$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'rubygems'
require 'bundler/setup'
require 'logger'
require 'active_record'
require 'sinatra'
require 'omniauth'
require 'omniauth-google-oauth2'
require 'models/user'
require 'models/authorization'
require 'helpers'

class ChattinAuth < Sinatra::Base
  helpers Helpers

  #setting up the environment
  env_index = ARGV.index("-e")
  env_arg = ARGV[env_index + 1] if env_index
  env = env_arg || ENV["SINATRA_ENV"] || "development"
  databases = YAML.load_file("config/database.yml")
  ActiveRecord::Base.establish_connection(databases[env])
  #HTTP entry points
  
  #get all users
  get '/api/v1/users' do
    User.all.to_json
  end

  #create user from omniauth hash
  post '/api/v1/users/?' do
    begin
      user = User.create_from_omniauth(json_body)

      unless user.new_record?
        authorization = Authorization.create_from_omniauth(json_body, user.id)
        unless authorization.new_record?
          user.to_json
        else
          error 400, { errors: authorization.errors }.to_json
        end
      else
        error 400, { errors: user.errors }.to_json
      end
    rescue => e
      error 400, { errors: [ e.message ] }.to_json
    end
  end
  
  #get a user by id
  get '/api/v1/users/:id' do
    user = User.find_by_id(params[:id]) 
    if user
      user.to_json
    else
      error 404, {error: "user not found"}.to_json
    end
  end

  #update existing user
  put '/api/v1/users/:id/' do
    user = User.find_by_id(params[:id])
    if user
      begin
        if user.update_attributes(JSON.parse(request.body.read))
          user.to_json
        else
          error 400, user.errors.to_json
        end
      rescue => e
        error 400, e.message.to_json
      end
    else
      error 404, {error: "user not found".to_json}
    end
  end

  #delete user
  delete '/api/v1/users/:id' do
    user = User.find_by_id(params[:id])
    if user
      user.authorizations.each { |a| a.destroy }
      user.destroy
      user.to_json
    else
      error 404, {error: "user not found".to_json}
    end
  end
  
  #get authorization
  get '/api/v1/authorizations' do
    Authorization.all.to_json
  end
  
  #get authorization
  get '/api/v1/authorizations/:id' do
    authorization = Authorization.find(params[:id])
    if authorization
      authorization.to_json
    else
      error 404, {error: "auth not found".to_json}
    end
  end
  
  #delete authorization
  delete '/api/v1/authorizations/:id' do
    authorization = Authorization.find(params[:id])
    if authorization
      authorization.destroy
      status 200, {status: "auth deleted"}.to_json
    else
      error 404, {error: "auth not found".to_json}
    end
  end
end  
