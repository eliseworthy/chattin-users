class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string   :name, :email
      t.timestamps
    end
    
    create_table :authentications do |t|
      t.string   :provider, :token, :uid
      t.datetime :expires_at
      t.integer  :user_id
      t.timestamps
    end
  end
end