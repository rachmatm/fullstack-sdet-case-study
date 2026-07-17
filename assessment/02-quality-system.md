# 02 Quality System

Status: Updated on July 17, 2026 after the first implementation pass.

## Objective

Build a small, credible quality system that does three things:

- block pull requests that are missing required delivery inputs
- catch a few high-risk regressions automatically
- produce an honest release verdict from evidence

This quality system is intentionally small. The repository did not start with a committed CI workflow, a visible workflow gate, or a committed automated regression net, so the first goal was to establish a trustworthy baseline rather than design a large system on paper.

## What Is Implemented Now

The first working version of the quality system is now in the repository.

Implemented components:

- PR template in `.github/PULL_REQUEST_TEMPLATE.md`
- PR body validation script in `scripts/check-pr-body.sh`
- CI workflow in `.github/workflows/quality-gate.yml`
- backend regression specs in `api/spec/requests/api/v1/authentication_spec.rb`
- backend regression specs in `api/spec/requests/api/v1/sessions_create_spec.rb`
- backend regression specs in `api/spec/requests/api/v1/sessions_candidate_spec.rb`
- backend regression specs in `api/spec/requests/api/v1/sessions_audio_complete_spec.rb`
- backend regression specs in `api/spec/models/session_spec.rb`
- request-spec host fix in `api/spec/rails_helper.rb`
- tag-based release verdict script in `scripts/release-verdict.sh`
- draft release notes in `RELEASE_NOTES.md`

Local verification in this pass:

- the targeted backend regression suite now passes locally with `13 examples, 0 failures`

## What This System Protects

The current system is designed to protect a narrow but meaningful set of risks:

1. Missing delivery inputs
2. Login tenant-selection behavior drift
3. Candidate invite URL correctness
4. First runtime session-flow correctness
5. Frontend build health
6. Release decision honesty

That is enough to prove a real quality net exists. It is not enough yet to claim broad platform coverage.

## Implemented Gates

### 1. PR input gate

Purpose:

- block pull requests that are missing key delivery inputs

Implementation:

- workflow job: `.github/workflows/quality-gate.yml`
- validation script: `scripts/check-pr-body.sh`

Required sections:

- `## Spec / PRD`
- `## Acceptance Criteria / Test Scenarios`
- `## Solution / Design Plan`
- `## Tests`
- `## Release Risk`

Rule:

- the section must exist
- the section cannot be empty
- the section cannot be placeholder-only

Why it matters:

- this prevents “green by omission”
- it forces a minimal product and delivery context into every PR

### 2. Backend regression gate

Purpose:

- catch a small set of high-risk backend regressions automatically

Implementation:

- workflow job: `.github/workflows/quality-gate.yml`
- specs:
  - `api/spec/requests/api/v1/authentication_spec.rb`
  - `api/spec/requests/api/v1/sessions_create_spec.rb`
  - `api/spec/requests/api/v1/sessions_candidate_spec.rb`
  - `api/spec/requests/api/v1/sessions_audio_complete_spec.rb`
  - `api/spec/models/session_spec.rb`

Current covered behaviors:

- login falls back to the first organization scheme when tenant context is missing
- login falls back to `test-corp` when no organization scheme is available
- login preserves an explicit tenant context when one is provided
- session creation returns a usable invite URL
- candidate invite-token access returns the expected candidate info and not-found errors
- audio-complete supports valid end, idempotent repeat, and invalid-token errors
- invite URL prefers `WEB_BASE_URL`
- local invite URL falls back to the web app port when needed

Supporting CI work added in the same pass:

- Ruby setup in GitHub Actions
- required backend env variables for test boot
- Rails test boot fixes around websocket autoloading and middleware naming
- PostgreSQL service in CI
- `bundle exec rails db:prepare` before `rspec`

Why it matters:

- these are not cosmetic checks
- they document and protect a high-risk authentication seam plus candidate access paths

### 3. Frontend build gate

Purpose:

- prove the frontend still builds from source in CI

Implementation:

- workflow job: `.github/workflows/quality-gate.yml`
- command: `npm run build`

Supporting CI work added in the same pass:

- Node setup in GitHub Actions
- frontend dependency reinstall step to avoid the Rollup optional dependency failure seen in CI

Why it matters:

- this gives a basic signal that the frontend can still be shipped as a build artifact
- it does not replace frontend behavioral tests

### 4. Tag-based release verdict gate

Purpose:

- turn the configured checks into a simple release recommendation

Implementation:

- workflow trigger for tags matching `v*` in `.github/workflows/quality-gate.yml`
- verdict script in `scripts/release-verdict.sh`

Current verdict inputs:

- backend regression gate result
- frontend build gate result
- release notes presence

Current outputs:

- `release-verdict.md`
- GitHub Step Summary
- uploaded release-verdict artifact

Why it matters:

- it creates an explicit `releasable` or `blocked` outcome
- it makes a release decision inspectable instead of implicit

## Design Principles

- keep the first net small and real
- prefer high-signal checks over broad fake confidence
- do not mark work green by weakening checks
- treat missing inputs as engineering risk, not paperwork
- make the blocked path visible and defensible

## Why These Checks Were Chosen First

These checks were selected because they map directly to the highest-confidence findings from the audit:

- login tenant-selection behavior was a real integrity risk
- invite URL generation was a real flow risk
- PR input quality was missing entirely
- release verdict logic did not exist
- frontend build proof was missing from CI

This gave the best first return for assessment evidence and practical protection.

## What Is Still Missing

The quality system is real now, but still incomplete.

Main gaps:

- no committed frontend behavioral test suite
- no deeper backend coverage for the full live interview lifecycle beyond first create/candidate/audio-complete seams
- no end-to-end test of assessor and candidate journeys
- no automated check yet for reconnect behavior or live interview flow
- no durable product source of truth beyond the assessment artifacts

## Next Expansion Steps

The next useful checks to add would be:

1. session lifecycle regression coverage
2. one assessor CRUD or session-management flow
3. one candidate journey or interview runtime flow
4. broader contract coverage between frontend routes and backend capabilities

## Practical Outcome

This system is already strong enough to prove four important things:

- the repo now has a real workflow gate
- the repo now has real regression checks
- the repo now has a real release-verdict mechanism
- the repo can now fail honestly for missing inputs or broken checks

That is the right first milestone for this assessment.
