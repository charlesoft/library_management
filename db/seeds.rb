# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

puts 'Creating UserRoles...'
librarian = UserRole.find_or_create_by!(name: 'librarian')
member = UserRole.find_or_create_by!(name: 'member')

puts 'Creating Users...'
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

puts 'Creating Books...'
authors = [
  'Haruki Murakami', 'Ursula K. Le Guin', 'Octavia E. Butler', 'Neil Gaiman',
  'Toni Morrison', 'George Orwell', 'Agatha Christie', 'Isabel Allende'
]
genres = [
  'Fiction', 'Fantasy', 'Science Fiction', 'Mystery', 'Historical', 'Non-Fiction'
]

fixed_copies = 30

20.times do |i|
  index = i + 1
  
  isbn ='ISBN-001'+index.to_s
  title = "Sample Book #{index}"
  book = Book.where(isbn: isbn).first_or_initialize
  book.title = title
  book.author = authors[rand(0..authors.length - 1)]
  book.genre = genres[rand(0..genres.length - 1)]
  book.total_copies = fixed_copies
  book.available = true
  book.save!
end

puts 'Creating Book Borrowings...'
members = User.joins(:user_role).where(user_roles: { name: 'member' })

books = Book.all

books.each do |book|
  members.each do |member|
    if book.available?
      BookBorrowing.create!(
        book: book,
        user: member,
        borrowing_date: Date.today - rand(0..31).days,
        due_date: Date.today + rand(1..31).days
      ) 
    end
  end
end

puts 'Seeding completed.'
