$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'logger'
require 'active_record'
require 'sinatra'

require 'models/user.rb'

#setting up the environment
env_index = ARGV.index("-e")
env_arg = ARGV[env_index + 1] if env_index
env = env_arg || ENV["SINATRA_ENV"] || "development"
databases = YAML.load_file("config/database.yml")
ActiveRecord::Base.establish_connection(databases[env])

#HTTP entry points

#get a user by name
get '/api/v1/users/:name' do
  user = User.find_by_name(params[:name])
  if user
    user.to_json
  else
    error 404, {error: "user not found"}.to_json
  end
end

#create a new user
post '/api/v1/users' do
  begin
    user = User.create(JSON.parse(request.body.read))
    if user
      user.to_json
    else
      error 400, user.errors.to_json
    end
  rescue => e
    error 400, e.message.to_json
  end
end

#update existing user
put '/api/v1/users/:name' do
  user = User.find_by_name(params[:name])
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
delete '/api/v1/users/:name' do
  user = User.find_by_name(params[:name])
  if user
    user.destroy
    user.to_json
  else
    error 404, {error: "user not found".to_json}
  end
end

#verify a user name and password
post '/api/v1/users/:name/sessions' do
  begin
    attributes = JSON.parse(request.body.read)
    user = User.find_by_name_and_password(
      params[:name], 
      attributes["password"]
    )
    if user
      user.to_json
    else
      error 400, {error: "invalid login credentials"}.to_json
    end
    rescue => e
      error 400, e.message.to_json
    end
end
