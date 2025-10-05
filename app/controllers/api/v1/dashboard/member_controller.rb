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
              overdue: bb.returned_date.nil? && bb.due_date < Date.current
            }
          end

          render json: { borrowings: data }
        end
      end
    end
  end
end


