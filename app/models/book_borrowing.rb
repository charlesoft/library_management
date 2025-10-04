class BookBorrowing < ApplicationRecord
  belongs_to :book
  belongs_to :user

  validates :borrowing_date, presence: true
  validates :due_date, presence: true
end
