# 01 Audit

Status: Updated on July 17, 2026 after the first quality-system implementation pass.

Current release call: `blocked`

## Executive Summary

- A real quality gate now exists in the repository.
- Backend regression checks have been added for login tenant-selection behavior, invite URL generation, and the first runtime session flows.
- A frontend production build gate now exists.
- A tag-based release verdict flow now exists.
- Draft release notes now exist.
- Several earlier code-level issues have been fixed, narrowed, or clarified.

The repo is in a much better state than the initial audit baseline, but I am still keeping the release call as `blocked` for one reason: the quality net is now real, but still narrow, and the final GitHub CI evidence for the latest passing branch is still the key proof point to complete.

## What Has Been Done

### 1. PR quality gate has been added

The repository now blocks pull requests when required delivery inputs are missing or placeholder-only.

References:

- `.github/workflows/quality-gate.yml`
- `scripts/check-pr-body.sh`
- `.github/PULL_REQUEST_TEMPLATE.md`

What it enforces:

- `## Spec / PRD`
- `## Acceptance Criteria / Test Scenarios`
- `## Solution / Design Plan`
- `## Tests`
- `## Release Risk`

What it checks:

- the section must exist
- the section cannot be blank
- the section cannot be placeholder-only such as `TBD`, `TODO`, `N/A`, or an empty checklist

Status:

- Implemented

### 2. Backend regression checks have been added

The repository now has targeted regression coverage for several high-risk behaviors:

- login tenant-selection behavior
- invite URL generation
- session creation and invite response
- candidate invite-token entry
- candidate audio-complete session ending

References:

- `.github/workflows/quality-gate.yml`
- `api/spec/requests/api/v1/authentication_spec.rb`
- `api/spec/requests/api/v1/sessions_create_spec.rb`
- `api/spec/requests/api/v1/sessions_candidate_spec.rb`
- `api/spec/requests/api/v1/sessions_audio_complete_spec.rb`
- `api/spec/models/session_spec.rb`

Important note:

- the request spec initially failed because of test host authorization, not because of the business logic itself
- that was addressed in `api/spec/rails_helper.rb` by forcing request specs to use `localhost`

Status:

- Implemented
- CI wiring for PostgreSQL-backed `rspec` was added in the workflow and should be treated as part of the same quality-system work
- The targeted regression suite now passes locally with `13 examples, 0 failures`

### 3. Frontend production build verification has been added

The repository now has a frontend build gate in CI.

References:

- `.github/workflows/quality-gate.yml`

Status:

- Implemented
- The frontend build has been verified in the Docker-based local environment

### 4. A tag-based release gate has been added

The repository now has a release verdict workflow for version tags such as `v1.0.0`.

References:

- `.github/workflows/quality-gate.yml`
- `scripts/release-verdict.sh`

Behavior:

- if all configured checks pass, the verdict is `releasable`
- if any configured check fails, the verdict is `blocked`
- the verdict is written to `release-verdict.md`
- the verdict is appended to the GitHub Step Summary
- the verdict artifact is uploaded

Status:

- Implemented

### 5. Draft release notes now exist

References:

- `RELEASE_NOTES.md`

Status:

- Implemented

### 6. Several code-level issues have been fixed or narrowed

The following issues were addressed during this pass:

- login tenant-selection behavior was restored to the original fallback-based implementation and documented with regression coverage
- invite URL host risk
- first runtime coverage was added for session create, candidate entry, and audio-complete flows
- Gemini multipart response parsing
- Gemini-driven portfolio regeneration safety
- docs and frontend backend-port mismatch
- dead frontend signup contract drift

Related references:

- `api/spec/requests/api/v1/authentication_spec.rb`
- `api/spec/requests/api/v1/sessions_create_spec.rb`
- `api/spec/requests/api/v1/sessions_candidate_spec.rb`
- `api/spec/requests/api/v1/sessions_audio_complete_spec.rb`
- `api/spec/clients/gemini/http_client_spec.rb`
- `api/spec/services/portfolios/generator_spec.rb`
- `api/app/clients/gemini/http_client.rb`
- `api/app/services/portfolios/generator.rb`
- `api/spec/models/session_spec.rb`
- `api/spec/rails_helper.rb`
- `api/README.md`
- `web/README.md`
- `web/src/services/auth.ts`

