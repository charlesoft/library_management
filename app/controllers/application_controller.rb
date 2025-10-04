class ApplicationController < ActionController::API
  include ActionController::MimeResponds
  include Devise::Controllers::Helpers

  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name, :user_role_id])
  end

  # Unified authentication supporting both controller specs (Devise sign_in)
  # and request specs (JWT Authorization header)
  def authenticate_user!
    if defined?(warden) && warden&.user
      return true
    end

    token = request.headers['Authorization']&.to_s
    if token&.start_with?('Bearer ')
      jwt = token.split(' ').last
      begin
        payload = Warden::JWTAuth::TokenDecoder.new.call(jwt)
        @current_user = User.find_by(id: payload['sub'])
        return true if @current_user
      rescue StandardError
        # fall through to unauthorized
      end
    end

    render json: { message: 'Unauthorized' }, status: :unauthorized
  end

  def current_user
    return warden.user if defined?(warden) && warden&.user
    @current_user
  end
end
