(0..1000).each do |i|
  WebSitePageColor.add( Faker::Internet.uri('https'), {red: rand(255), green: rand(255), blue: rand(255)})
  sleep 0.5
end