Status:

- Implemented as first-pass fixes

## Severity-Ranked Risk List

### R-001 `P1 Major` - Release confidence is still limited by narrow automated coverage

Impact:

The repo now has a real quality gate, and it now covers several meaningful runtime seams, but it still covers only a limited slice of overall platform behavior. Critical flows such as the live interview websocket lifecycle, reconnect behavior, broader assessor workflows, and richer end-to-end UI/API journeys are still not protected by automated checks.

Why this is `P1`:

The platform is no longer missing a quality net entirely, but the current net is still too thin to support confident release approval without additional manual validation.

Evidence:

- PR input validation exists in `.github/workflows/quality-gate.yml` and `scripts/check-pr-body.sh`
- backend regression checks now exist in `api/spec/requests/api/v1/authentication_spec.rb`, `api/spec/requests/api/v1/sessions_create_spec.rb`, `api/spec/requests/api/v1/sessions_candidate_spec.rb`, `api/spec/requests/api/v1/sessions_audio_complete_spec.rb`, and `api/spec/models/session_spec.rb`
- frontend build validation exists in `.github/workflows/quality-gate.yml`
- release verdict logic exists in `scripts/release-verdict.sh`

Final status:

- Remaining

### R-002 `P1 Major` - The repository still lacks a stable product source of truth

Impact:

The engineering quality net is stronger now, but product intent is still under-documented in the repo itself. The main source of acceptance context remains the assessment artifacts rather than a durable PRD, ADR set, or feature-level acceptance documentation.

Why this is `P1`:

This makes release decisions more dependent on inference than on traceable product intent.

Evidence:

- the repo contains setup docs, assessment docs, and release notes
- the repo still does not contain a durable internal PRD or equivalent product decision record outside the case-study materials

Final status:

- Remaining

### R-003 `P1 Major` - Wrong-tenant login risk

Impact:

An authenticated user could previously be bound to the wrong tenant context, which is a serious integrity and tenant-isolation problem.

Evidence:

- login still falls back to the first organization scheme, or to `test-corp`, when no explicit tenant context is provided in `api/app/controllers/api/v1/authentication_controller.rb`
- login regression coverage now documents explicit tenant use plus both fallback paths in `api/spec/requests/api/v1/authentication_spec.rb`
- request-spec host handling was corrected in `api/spec/rails_helper.rb`

Final status:

- Remaining

Reason for status:

- this risk is still present in the product behavior
- the work in this pass restored the original fallback logic and added regression coverage
- it did not remove the underlying possibility of binding login to a fallback tenant

### R-004 `P1 Major` - Invite URL host risk

Impact:

Candidate invite links could previously point to the wrong host or service boundary.

Evidence of fix:

- invite URL regression coverage exists in `api/spec/models/session_spec.rb`
- setup and environment docs now distinguish backend and frontend base URLs in `api/README.md`
- the invite URL code path now prefers `WEB_BASE_URL` and explicitly maps local `APP_BASE_URL` from port `3001` to web port `5173` in `api/app/models/session.rb`

Final status:

- Fixed, pending broader runtime verification

Reason for status:

- the risky behavior was changed in code, not only documented
- the new host-selection logic is covered by regression tests
- runtime verification is still useful, but the original wrong-host path has been directly addressed

### R-005 `P2 Minor` - Local setup documentation drift

Impact:

Confusing or inconsistent setup documentation wastes engineering time and reduces trust in the repo.

Evidence of fix:

- setup instructions were corrected in `api/README.md`

Final status:

- Fixed

### R-006 `P2 Minor` - Frontend and documentation port mismatch

Impact:

Developers could point the frontend to the wrong backend port during local setup.

Evidence of fix:

- the frontend setup docs now align on port `3001` in `web/README.md`
- the backend docs align frontend and backend local ports in `api/README.md`

Final status:

- Fixed

### R-007 `P2 Minor` - Dead frontend signup contract drift

Impact:

Dormant frontend auth code that does not match backend routes creates unnecessary drift and false assumptions.

Evidence of fix:

- the stale signup path was removed from `web/src/services/auth.ts`

Final status:

- Fixed

### R-008 `P1 Major` - Malformed Gemini portfolio regeneration could erase the last good candidate portfolio

