class User < ActiveRecord::Base
  validates_uniqueness_of :name, :email, :uid
  
  def to_json
    super
  end
end
