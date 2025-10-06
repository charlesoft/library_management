class UserRole < ApplicationRecord
  include Indestructible
  has_many :users

  validates :name, presence: true, inclusion: { in: %w[librarian member] }
end
