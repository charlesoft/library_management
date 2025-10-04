class Book < ApplicationRecord
  has_many :book_borrowings, dependent: :restrict_with_exception

  validates :title, presence: true
  validates :author, presence: true
  validates :genre, presence: true
  validates :isbn, presence: true, uniqueness: true
  validates :total_copies, numericality: { greater_than_or_equal_to: 0 }
  
  default_scope { order(created_at: :desc) }
  
  scope :search, ->(query) { where("title ILIKE :query OR author ILIKE :query OR genre ILIKE :query", query: "%#{query}%") }
end
