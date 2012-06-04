$LOAD_PATH.unshift(File.dirname(__FILE__))
require File.dirname(__FILE__) + '/../service'
require 'rspec'
require 'sinatra/base'
require 'rack/test'

set :environment, :test

RSpec.configure do |conf|
  helpers = Module.new do
    def json_body
      body = last_response.body
      JSON.parse(body) unless body.empty?
    end
  end

  conf.include Rack::Test::Methods
  conf.include helpers
end

def app
  ChattinAuth
end

describe 'service' do
  before { User.destroy_all }
  let!(:user) { User.create!(name: "elise", email: "elise@example.com") }

  describe "REST API for users" do
    describe "POST on /api/v1/users/" do
      it "should return a created user" do
        auth_hash = {
          provider: "google",
          uid: 1234,
          credentials: {
            expires_at: 123456,
            token: "abcdefghijklmnop",
          },
          info: {
            name: "Charles",
            email: "charles.c.strahan@gmail.com",
          }
        }

        post "/api/v1/users/", auth_hash.to_json
        last_response.should be_ok

        id = json_body["id"].to_i
        id.should_not be_nil
      end
    end

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

      it "should return a 404 for a user that doesn't exist" do
        get "/api/v1/users/12345/"
        last_response.status.should == 404
      end
    end

    describe "PUT on /api/v1/users/:id" do
      it "should update a user" do
        put "/api/v1/users/#{user.id}/", {email: "honey@example.com"}.to_json
        last_response.should be_ok
        get "/api/v1/users/#{user.id}"
        attributes = JSON.parse(last_response.body)["user"]
        attributes["email"].should == "honey@example.com"
      end
    end 

    describe "DELETE on /api/v1/users/:id" do
      it "should delete a user" do
        delete "/api/v1/users/#{user.id}"
        last_response.should be_ok
        get "/api/v1/users/#{user.id}/"
        last_response.status.should == 404
      end
    end
  end
end
