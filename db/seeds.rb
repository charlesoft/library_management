# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

puts 'Seeding UserRoles...'
librarian = UserRole.find_or_create_by!(name: 'librarian')
member = UserRole.find_or_create_by!(name: 'member')

puts 'Seeding Users...'
users = [
  { name: 'Alice Admin', email: 'alice@example.com', role: librarian },
  { name: 'Bob Member', email: 'bob@example.com', role: member },
  { name: 'Carol Member', email: 'carol@example.com', role: member },
  { name: 'Dave Member', email: 'dave@example.com', role: member },
  { name: 'Eve Member', email: 'eve@example.com', role: member }
]

users.each do |user|
  User.where(email: user[:email]).first_or_create!(
    name: user[:name],
    password: 'password123',
    password_confirmation: 'password123',
    user_role: user[:role]
  )
end

puts 'Seeding completed.'
