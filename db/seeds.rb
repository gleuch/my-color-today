user = User.first

(0..100).each do |i|
  WebSitePageColor.add( Faker::Internet.uri('https'), {red: rand(255), green: rand(255), blue: rand(255)}, user)
end
