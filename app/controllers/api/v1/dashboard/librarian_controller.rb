module Api
  module V1
    module Dashboard
      class LibrarianController < ApplicationController
        before_action :authenticate_user!
        before_action :authorize_librarian!

        def show
          total_books = Book.count
          total_borrowed = BookBorrowing.where(returned_date: nil).count

          due_today_borrowings = BookBorrowing
            .includes(:user, :book)
            .where(due_date: Date.current, returned_date: nil)

          books_due_today = due_today_borrowings
            .map { |bb| { book: bb.book, borrowing: { id: bb.id, user: bb.user, due_date: bb.due_date } } }

          render json: {
            total_books: total_books,
            total_borrowed: total_borrowed,
            books_due_today: books_due_today
          }
        end

        private

        def authorize_librarian!
          head :forbidden unless current_user.user_role&.name == 'librarian'
        end
      end
    end
  end
end


