require 'rspec'
require 'sinatra/base'
require 'active_record'
require File.dirname(__FILE__) + '/../client'

describe "client" do
  before(:all) do
    User.base_uri = "http://localhost:3000"
    User.create({name: "elise", email: "elise@elise.com"})
  end
  
  it "should get a user" do 
    user = User.find_by_id(user.id)
    user["name"].should == "elise"
    user["email"].should == "elise@example.com"
  end
  
  it "should return nil for a user not found" do
    User.find_by_name("bookis").should be_nil
  end
  
  it "should create a user" do
    user = User.create(
      name: "bookis",
      email: "bookis@example.com",
    )
    
    user["name"].should == "bookis"
    user["email"].should == "bookis@example.com"
    User.find_by_name("bookis").should == user
  end
  
  it "should update a user" do
    user = User.update("elise", {email: "no@example.com"})
    user["name"].should == "elise"
    user["email"].should == "no@example.com"
    User.find_by_name("elise").should == user
  end
  
  it "should destroy a user" do
    User.destroy("squilio").should == true
    User.find_by_name("squilio").should be_nil
  end  
  
  # it "should verify login credentials" do
  #   user = User.login("elise", "password")
  #   user["name"].should == "elise"
  # end
  # 
  # it "should return nil with invalid credentials" do
  #   User.login("elise", "incorrectpass").should be_nil
  # end
end
