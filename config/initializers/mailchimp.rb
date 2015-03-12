# if Rails.env.test?
#   Gibbon::Export.api_key = "fake"
#   Gibbon::Export.throws_exceptions = false
# end
# 
# mailchimp_options = YAML.load_file(File.join(Rails.root, 'config', 'mailchimp.yml'))[::Rails.env] rescue nil
# 
# if mailchimp_options.present?
#   ENV['MAILCHIMP_API_KEY'] = mailchimp_options['api_key']
#   ENV['MAILCHIMP_LIST_ID'] = mailchimp_options['list_id']
#   
#   Gibbon::API.api_key = ENV['MAILCHIMP_API_KEY']
#   Gibbon::API.timeout = 15
#   Gibbon::API.throws_exceptions = false
# 
#   Rails.configuration.mailchimp = Gibbon::API.new
# end