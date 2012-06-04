class User < ActiveRecord::Base
  validates_uniqueness_of :name, :email
  has_many :authorizations
  accepts_nested_attributes_for :authorizations
  
  def to_json
    super
  end
end
