class User < ActiveRecord::Base
  validates_uniqueness_of :name, :email
  has_many :authorizations
  accepts_nested_attributes_for :authorizations

  def to_json
    super
  end

  def self.create_from_omniauth(auth_hash)
    name  = auth_hash["info"]["name"]
    email = auth_hash["info"]["email"]

    user_attributes = {
      name:  name,
      email: email
    }

    user = find_or_initialize_by_email(
      user_attributes[:email],
      user_attributes
    )

    user.save

    user
  end
end
