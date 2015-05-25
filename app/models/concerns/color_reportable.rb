module ColorReportable
  extend ActiveSupport::Concern

  included do
    has_many :reports, class_name: 'ColorReport', as: :item
  end


  def report(d, *args)
    opts = args.extract_options!
    info = reports.on(d || :overall).get
    info.recalculate! if opts[:recalculate]
    {count: info.views_count, rgb: info.color_rgb, hex: info.color_hex, palette: info.palette}
  end


end