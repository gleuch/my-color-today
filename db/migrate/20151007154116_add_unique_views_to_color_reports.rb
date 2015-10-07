class AddUniqueViewsToColorReports < ActiveRecord::Migration

  def change
    add_column :color_reports, :unique_views_count, :integer, default: 0, after: :views_count
  end

end
