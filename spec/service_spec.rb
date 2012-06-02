$LOAD_PATH.unshift(File.dirname(__FILE__))
require File.dirname(__FILE__) + '/../service'
require 'rspec'
require 'sinatra/base'
require 'rack/test'

set :environment, :test

RSpec.configure do |conf|
  conf.include Rack::Test::Methods
end

def app
  Sinatra::Application
end

describe 'service' do
  before(:each) do
    User.delete_all
  end
  
  describe "GET on /api/v1/users/:id" do
    before(:each) do
      User.create(name: "elise", email: "elise@example.com", password: "abc", bio: "girl")
    end
    
    it "should return a user by name" do
      get '/api/v1/users/elise'
      last_response.should be_ok
      attributes = JSON.parse(last_response.body)["user"]
      attributes["name"].should == "elise"
    end
    
    it "should return a user with an email" do
      get '/api/v1/users/elise'
      last_response.should be_ok
      attributes = JSON.parse(last_response.body)["user"]
      attributes["email"].should == "elise@example.com"
    end
    
    it "should not return a user's password" do
      get '/api/v1/users/elise'
      last_response.should be_ok
      attributes = JSON.parse(last_response.body)["user"]
      attributes.should_not have_key("password")
    end
    
    it "should return a user with a bio" do
      get '/api/v1/users/elise'
      last_response.should be_ok
      attributes = JSON.parse(last_response.body)["user"]
      attributes["bio"].should == "girl"
    end
    
    it "should return a 404 for a user that doesn't exist" do
      get '/api/v1/users/foo'
      last_response.status.should == 404
    end
  end
  
  describe "POST on /api/v1/users" do
    it "should create a user" do
      post '/api/v1/users', {
        name: "trotter",
        email: "no spam",
        password: "whatever",
        bio: "southern belle"
      }.to_json
      last_response.should be_ok
      get '/api/v1/users/trotter'
      attributes = JSON.parse(last_response.body)["user"]
      attributes["name"].should == "trotter"
      attributes["email"].should == "no spam"
      attributes["bio"].should == "southern belle"
    end
  end
end