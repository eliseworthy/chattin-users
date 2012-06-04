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
class ChattinAuth < Sinatra::Base
  #setting up the environment
  env_index = ARGV.index("-e")
  env_arg = ARGV[env_index + 1] if env_index
  env = env_arg || ENV["SINATRA_ENV"] || "development"
  databases = YAML.load_file("config/database.yml")
  ActiveRecord::Base.establish_connection(databases[env])

  #authentication
  #get root
  get '/' do
    <<-HTML
      <ul>
        <li><a href='/auth/google_oauth2'>Sign in with google</a></li>
      </ul>
    HTML
  end

  #callback after google login
  get '/auth/:provider/callback' do
    content_type 'text/plain'
     begin
       omniauth_hash = request.env['omniauth.auth'].to_hash
        if omniauth_hash
          provider   = omniauth_hash["provider"]
          uid        = omniauth_hash["uid"]
          name       = omniauth_hash["info"]["name"]
          email      = omniauth_hash["info"]["email"]
          token      = omniauth_hash["credentials"]["token"]
          expires_at = omniauth_hash["credentials"]["expires_at"].to_i
          attributes = {
            name: name, 
            email: email, 
            uid: uid, 
            authorizations_attributes: [provider: provider, expires_at: expires_at, token: token]
          }
          
          user = User.create(attributes)
          user.to_json
        else
          error 400, omniauth_hash.errors.to_json
        end
      rescue => e
        error 400, e.message.to_json
      end
  end
  
  
  #failure upon login  
  get '/auth/failure' do
    content_type 'text/plain'
    request.env['omniauth.auth'].to_hash.inspect rescue "No Data"
  end
  
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
end  
