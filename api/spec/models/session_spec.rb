# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Session, type: :model do
  describe '#invite_url' do
    let(:session) { described_class.new(invite_token: 'invite-token') }

    around do |example|
      original_web_base_url = ENV['WEB_BASE_URL']
      original_app_base_url = ENV['APP_BASE_URL']
      example.run
    ensure
      ENV['WEB_BASE_URL'] = original_web_base_url
      ENV['APP_BASE_URL'] = original_app_base_url
    end

    it 'prefers WEB_BASE_URL when present' do
      ENV['WEB_BASE_URL'] = 'https://app.example.com'
      ENV['APP_BASE_URL'] = 'https://api.example.com'

      expect(session.invite_url).to eq('https://app.example.com/interview/invite-token')
    end

    it 'maps local APP_BASE_URL to the local web app port when WEB_BASE_URL is absent' do
      ENV.delete('WEB_BASE_URL')
      ENV['APP_BASE_URL'] = 'http://localhost:3001'

      expect(session.invite_url).to eq('http://localhost:5173/interview/invite-token')
    end
  end
end
