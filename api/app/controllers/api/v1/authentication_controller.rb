# frozen_string_literal: true

module Api
  module V1
    class AuthenticationController < ApiController
      skip_before_action :require_tenant!

      # POST /api/v1/auth/login
      def authenticate
        user = User.find_by(email: params[:email].to_s.downcase)

        return json_error('Invalid email or password', :unauthorized) unless user&.authenticate(params[:password])

        return json_error('Invalid email or password', :unauthorized) unless user.role == 'admin'

        scheme = resolve_scheme
        return json_error('Tenant context is required', :unprocessable_entity) if scheme.blank?

        token  = JsonWebToken.encode({ user_id: user.id, role: user.role, scheme: })

        json_response({ token:, user: { id: user.id, email: user.email, role: user.role } })
      end

      private

      def resolve_scheme
        identifier = request.headers['X-Tenant-Scheme'].presence || referer_host
        return if identifier.blank?

        organization = Organization.identify(identifier)
        return if organization.blank? || organization.default?

        organization.scheme
      end

      def referer_host
        referer = request.referer.to_s
        return if referer.blank?

        URI.parse(referer).host.presence
      rescue URI::InvalidURIError
        nil
      end
    end
  end
end
