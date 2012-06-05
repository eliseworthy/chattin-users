class Authentication < ActiveRecord::Base
  validates_uniqueness_of :uid, scope: :provider
  belongs_to :user

  def self.create_from_omniauth(auth_hash, user_id)
    provider   = auth_hash["provider"]
    expires_at = auth_hash["credentials"]["expires_at"].to_i
    token      = auth_hash["credentials"]["token"]
    uid        = auth_hash["uid"]

    authentication_attributes = {
      provider:   provider,
      expires_at: expires_at,
      token:      token,
      uid:        uid,
      user_id:    user_id
    }

    auth = find_or_initialize_by_uid_and_provider(
      authentication_attributes[:uid], 
      authentication_attributes[:provider], 
      authentication_attributes
    )
    auth.save

    auth
  end
end
