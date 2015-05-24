class CreateColorReports < ActiveRecord::Migration

  def change
    create_table :color_reports do |t|
      t.string    :uuid
      t.integer   :item_id
      t.string    :item_type
      t.integer   :date_range,        default: 0
      t.string    :date_range_value
      t.string    :query_value
      t.integer   :color_red
      t.integer   :color_green
      t.integer   :color_blue
      t.boolean   :palette,           default: false
      t.timestamps                    null: false
    end

    add_index :color_reports, [:uuid], unique: true
    add_index :color_reports, [:item_id, :item_type, :date_range]
  end

end
