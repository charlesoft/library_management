module Api
  module V1
    module Dashboard
      class LibrarianController < ApplicationController
        before_action :authenticate_user!
        before_action :authorize_librarian!

        def show
          borrowings = BookBorrowing.includes(:book)
          .where(user_id: current_user.id)

          data = borrowings.map do |bb|
            {
              borrowing_id: bb.id,
              book: bb.book,
              due_date: bb.due_date,
              returned_date: bb.returned_date,
              overdue: bb.returned_date.nil? && bb.due_date < Date.current
            }
          end
          
          total_books = Book.all.sum(:total_copies)
          total_borrowed = BookBorrowing.where(returned_date: nil).count

          due_today_borrowings = BookBorrowing
            .includes(:user, :book)
            .where(due_date: Date.current, returned_date: nil)

          books_due_today = due_today_borrowings
            .map { |bb| { book: bb.book, borrowing: { id: bb.id, user: bb.user, due_date: bb.due_date } } }

        overdue_borrowings = BookBorrowing
          .includes(:user, :book)
          .where('due_date < ?', Date.current)
          .where("returned_date IS NULL OR returned_date > due_date")

        overdue_members = overdue_borrowings
          .group_by(&:user)
          .map do |user, bbs|
            {
              user: { id: user.id, name: user.name, email: user.email },
              count: bbs.size,
              books: bbs.map { |bb| { book: { id: bb.book.id, title: bb.book.title }, due_date: bb.due_date, returned_date: bb.returned_date } }
            }
          end

          render json: {
            total_books: total_books,
            total_borrowed: total_borrowed,
            books_due_today: books_due_today,
            overdue_members: overdue_members,
            borrowings: data
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


