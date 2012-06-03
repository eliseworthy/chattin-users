require 'rubygems'
require 'bundler/setup'
require 'typhoeus'
require 'json'

class User
  class << self; attr_accessor :base_uri end
  
  def self.find_by_name(name)
    response = Thyphoeus::Request.get(
               "#{base_uri}/api/v1/users/#{name}"
               )
    if response.code == 200
      JSON.parse(response.body)["user"]
    elsif response.code == 404
      nil
    else 
      raise response.body
    end
  end
end        