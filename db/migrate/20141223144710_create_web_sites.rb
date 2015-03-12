class CreateWebSites < ActiveRecord::Migration

  def change
    create_table :web_sites do |t|
      t.string      :uuid
      t.string      :slug
      t.string      :uri_domain_tld
      t.text        :url
      t.integer     :pages_count,     default: 0
      t.integer     :status,          default: 0
      t.timestamps
    end

    add_index :web_sites, [:slug], unique: true
    add_index :web_sites, [:uuid], unique: true

  end

end
