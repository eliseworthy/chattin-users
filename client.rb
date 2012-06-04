require 'rubygems'
require 'bundler/setup'
require 'typhoeus'
require 'json'

class User
  class << self; attr_accessor :base_uri end
  
  def self.find_all
    response = Typhoeus::Request.get(
               "#{base_uri}/api/v1/users"
               )
    if response.code == 200
       JSON.parse(response.body)
     elsif response.code == 404
       nil
     else 
       raise response.body
     end           
  end             
  
  def self.find_by_id(id)
    response = Typhoeus::Request.get(
               "#{base_uri}/api/v1/users/#{id}"
               )
    if response.code == 200
      JSON.parse(response.body)["user"]
    elsif response.code == 404
      nil
    else 
      raise response.body
    end
  end
     
  def self.create(attributes)
    response = Typhoeus::Request.post(
      "#{base_uri}/api/v1/users/",
      body: attributes.to_json
      )
    if response.code == 200
      JSON.parse(response.body)["user"]
    else
      raise response.body
    end
  end  
  
  def self.update(name, attributes)
    response = Typhoeus::Request.put(
      "#{base_uri}/api/v1/users/#{id}",
      body: attributes.to_json
      )
    if response.code == 200
      JSON.parse(response.body)["user"]
    else
      raise response.body
    end
  end
  
  def self.destroy(name)
    Typhoeus::Request.delete(
      "#{base_uri}/api/v1/users/#{id}"
      ).code == 200
  end
end        