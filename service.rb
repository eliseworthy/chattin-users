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
        <li><a href='/authenticate'>Sign in with google</a></li>
      </ul>
    HTML
  end
  
  get "/authenticate" do
    redirect "/auth/google_oauth2"
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
          
          user_attributes = {
            name: name, 
            email: email
          }
          
          authorization_attributes = {
            provider: provider, 
            expires_at: expires_at, 
            token: token,
            uid: uid
          }  
          
          user = User.find_or_initialize_by_email(
                                                  user_attributes[:email], 
                                                  user_attributes
                                                )
          if user.save
            authorization = user.authorizations.find_or_create_by_uid_and_provider!(authorization_attributes[:uid], authorization_attributes[:provider], authorization_attributes)
          end
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
  
  #get a user by id
  get '/api/v1/users/:id' do
    user = User.find(params[:id])
    if user
      user.to_json
    else
      error 404, {error: "user not found"}.to_json
    end
  end

  #update existing user
  put '/api/v1/users/:id/' do
    user = User.find(params[:id])
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
    user = User.find(params[:id])
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
