puts "📃 Seeding data..."

5.times do
  user = User.create(username: Faker::GreekPhilosophers.name.downcase.gsub(/\W/, '_'))

  rand(3..5).times do
    user.articles.create(
      title: Faker::Lorem.sentence, 
      content: Faker::Markdown.sandwich(sentences: rand(3..6), repeat: rand(2..5)),
      minutes_to_read: rand(3..50)
    )
  end
end

puts "✅ Done seeding"