Impact:

A recruiter or assessor could open a candidate portfolio that was previously usable, trigger a regeneration or background retry, and then lose the entire prior portfolio because Gemini returned one malformed skill row. In real usage that means the most recent structured evidence for a candidate can disappear during review, forcing manual re-evaluation or delaying a hiring decision.

Why this is `P1`:

This is not only an internal job failure. It can directly remove previously available decision-support data for an active candidate review workflow.

Evidence of fix:

- portfolio regeneration in `api/app/services/portfolios/generator.rb` now validates the full Gemini payload before replacing existing portfolio skills
- portfolio replacement is now done atomically so a failed write cannot wipe the previous snapshot
- regression coverage was added in `api/spec/services/portfolios/generator_spec.rb`

Final status:

- Fixed

### R-009 `P1 Major` - Multipart Gemini responses could be truncated before downstream parsing

Impact:

Gemini can return structured text across multiple content parts. If the app reads only the first part, production behavior can degrade in several ways: fit-gap narratives can be cut off, portfolio generation can fail on partial JSON, and downstream AI-derived artifacts can become incomplete or inconsistent even though Gemini actually returned the full answer.

Why this is `P1`:

This affects a shared Gemini client used by multiple services. A single parser assumption can therefore corrupt several AI-backed product outputs at once.

Evidence of fix:

- the shared parser in `api/app/clients/gemini/http_client.rb` now joins all text parts before parsing
- regression coverage was added in `api/spec/clients/gemini/http_client_spec.rb`

Final status:

- Fixed

### R-010 `P0 Critical` - Live interview can terminate too early and leave unusable assessment results

Impact:

This is a candidate-facing and assessor-facing runtime failure. A candidate can start an interview, lose the session far earlier than the configured assessment duration, and leave behind a transcript that is too thin to support a credible evaluation. From the admin side, the resulting portfolio can fail to generate or degrade into weak skill levels and low-signal fit-gap output, which makes the final assessment result unreliable.

Observed user-visible failure pattern:

- the interview ended too early
- the transcript was too thin
- portfolio generation failed or produced weak skill levels

Why this is `P0`:

If this happens in production, the core product promise fails. The candidate experience is interrupted, the assessor loses confidence in the result, and the platform can produce an invalid hiring artifact from an incomplete interview. This is not a minor regression or a reporting issue. It is a top-priority runtime failure in the main value path of the system.

Likely contributing causes to investigate:

- Gemini websocket or runtime error during the live interview loop
- reconnect exhaustion during browser or Gemini session recovery
- backend session termination with end reason `error`

Important note:

- these causes are currently hypotheses based on the observed symptom pattern and the known session lifecycle paths
- they should be confirmed with Docker runtime logs from `api` and `sidekiq` during reproduction
- the next strongest move is to capture the actual `api` and `sidekiq` logs from one failed short interview and turn this `P0` from a suspected runtime blocker into a confirmed root-cause finding

Initial evidence path:

- candidate timer and interview state handling in `web/src/pages/interview/InterviewPage.tsx`
- warning-only timer threshold in `web/src/components/interview/InterviewTimer.tsx`
- live session ending paths in `api/app/channels/audio_websocket_middleware.rb`
- session termination and portfolio enqueueing in `api/app/services/sessions/end_handler.rb`
- portfolio generation flow in `api/app/services/portfolios/generator.rb`
- fit-gap generation flow in `api/app/services/fit_gap/engine.rb`

Final status:

- Remaining

Reason for status:

- the symptom was observed during manual testing of the live interview flow
- the exact root cause has not yet been confirmed with runtime logs
- until the session-ending path is verified and stabilized, this remains a release-blocking production risk

## Remaining Work Before I Would Call This Release-Ready

- keep the blocked and passing PR examples visible as evidence
- keep the red-to-green commit story clear in Git history
- complete final green CI proof for the latest passing branch
- investigate and stabilize the premature live-interview termination path with runtime logs
- capture the actual `api` and `sidekiq` logs from one failed short interview and convert the current `P0` suspicion into a confirmed root-cause finding
- add broader coverage for at least one real end-to-end interviewer or candidate flow if time allows
- keep the release-tag evidence visible once the final tag-based run is executed
