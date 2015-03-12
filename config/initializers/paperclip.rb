# # Disable paperclip logging
# Paperclip.options[:log] = false
# Paperclip.options[:use_exif_orientation] = false
# 
# # S3 Config
# s3_options = YAML.load_file(File.join(Rails.root, 'config', 's3.yml'))[Rails.env].symbolize_keys rescue nil
# if s3_options.present?
#   Paperclip::Attachment.default_options.merge!({
#     use_timestamp:  false,
#     path:           '/:class/:attachment/:id_partition/:style/:filename',
#     storage:        :s3,
#     bucket:         s3_options[:bucket],
#     s3_headers: { 
#       'Expires'       => 3.year.from_now.httpdate,
#       'Cache-Control' => 'max-age=94608000'
#     },
#     s3_credentials: {
#       access_key_id:      s3_options[:access_key_id],
#       secret_access_key:  s3_options[:secret_access_key]
#     }
#   })
# 
#   Paperclip::Attachment.default_options[:url]           = s3_options[:url] unless s3_options[:url].blank? # ':s3_alias_url',
#   Paperclip::Attachment.default_options[:s3_host_alias] = Proc.new {|i,a| s3_options[:s3_host_alias].gsub(/\%d/, (i.original_filename.size.to_i % 4 rescue 0).to_s) } unless s3_options[:s3_host_alias].blank?
# 
#   # Stored to do simple swap-a-roo
#   Paperclip::Attachment.default_options[:s3_http_host_alias]  = Proc.new {|i,a| s3_options[:s3_host_alias].gsub(/\%d/, (i.original_filename.size.to_i % 4 rescue 0).to_s) } unless s3_options[:s3_host_alias].blank?
#   Paperclip::Attachment.default_options[:s3_ssl_host_alias]   = Proc.new {|i,a| s3_options[:s3_ssl_host_alias].gsub(/\%d/, (i.original_filename.size.to_i % 4 rescue 0).to_s) } unless s3_options[:s3_ssl_host_alias].blank?
# end
# 
# 
# require 'paperclip/media_type_spoof_detector'
# 
# module Paperclip
#   class MediaTypeSpoofDetector
#     def spoofed?
#       false
#     end
#   end
# end