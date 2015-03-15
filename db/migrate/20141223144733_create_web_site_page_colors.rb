class CreateWebSitePageColors < ActiveRecord::Migration

  def change
    create_table :web_site_page_colors do |t|
      t.integer     :web_site_page_id
      t.string      :uuid
      t.integer     :user_id
      t.integer     :color_red
      t.integer     :color_green
      t.integer     :color_blue
      t.string      :color_hex,               length: 6
      t.datetime    :created_at
    end

    add_index :web_site_page_colors, [:uuid], unique: true
    add_index :web_site_page_colors, [:user_id]
  end

end
