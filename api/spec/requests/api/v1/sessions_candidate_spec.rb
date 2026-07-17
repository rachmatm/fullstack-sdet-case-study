# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Candidate session access', type: :request do
  describe 'GET /api/v1/sessions/:token/candidate' do
    let!(:organization) do
      Organization.find_or_create_by!(scheme: 'candidate-corp') do |org|
        org.name = 'Candidate Corp'
        org.identifier = 'candidate-corp'
        org.host = 'candidate-corp.local'
      end
    end

    let!(:assessment) do
      Assessment.create!(
        tenant_id: organization.id,
        created_by: 7,
        name: 'Frontend Engineer',
        time_limit_min: 45
      )
    end

    let!(:session) do
      Session.create!(
        assessment: assessment,
        tenant_id: organization.id,
        candidate_name: 'Morgan Candidate'
      )
    end

    after do
      Current.clear
    end

    it 'returns candidate info for a valid invite token' do
      get "/api/v1/sessions/#{session.invite_token}/candidate"

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body).to eq(
        'session_id' => session.id,
        'role_title' => assessment.name,
        'time_limit_min' => assessment.time_limit_min,
        'session_status' => session.status
      )
    end

    it 'returns not found for an invalid invite token' do
      get '/api/v1/sessions/not-a-real-token/candidate'

      expect(response).to have_http_status(:not_found)
      expect(response.parsed_body).to eq(
        'errors' => [{ 'status' => 404, 'message' => 'Invalid or expired invite token' }]
      )
    end

    it 'returns not found when the assessment cannot be resolved for the session tenant' do
      session.update_column(:tenant_id, organization.id + 999)

      get "/api/v1/sessions/#{session.invite_token}/candidate"

      expect(response).to have_http_status(:not_found)
      expect(response.parsed_body).to eq(
        'errors' => [{ 'status' => 404, 'message' => 'Assessment not found' }]
      )
    end
  end
end
