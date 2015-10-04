class AddActiveBooleanToWebSitePageColors < ActiveRecord::Migration

  def change
    add_column :web_site_page_colors, :active, :boolean, default: true, after: :api_token_id
  end

end
