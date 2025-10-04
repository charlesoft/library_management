module Api
  module V1
    class SessionsController < Devise::SessionsController
      respond_to :json

      def create
        email = permitted_params[:email]
        password = permitted_params[:password]
        user = User.find_for_database_authentication(email: email)
        
        if user.present? && user.valid_password?(password)
          sign_in(resource_name, user)
          render json: { user: user, message: 'Logged in successfully' }, status: :ok
        else
          render json: { message: 'Invalid Email or password' }, status: :unauthorized
        end 
      end

      private
      
      def permitted_params
        params.require(:user).permit(:email, :password)
      end

      def respond_to_on_destroy
        if request.headers['Authorization'].present?
          render json: { message: 'Logged out successfully' }, status: :ok
        else
          render json: { message: 'No active session' }, status: :unauthorized
        end
      end
    end
  end
end
