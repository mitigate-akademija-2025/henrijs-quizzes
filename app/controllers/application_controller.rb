class ApplicationController < ActionController::Base
  helper Heroicon::Engine.helpers
  include Pundit::Authorization
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  before_action :authenticate_user!

  before_action :configure_permitted_parameters, if: :devise_controller?

  rescue_from Pundit::NotAuthorizedError do
    redirect_to(request.referer.presence || root_path, alert: "Not allowed.")
  end

  protected

  def configure_permitted_parameters
    keys = [ :username ]
    devise_parameter_sanitizer.permit(:sign_up, keys: keys)
    devise_parameter_sanitizer.permit(:account_update, keys: keys)
  end
end
