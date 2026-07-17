# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Authentication', type: :request do
  describe 'POST /api/v1/auth/login' do
    let(:user) do
      instance_double(
        User,
        authenticate: true,
        role: 'admin',
        id: 42,
        email: 'admin@example.com'
      )
    end

    before do
      allow(User).to receive(:find_by).with(email: 'admin@example.com').and_return(user)
    end

    it 'returns an error when tenant context is missing' do
      post '/api/v1/auth/login', params: { email: 'admin@example.com', password: 'secret' }

      expect(response).to have_http_status(:unprocessable_entity)
      expect(response.parsed_body).to eq(
        'errors' => [{ 'status' => 422, 'message' => 'Tenant context is required' }]
      )
    end

    it 'encodes the canonical organization scheme in the token' do
      organization = instance_double(Organization, id: 7, scheme: 'tenant-scheme', default?: false)
      allow(Organization).to receive(:identify).with('Demo Tenant').and_return(organization)

      post '/api/v1/auth/login',
           params: { email: 'admin@example.com', password: 'secret' },
           headers: { 'X-Tenant-Scheme' => 'Demo Tenant' }

      expect(response).to have_http_status(:ok)

      claims = JsonWebToken.decode(response.parsed_body.fetch('token'))
      expect(claims['scheme']).to eq('tenant-scheme')
    end
  end
end
