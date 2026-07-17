# 01 Audit

Status: Updated on July 17, 2026 after the first quality-system implementation pass.

Current release call: `blocked`

## Executive Summary

- A real quality gate now exists in the repository.
- Backend regression checks have been added for two high-risk areas: tenant-aware login and invite URL generation.
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

The repository now has targeted regression coverage for two high-risk behaviors:

- login tenant-selection behavior
- invite URL generation

References:

- `.github/workflows/quality-gate.yml`
- `api/spec/requests/api/v1/authentication_spec.rb`
- `api/spec/models/session_spec.rb`

Important note:

- the request spec initially failed because of test host authorization, not because of the business logic itself
- that was addressed in `api/spec/rails_helper.rb` by forcing request specs to use `localhost`

Status:

- Implemented
- CI wiring for PostgreSQL-backed `rspec` was added in the workflow and should be treated as part of the same quality-system work

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
- docs and frontend backend-port mismatch
- dead frontend signup contract drift

Related references:

- `api/spec/requests/api/v1/authentication_spec.rb`
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

The repo now has a real quality gate, but it still covers only a small slice of platform behavior. Critical flows such as the live interview session, reconnect behavior, broader assessor workflows, and richer end-to-end API/UI journeys are still not protected by automated checks.

Why this is `P1`:

The platform is no longer missing a quality net entirely, but the current net is still too thin to support confident release approval without additional manual validation.

Evidence:

- PR input validation exists in `.github/workflows/quality-gate.yml` and `scripts/check-pr-body.sh`
- backend regression checks exist in `api/spec/requests/api/v1/authentication_spec.rb` and `api/spec/models/session_spec.rb`
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
- login regression coverage now documents this fallback behavior in `api/spec/requests/api/v1/authentication_spec.rb`
- request-spec host handling was corrected in `api/spec/rails_helper.rb`

Final status:

- Remaining

### R-004 `P1 Major` - Invite URL host risk

Impact:

Candidate invite links could previously point to the wrong host or service boundary.

Evidence of fix:

- invite URL regression coverage exists in `api/spec/models/session_spec.rb`
- setup and environment docs now distinguish backend and frontend base URLs in `api/README.md`

Final status:

- Fixed, pending broader runtime verification

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

## Remaining Work Before I Would Call This Release-Ready

- keep the blocked and passing PR examples visible as evidence
- keep the red-to-green commit story clear in Git history
- complete final green CI proof for the latest passing branch
- add broader coverage for at least one real end-to-end interviewer or candidate flow if time allows
- keep the release-tag evidence visible once the final tag-based run is executed
