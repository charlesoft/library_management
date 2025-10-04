class UserRole < ApplicationRecord
  has_many :users, dependent: :restrict_with_exception

  validates :name, presence: true, inclusion: { in: %w[librarian member] }
end
