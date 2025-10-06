class Book < ApplicationRecord
  include Indestructible
  has_many :book_borrowings

  validates :title, presence: true
  validates :author, presence: true
  validates :genre, presence: true
  validates :isbn, presence: true, uniqueness: true
  validates :total_copies, numericality: { greater_than_or_equal_to: 0 }
  
  DEFAULT_LIMIT = 20
  DEFAULT_OFFSET = 0
  
  default_scope { order(created_at: :desc) }
  
  scope :search, ->(query) { where("title ILIKE :query OR author ILIKE :query OR genre ILIKE :query", query: "%#{query}%") }

  def available_copies
    total_copies - book_borrowings.where(returned_date: nil).count
  end

  def available?
    self[:available] && available_copies > 0
  end
end
