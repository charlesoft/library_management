class BookBorrowing < ApplicationRecord
  include Indestructible
  belongs_to :book
  belongs_to :user

  validates :borrowing_date, presence: true
  validates :due_date, presence: true

  validate :borrowing_before_due
  validate :book_must_be_available, on: :create
  validate :user_cannot_borrow_same_book_twice, on: :create

  after_create :decrement_book_availability
  after_update :update_book_availability_if_returned
  
  
  def self.by_user(user)
    if user.user_role.name == 'member'
      includes(:user).where(user_id: user.id)
    elsif user.user_role.name == 'librarian'
      includes(:user)
    end
  end

  private

  def borrowing_before_due
    return if borrowing_date.blank? || due_date.blank?
    errors.add(:due_date, 'must be after borrowing date') if due_date <= borrowing_date
  end

  def book_must_be_available
    errors.add(:book, 'is not available') unless book&.available?
  end

  def user_cannot_borrow_same_book_twice
    return unless self.book.present? && self.user.present? && self.user.user_role.name == 'member'
    active = BookBorrowing.where(book_id: book.id, user_id: user.id, returned_date: nil).exists?
    errors.add(:base, 'already borrowed this book') if active
  end

  def decrement_book_availability
    if book.available_copies <= 0
      self.book.update!(available: false)
    else
      # If there are copies, recompute availability after borrowing
      self.book.update!(available: self.book.available_copies > 0)
    end
  end

  def update_book_availability_if_returned
    if saved_change_to_returned_date? && returned_date.present?
      self.book.update!(available: self.book.available_copies > 0)
    end
  end
end
