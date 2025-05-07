class ApplicationController < ActionController::API
  rescue_from StandardError, with: :handle_error

  def handle_error(error)
    logger.error(error.message)
    logger.error(error.backtrace.join("\n"))

    render json: { error: error.message }, status: :internal_server_error
  end
end
