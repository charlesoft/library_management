module Api
  module V1
    class BooksController < ApplicationController
      before_action :authenticate_user!
      before_action :set_book, only: [:show, :update, :destroy]
      def show
        render json: @book
      end
      before_action :authorize_librarian!, only: [:create, :update, :destroy]

      def index
        books = Book
        
        if params[:q].present?
          books = books.search(params[:q])
        end

        limit = params[:limit].to_i
        offset = params[:offset].to_i
        limit = 20 if limit <= 0 || limit > 100
        offset = 0 if offset < 0

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
        render json: @book
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


