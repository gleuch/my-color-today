class CreateApiTokens < ActiveRecord::Migration
  def change
    create_table :api_tokens do |t|
      t.integer     :user_id
      t.string      :token_key
      t.string      :token_secret
      t.datetime    :expires_at
      t.integer     :status,            default: 0
      t.timestamps
    end

    add_index :api_tokens, [:token_key], unique: true
  end
end
