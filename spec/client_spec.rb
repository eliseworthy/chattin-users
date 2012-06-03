require 'rspec'
require 'sinatra/base'
require 'active_record'
require File.dirname(__FILE__) + '/../client'

describe "client" do
  before(:all) do
    User.base_uri = "http://localhost:3000"

    User.destroy("elise")
    User.destroy("bookis")

    User.create(
      :name => "elise",
      :email => "elise@example.com",
      :password => "password",
      :bio => "girloo")
  end
  
  it "should get a user" do 
    user = User.find_by_name("elise")
    user["name"].should == "elise"
    user["email"].should == "elise@example.com"
    user["bio"].should == "girloo"
  end
  
  it "should return nil for a user not found" do
    User.find_by_name("bookis").should be_nil
  end
end
