module Api
  module V1
    class RegistrationsController < Devise::RegistrationsController
      respond_to :json

      def create
        build_resource(sign_up_params)
        resource.user_role = UserRole.find_by(name: 'member')

        if resource.save
          sign_up(resource_name, resource)
          render json: { user: resource, message: 'Signed up successfully' }, status: :created
        else
          render json: { errors: resource.errors.full_messages }, status: :unprocessable_content
        end
      end

      private

      def sign_up_params
        params.require(:user).permit(:name, :email, :password, :password_confirmation)
      end
    end
  end
end
