# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Session creation', type: :request do
  describe 'POST /api/v1/assessments/:assessment_id/sessions' do
    let!(:organization) do
      Organization.find_or_create_by!(scheme: 'test-corp') do |org|
        org.name = 'Test Corp'
        org.identifier = 'test-corp'
        org.host = 'test-corp.local'
      end
    end

    let!(:assessment) do
      Assessment.create!(
        tenant_id: organization.id,
        created_by: 42,
        name: 'Backend Engineer',
        time_limit_min: 30
      )
    end

    let(:auth_token) do
      JsonWebToken.encode(user_id: 42, role: 'admin', scheme: organization.scheme)
    end

    let(:headers) do
      {
        'Authorization' => "Bearer #{auth_token}"
      }
    end

    after do
      Current.clear
    end

    it 'creates a session and returns a usable invite URL' do
      post "/api/v1/assessments/#{assessment.id}/sessions",
           params: {
             session: {
               candidate_id: 123,
               candidate_name: 'Casey Candidate'
             }
           },
           headers: headers

      expect(response).to have_http_status(:created)

      body = response.parsed_body
      expect(body.dig('session', 'assessment_id')).to eq(assessment.id)
      expect(body.dig('session', 'tenant_id')).to eq(organization.id)
      expect(body.dig('session', 'candidate_id')).to eq(123)
      expect(body.dig('session', 'candidate_name')).to eq('Casey Candidate')
      expect(body.fetch('invite_url')).to eq(body.dig('session', 'invite_url'))
      expect(body.fetch('invite_url')).to match(%r{\Ahttp://localhost:5173/interview/.+})
    end

    it 'returns not found when the assessment does not exist' do
      post '/api/v1/assessments/999999/sessions',
           params: { session: { candidate_name: 'Missing Assessment' } },
           headers: headers

      expect(response).to have_http_status(:not_found)
      expect(response.parsed_body).to eq(
        'errors' => [{ 'status' => 404, 'message' => 'Assessment not found' }]
      )
    end
  end
end
