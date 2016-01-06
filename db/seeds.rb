# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

# users
10.times do |n|
  email = "user-#{n}@example.com"
  password = "password"
  User.create!(email: email,
               password:              password,
               password_confirmation: password)
end

# products
users = User.all
5.times do
  users.each do |user|
    title = FFaker::Product.product_name
    price = rand() * 100
    published = true
    user.products.create!(title:      title,
                          price:      price,
                          published:  published)
  end
end
