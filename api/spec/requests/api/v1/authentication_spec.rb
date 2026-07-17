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

    it 'falls back to the first organization scheme when tenant context is missing' do
      allow(ActiveRecord::Base.connection).to receive(:select_value)
        .with('SELECT scheme FROM organizations LIMIT 1')
        .and_return('fallback-scheme')

      post '/api/v1/auth/login', params: { email: 'admin@example.com', password: 'secret' }

      expect(response).to have_http_status(:ok)

      claims = JsonWebToken.decode(response.parsed_body.fetch('token'))
      expect(claims['scheme']).to eq('fallback-scheme')
    end

    it 'uses the provided tenant context when present' do
      expect(ActiveRecord::Base.connection).not_to receive(:select_value)
        .with('SELECT scheme FROM organizations LIMIT 1')

      post '/api/v1/auth/login',
           params: { email: 'admin@example.com', password: 'secret' },
           headers: { 'X-Tenant-Scheme' => 'demo-tenant' }

      expect(response).to have_http_status(:ok)

      claims = JsonWebToken.decode(response.parsed_body.fetch('token'))
      expect(claims['scheme']).to eq('demo-tenant')
    end

    it 'falls back to test-corp when no tenant context or organization scheme exists' do
      allow(ActiveRecord::Base.connection).to receive(:select_value)
        .with('SELECT scheme FROM organizations LIMIT 1')
        .and_return(nil)

      post '/api/v1/auth/login', params: { email: 'admin@example.com', password: 'secret' }

      expect(response).to have_http_status(:ok)

      claims = JsonWebToken.decode(response.parsed_body.fetch('token'))
      expect(claims['scheme']).to eq('test-corp')
    end
  end
end
