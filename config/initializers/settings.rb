begin

  # Explicity define
  Setting.admin_facebook_ids = [
    7002294,    # greg leuch
  ]
  Setting.facebook_app_id = '980253892031099'
  Setting.google_analytics = 'UA-000000001-0'

  case Rails.env
    when 'development'
      # Setting.chrome_extension_id = 'mlelncoamdohkknhfdkjfoghlifglkcn'
      Setting.chrome_extension_id = 'pipehoklkfhchfckliliaifabhebjoln'
      Setting.facebook_app_id = '980257832030705'

    else
      Setting.chrome_extension_id = 'nkghbibhhebkddaeebapfkooljjfhnca'
      Setting.google_analytics = 'UA-2855868-26'
  end

rescue => err
  puts "Settings Initializer Error: #{err}"
  nil
end
