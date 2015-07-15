Cursor.configure do |config|
  # config.default_per_page = 25
  # config.max_per_page = nil
  # config.page_method_name = :page
  config.before_param_name = :next_id
  config.after_param_name = :prev_id
end


module Cursor
  module PageScopeMethods

    # Number results returned
    def total_results
      @total_results ||= count
    end

    # Total number of results
    def total_entities
      @total_entities ||= limit(nil).count
    end

    # Correction
    def url_parts request_url
      base, params = request_url.split('?', 2)
      params = Rack::Utils.parse_nested_query(params || '')
      params.stringify_keys!
      params.delete('before')
      params.delete('after')
      params.delete(Cursor.config.before_param_name.to_s)
      params.delete(Cursor.config.after_param_name.to_s)
      [base, params]
    end

  end
end