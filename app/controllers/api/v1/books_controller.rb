module Api
  module V1
    class BooksController < ApplicationController
      before_action :authenticate_user!
      before_action :set_book, only: [:show, :update, :destroy]
      before_action :authorize_librarian!, only: [:create, :update, :destroy]

      def index
        books = Book
        
        if params[:q].present?
          books = books.search(params[:q])
        end

        limit = params[:limit].to_i || Book::DEFAULT_LIMIT
        offset = params[:offset].to_i || Book::DEFAULT_OFFSET

        books = books.limit(limit).offset(offset)
        render json: {
          data: books,
          pagination: {
            limit: limit,
            offset: offset,
            count: books.size
          }
        }
      end
      
      def show
        borrowings = BookBorrowing
        
        if current_user.user_role.name == 'member'
          borrowings = @book.book_borrowings.includes(:user).where(user_id: current_user.id)
        elsif current_user.user_role.name == 'librarian'
          borrowings = @book.book_borrowings.includes(:user)
        end
        
      current_user_has_active_borrowing = current_user.present? ?
        borrowings.where(user_id: current_user.id, returned_date: nil).exists? : false
        
        borrowings = borrowings.map do |bb|
          {
            id: bb.id,
            book_id: bb.book_id,
            borrowing_date: bb.borrowing_date,
            due_date: bb.due_date,
            returned_date: bb.returned_date,
            user_name: bb.user&.name
          }
        end

        render json: {
          data: { book: @book, book_borrowings: borrowings, current_user_has_active_borrowing: current_user_has_active_borrowing }
        }
      end

      def create
        book = Book.new(book_params)
        if book.save
          render json: book, status: :created
        else
          render json: { errors: book.errors.full_messages }, status: :unprocessable_content
        end
      end

      def update
        if @book.update(book_params)
          render json: @book, status: :ok
        else
          render json: { errors: @book.errors.full_messages }, status: :unprocessable_content
        end
      end

      def destroy
        @book.delete!
        head :no_content
      end

      private

      def set_book
        @book = Book.find(params[:id])
      end

      def book_params
        params.require(:book).permit(:title, :author, :genre, :isbn, :total_copies)
      end

      def authorize_librarian!
        role = current_user.user_role&.name
        head :forbidden unless role == 'librarian'
      end
    end
  end
end


