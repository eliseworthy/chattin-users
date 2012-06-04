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
  ChattinAuth
end

describe 'service' do
  before { User.destroy_all }
  let!(:user) { User.create!(name: "elise", email: "elise@example.com") }
  
  describe "GET on /" do
    it "returns the login screen" do
      get '/'
      last_response.should be_ok
    end
  end
  
  describe "REST API for users" do

  
     describe "GET on /api/v1/users/:id" do
      it "should return a user with name" do
        get "/api/v1/users/#{user.id}"
        last_response.should be_ok
        attributes = JSON.parse(last_response.body)["user"]
        attributes["name"].should == "elise"
      end
  
      it "should return a user with an email" do
        get "/api/v1/users/#{user.id}"
        last_response.should be_ok
        attributes = JSON.parse(last_response.body)["user"]
        attributes["email"].should == "elise@example.com"
      end
  
      # it "should not return a user's password" do
      #   get '/api/v1/users/elise'
      #   last_response.should be_ok
      #   attributes = JSON.parse(last_response.body)["user"]
      #   attributes.should_not have_key("password")
      # end
  
      it "should return a 404 for a user that doesn't exist" do
        get "/api/v1/users/12345/"
        last_response.status.should == 404
      end
    end

    describe "PUT on /api/v1/users/:id" do
      it "should update a user" do
        put "/api/v1/users/#{user.id}/", {email: "honey@example.com"}.to_json
        last_response.should be_ok
        get "/api/v1/users/#{user.id}.json"
        attributes = JSON.parse(last_response.body)["user"]
        attributes["email"].should == "honey@example.com"
      end
    end 

    describe "DELETE on /api/v1/users/:id" do
      it "should delete a user" do
        delete "/api/v1/users/#{user.id}.json"
        last_response.should be_ok
        get "/api/v1/users/#{user.id}/"
        last_response.status.should == 404
      end
    end
  end
  
  # describe "POST on /api/v1/users/:id/sessions" do
  #   before(:each) do
  #     User.create(
  #       name: "bookis",
  #     )
  #   end
  #   
  #   # it "should return the user object on valid credentials" do
  #   #       post '/api/v1/users/bookis/sessions', {
  #   #         password: "whatever"}.to_json
  #   #       last_response.should be_ok
  #   #       attributes = JSON.parse(last_response.body)["user"]
  #   #       attributes["name"].should == "bookis"
  #   #     end
  #   #     
  #   #     it "should fail on invalid credentials" do
  #   #       post '/api/v1/users/bookis/sessions', {
  #   #         password: "whatwhat"}.to_json
  #   #       last_response.status.should == 400  
  #   # end
  # end
end