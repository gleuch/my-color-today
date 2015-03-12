class CreateWebSitePages < ActiveRecord::Migration

  def change
    create_table :web_site_pages do |t|
      t.integer     :web_site_id
      t.string      :uuid
      t.string      :slug
      t.text        :url
      t.text        :uri_path
      t.integer     :color_avg_red
      t.integer     :color_avg_green
      t.integer     :color_avg_blue
      t.string      :color_avg_hex
      t.integer     :colors_count,    default: 0
      t.integer     :status,          default: 0
      t.string      :color_avg_job_id
      t.timestamps
    end

    add_index :web_site_pages, [:slug], unique: true
    add_index :web_site_pages, [:uuid], unique: true
  end

end
