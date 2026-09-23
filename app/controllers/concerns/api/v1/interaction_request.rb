# frozen_string_literal: true

module Api
  module V1
    module InteractionRequest
      private

      def device_id
        value = request.headers["X-Device-Id"].to_s
        if value.match?(/\A[0-9a-f]{8}-(?:[0-9a-f]{4}-){3}[0-9a-f]{12}\z/i)
          GuestUser.find_or_create_by!(device_id: value)
          return value
        end

        render_error("invalid_device_id", "X-Device-Id must be a UUID", :bad_request)
        nil
      end

      def title_key
        type = params[:media_type]
        id = params[:id].to_s
        return [type, id.to_i] if %w[tv movie].include?(type) && id.match?(/\A[1-9]\d*\z/)

        render_error("invalid_title", "Invalid title identifier", :unprocessable_content)
        nil
      end

      def invalid_record(record)
        render_error("invalid_parameter", record.errors.full_messages.join(", "), :unprocessable_content)
      end
    end
  end
end
