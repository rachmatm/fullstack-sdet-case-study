# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Portfolios::Generator do
  describe '#call' do
    let!(:organization) do
      Organization.find_or_create_by!(scheme: 'portfolio-corp') do |org|
        org.name = 'Portfolio Corp'
        org.identifier = 'portfolio-corp'
        org.host = 'portfolio-corp.local'
      end
    end

    let!(:assessment) do
      Assessment.create!(
        tenant_id: organization.id,
        created_by: 12,
        name: 'Platform Engineer',
        time_limit_min: 30
      )
    end

    let!(:assessment_skill) do
      assessment.assessment_skills.create!(
        skill_id: 'platform-design',
        skill_label: 'Platform Design',
        scope_include: 'Designing resilient backend systems',
        l1_anchor: 'Needs close guidance',
        l2_anchor: 'Handles routine system design',
        l3_anchor: 'Handles complex design tradeoffs',
        l4_anchor: 'Defines platform patterns',
        l5_anchor: 'Sets org-level standards',
        display_order: 1,
        expected_level: 3
      )
    end

    let!(:session) do
      Session.create!(
        assessment: assessment,
        tenant_id: organization.id,
        candidate_id: 123,
        candidate_name: 'Casey Candidate',
        status: 'ended'
      )
    end

    let!(:coverage_map) do
      session.coverage_maps.create!(
        skill_id: 'platform-design',
        skill_label: 'Platform Design',
        is_discovered: false,
        state: 'covered',
        probe_count: 3
      )
    end

    let!(:transcript_turn) do
      session.transcript_turns.create!(
        turn_number: 1,
        speaker: 'candidate',
        text: 'I built a fault-tolerant job pipeline with retries and backpressure.'
      )
    end

    let!(:portfolio) do
      session.create_portfolio!(
        candidate_id: session.candidate_id,
        generation_status: 'complete',
        generated_at: Time.current
      )
    end

    let!(:existing_skill) do
      portfolio.portfolio_skills.create!(
        skill_id: 'existing-skill',
        skill_label: 'Existing Skill',
        is_discovered: false,
        ai_level: 3,
        ai_confidence: 'high',
        evidence: ['Existing quote'],
        competency_summary: 'Existing stable portfolio entry.'
      )
    end

    subject(:generator) { described_class.new(session: session, gemini_client: gemini_client) }

    context 'when Gemini returns an invalid payload' do
      let(:gemini_client) do
        instance_double(
          Gemini::HttpClient,
          generate_content: {
            'configured_skills' => [
              {
                'skill_id' => 'platform-design',
                'level' => 4
              }
            ],
            'discovered_skills' => []
          }
        )
      end

      it 'marks generation failed without deleting the previous portfolio skills' do
        expect { generator.call }.to raise_error(ActiveRecord::RecordInvalid)

        expect(portfolio.reload.generation_status).to eq('failed')
        expect(portfolio.generation_error).to include("Skill label can't be blank")
        expect(portfolio.portfolio_skills.pluck(:skill_label)).to eq(['Existing Skill'])
      end
    end

    context 'when Gemini returns a valid payload' do
      let(:gemini_client) do
        instance_double(
          Gemini::HttpClient,
          generate_content: {
            'configured_skills' => [
              {
                'skill_id' => 'platform-design',
                'skill_label' => 'Platform Design',
                'level' => 4,
                'confidence' => 'high',
                'evidence' => ['Designed retries for worker failures'],
                'competency_summary' => 'Shows strong judgment under failure scenarios.'
              }
            ],
            'discovered_skills' => []
          }
        )
      end

      it 'replaces the portfolio atomically with the new generated skills' do
        result = generator.call

        expect(result).to eq(portfolio.reload)
        expect(portfolio.generation_status).to eq('complete')
        expect(portfolio.portfolio_skills.pluck(:skill_label)).to eq(['Platform Design'])
      end
    end
  end
end
