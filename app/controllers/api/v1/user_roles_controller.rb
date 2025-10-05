module Api
  module V1
    class UserRolesController < ApplicationController
      # Public endpoint to allow signup forms to fetch role ids
      def index
        render json: UserRole.select(:id, :name).order(:name)
      end
    end
  end
end


