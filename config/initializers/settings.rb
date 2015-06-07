begin

  # Explicity define
  Setting.admin_facebook_ids = [
    7002294,    # greg leuch
  ]
  Setting.facebook_app_id = ''

  case Rails.env
    when 'development'
      # Setting.chrome_extension_id = 'mlelncoamdohkknhfdkjfoghlifglkcn'
      Setting.chrome_extension_id = 'pipehoklkfhchfckliliaifabhebjoln'

    else
      Setting.chrome_extension_id = 'nkghbibhhebkddaeebapfkooljjfhnca'
  end

rescue => err
  puts "Settings Initializer Error: #{err}"
  nil
end