class CreateUserAuthentications < ActiveRecord::Migration

  def change
    create_table :user_authentications do |t|
      t.string        :uuid,                                           null: false
      t.integer       :user_id
      t.integer       :provider,                           default: 0, null: false
      t.string        :auth_token
      t.string        :auth_secret
      t.integer       :status,                             default: 0, null: false
      t.timestamps
    end

    add_index :user_authentications, [:user_id]
    add_index :user_authentications, [:uuid], unique: true
  end

end
