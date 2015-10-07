module ColorReportable
  extend ActiveSupport::Concern

  included do
    has_many :reports, class_name: 'ColorReport', as: :item
  end


  def report(d, *args)
    opts = args.extract_options!
    info = reports.on(d || :overall, date: opts[:date]).get
    info.recalculate! if opts[:recalculate]
    info.to_api
  end


end