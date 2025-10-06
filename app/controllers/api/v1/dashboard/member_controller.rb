module Api
  module V1
    module Dashboard
      class MemberController < ApplicationController
        before_action :authenticate_user!

        def show
        borrowings = BookBorrowing.includes(:book)
          .where(user_id: current_user.id)

        data = borrowings.map do |bb|
          {
            borrowing_id: bb.id,
            book: bb.book,
            due_date: bb.due_date,
            returned_date: bb.returned_date,
            overdue: bb.is_overdue?
          }
        end

        overdue_only = data.select { |row| row[:overdue] }

        render json: { borrowings: data, overdue_borrowings: overdue_only }
        end
      end
    end
  end
end


