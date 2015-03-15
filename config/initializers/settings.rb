begin

  # Explicity define
  Setting.admin_facebook_ids = [
    7002294,    # greg leuch
  ]
  Setting.facebook_app_id = ''

rescue => err
  puts "Settings Initializer Error: #{err}"
  nil
end