class AddPaletteColorToWebSitePageColors < ActiveRecord::Migration

  def change
    add_column :web_site_page_colors, :palette_red, :integer, after: :color_red
    add_column :web_site_page_colors, :palette_green, :integer, after: :palette_red
    add_column :web_site_page_colors, :palette_blue, :integer, after: :palette_green
    add_column :web_site_page_colors, :palette_hex, :string, after: :palette_blue
  end

end
