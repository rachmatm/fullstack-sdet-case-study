# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Gemini::HttpClient do
  describe '#generate_content' do
    it 'joins multipart Gemini responses before parsing JSON' do
      response_body = {
        candidates: [
          {
            content: {
              parts: [
                { text: '{"culture_narrative":"Strong collaboration",' },
                { text: '"overall_narrative":"Recommended hire"}' }
              ]
            }
          }
        ]
      }.to_json

      response = instance_double(Faraday::Response, success?: true, body: response_body)
      connection = instance_double(Faraday::Connection, post: response)

      client = described_class.new(model: 'gemini-test', api_key: 'test-key')
      client.instance_variable_set(:@connection, connection)

      result = client.generate_content('prompt')

      expect(result).to eq(
        'culture_narrative' => 'Strong collaboration',
        'overall_narrative' => 'Recommended hire'
      )
    end
  end
end
