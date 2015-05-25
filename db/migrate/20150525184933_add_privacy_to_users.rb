class AddPrivacyToUsers < ActiveRecord::Migration

  def change
    add_column :users, :profile_private, :boolean, default: false, after: :roles_mask
  end

end
