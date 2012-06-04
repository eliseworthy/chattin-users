class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string   :name
      t.string   :uid
      t.string   :email
      t.timestamps
    end
    
    create_table :authorizations do |t|
      t.string   :provider, :token
      t.datetime :expires_at
      t.integer  :user_id
      t.timestamps
    end
  end
end