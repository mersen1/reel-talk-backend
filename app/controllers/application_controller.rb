# frozen_string_literal: true

class ApplicationController < ActionController::API
  rescue_from ExternalContent::InvalidParameter, with: :render_invalid_parameter
  rescue_from ExternalContent::NotFound, with: :render_not_found
  rescue_from ExternalContent::Unavailable, with: :render_provider_unavailable

  private

  def external_content
    ExternalContent::Gateway.default
  end

  def render_invalid_parameter(error)
    render_error(error.code, error.message, :unprocessable_content, error.details)
  end

  def render_not_found(error)
    render_error(error.code, error.message, :not_found, error.details)
  end

  def render_provider_unavailable(error)
    render_error(error.code, error.message, error.status, error.details)
  end

  def render_error(code, message, status, details = nil)
    error = { code: code, message: message }
    error[:details] = details if details.present?
    render json: { error: error }, status: status
  end
end
