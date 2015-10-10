begin

  # Explicity define
  Setting.admin_facebook_ids = [
    7002294,    # greg leuch
  ]
  Rails.configuration.facebook_app_id = '980253892031099'


  case Rails.env
    when 'development'
      # Setting.chrome_extension_id = 'mlelncoamdohkknhfdkjfoghlifglkcn'
      Setting.chrome_extension_id = 'pipehoklkfhchfckliliaifabhebjoln'
      Rails.configuration.facebook_app_id = '980257832030705'

    else
      Setting.chrome_extension_id = 'nkghbibhhebkddaeebapfkooljjfhnca'
  end

rescue => err
  puts "Settings Initializer Error: #{err}"
  nil
end
