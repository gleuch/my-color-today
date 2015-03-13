class CreateUsers < ActiveRecord::Migration

  def change
    create_table :users do |t|
      t.string      :uuid,                                             null: false
      t.string      :slug
      t.string      :name,                                             null: false
      t.string      :email
      t.string      :login,                                            null: false
      t.string      :avatar_file_name
      t.string      :avatar_content_type
      t.integer     :avatar_file_size,    default: 0
      t.datetime    :avatar_updated_at
      t.string      :crypted_password
      t.string      :password_salt
      t.string      :persistence_token,                                null: false
      t.string      :perishable_token,                                 null: false
      t.string      :single_access_token,                              null: false
      t.integer     :login_count,                          default: 0, null: false
      t.integer     :failed_login_count,                   default: 0, null: false
      t.datetime    :last_request_at
      t.datetime    :current_login_at
      t.datetime    :last_login_at
      t.string      :current_login_ip
      t.string      :last_login_ip
      t.string      :signup_method
      t.integer     :roles_mask
      t.timestamps
    end

    add_index :users, [:uuid], unique: true
    add_index :users, [:slug], unique: true
    add_index :users, [:login], unique: true
    add_index :users, [:email], unique: true
    add_index :users, [:last_request_at]
    add_index :users, [:perishable_token]
    add_index :users, [:persistence_token]
    add_index :users, [:single_access_token]
  end

end