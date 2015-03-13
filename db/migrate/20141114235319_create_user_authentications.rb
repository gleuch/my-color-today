class CreateUserAuthentications < ActiveRecord::Migration

  def change
    create_table :user_authentications do |t|
      t.integer   :user_id
      t.string    :uuid
      t.string    :uid
      t.string    :provider
      t.string    :name
      t.string    :email
      t.string    :username
      t.string    :token
      t.string    :secret
      t.string    :refresh_token
      t.datetime  :token_expires_at
      t.string    :avatar_file_name
      t.string    :avatar_content_type
      t.integer   :avatar_file_size,        default: 0
      t.datetime  :avatar_updated_at
      t.string    :profile_url
      t.string    :profile_image_url
      t.date      :birthday
      t.string    :locale
      t.string    :gender
      t.integer   :status,                  default: 0
      t.timestamps
    end

    add_index :user_authentications, [:uuid], unique: true
    add_index :user_authentications, [:uid,:provider]
  end

end
