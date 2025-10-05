module Api
  module V1
    class BookBorrowingsController < ApplicationController
      before_action :authenticate_user!
      before_action :set_book, only: [:create]
      before_action :set_borrowing, only: [:return_book]
      before_action :authorize_librarian!, only: [:return_book]

      # POST /api/v1/books/:book_id/borrow
      def create
        borrowing = BookBorrowing.new(
          book: @book,
          user: current_user,
          borrowing_date: Date.current,
          due_date: borrowing_params[:due_date]
        )
        if borrowing.save
          render json: borrowing, status: :created
        else
          render json: { errors: borrowing.errors.full_messages }, status: :unprocessable_content
        end
      end

      # PATCH /api/v1/book_borrowings/:id/return
      def return_book  
        if @borrowing.update(returned_date: Date.current)
          render json: @borrowing, status: :ok
        else
          render json: { errors: @borrowing.errors.full_messages }, status: :unprocessable_content
        end
      end

      private
      
      def borrowing_params
        params.require(:book_borrowing).permit(:due_date)
      end

      def set_book
        @book = Book.find(params[:book_id])
      end

      def set_borrowing
        @borrowing = BookBorrowing.find(params[:id])
      end

      def authorize_librarian!
        role = current_user.user_role&.name
        head :forbidden unless role == 'librarian'
      end
    end
  end
end


