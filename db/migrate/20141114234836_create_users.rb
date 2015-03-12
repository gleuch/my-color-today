class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string      :uuid,                                             null: false
      t.string      :first_name,                                       null: false
      t.string      :last_name,                                        null: false
      t.string      :email
      t.string      :login,                                            null: false
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
      t.integer     :roles_mask
      t.timestamps
    end

    add_index :users, [:last_request_at]
    add_index :users, [:perishable_token]
    add_index :users, [:persistence_token]
    add_index :users, [:single_access_token]
    add_index :users, [:uuid], unique: true
  end
end