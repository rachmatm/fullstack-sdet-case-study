# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Candidate audio completion', type: :request do
  describe 'POST /api/v1/sessions/:token/audio_complete' do
    let!(:organization) do
      Organization.find_or_create_by!(scheme: 'audio-corp') do |org|
        org.name = 'Audio Corp'
        org.identifier = 'audio-corp'
        org.host = 'audio-corp.local'
      end
    end

    let!(:assessment) do
      Assessment.create!(
        tenant_id: organization.id,
        created_by: 9,
        name: 'SDET',
        time_limit_min: 30
      )
    end

    let!(:session) do
      Session.create!(
        assessment: assessment,
        tenant_id: organization.id,
        status: 'active',
        started_at: 5.minutes.ago
      )
    end

    after do
      Current.clear
    end

    it 'ends the session for a valid invite token' do
      handler = instance_double(Sessions::EndHandler, call: session)
      allow(Sessions::EndHandler).to receive(:new).with(session).and_return(handler)

      post "/api/v1/sessions/#{session.invite_token}/audio_complete"

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body).to eq(
        'ended' => true,
        'message' => 'Session ended'
      )
      expect(handler).to have_received(:call).with(reason: 'all_covered')
    end

    it 'is idempotent when the session is already ended' do
      session.update!(status: 'ended', end_reason: 'manual_assessor', ended_at: Time.current)

      post "/api/v1/sessions/#{session.invite_token}/audio_complete"

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body).to eq(
        'ended' => true,
        'message' => 'Session already ended'
      )
    end

    it 'returns not found for an invalid invite token' do
      post '/api/v1/sessions/not-a-real-token/audio_complete'

      expect(response).to have_http_status(:not_found)
      expect(response.parsed_body).to eq(
        'errors' => [{ 'status' => 404, 'message' => 'Invalid or expired invite token' }]
      )
    end
  end
end
