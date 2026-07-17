# Assessment 3: Release Decision

Status: Draft v1 on July 17, 2026.

Current release call: `blocked`

## Decision

This version should not be called `releasable` yet.

The repo now contains real release-gating mechanics, but the evidence is still too narrow to justify shipment with confidence.

## What The Gate Checks

- PR-body quality gate via [scripts/check-pr-body.sh](/home/rewog/Projects/ai-interview-platform/scripts/check-pr-body.sh)
- Backend regression specs for tenant-aware login and invite URL generation
- Frontend production build
- Release-notes presence
- Tag-based release-verdict generation in CI via [scripts/release-verdict.sh](/home/rewog/Projects/ai-interview-platform/scripts/release-verdict.sh)

## Evidence Reviewed

- PR-body gate passes with a filled-in PR payload
- Backend regression specs pass
- Frontend production build passes in the Dockerized web environment
- Tag-triggered release gating is configured in [.github/workflows/quality-gate.yml](/home/rewog/Projects/ai-interview-platform/.github/workflows/quality-gate.yml)
- The release-verdict script has been dry-run in both passing and blocked conditions
- Draft release notes exist in [RELEASE_NOTES.md](/home/rewog/Projects/ai-interview-platform/RELEASE_NOTES.md)
- The audit has been updated to reflect the current repo state in [assessment/01-audit.md](/home/rewog/Projects/ai-interview-platform/assessment/01-audit.md)

## What Is Green Now

- tenant-aware login regression checks
- invite URL regression checks
- frontend production build
- PR-input quality gate
- release-verdict scaffolding for version tags
- stale frontend signup drift removed so the frontend auth surface now matches the exposed backend auth contract

## What Still Blocks Release

### B-001 `P1 Major` - Quality gate coverage is still too narrow

The current net is real, but it still does not prove the highest-risk runtime flows end to end.

Still missing:

- live interview runtime flow coverage
- session lifecycle regression checks beyond invite URL generation
- candidate reconnect behavior checks
- assessor CRUD verification beyond build-time confidence

Why it blocks:

- a green build would still overstate release confidence
- the brief explicitly asks for a release decision based on evidence, not optimism

Owner if continued:

- engineering

### B-002 `P1 Major` - Product source of truth is still too weak

The repo now has assessment artifacts and release notes, but it still lacks a stable product source of truth such as:

- a real PRD
- explicit acceptance criteria tied to implemented flows
- traceability outside the assessment folder

Why it blocks:

- release approval is still too dependent on reverse-engineering behavior from code
- the brief treats missing inputs as a first-class delivery risk

Owner if continued:

- engineering plus product/CTO sponsor for acceptance boundaries

### B-003 Operational Gap - Tag gate exists but has not yet been exercised on a real tag

The tag-triggered release gate is implemented, but the repo does not yet have the first real tagged CI run captured as evidence.

Why it matters:

- the mechanism is present
- the final release artifact path is not yet demonstrated on an actual tag

Owner if continued:

- release owner for this assessment submission

## Recommendation

Do not cut the final submission release as `releasable` yet.

If a tag must be created to demonstrate the mechanism, create it as a blocked release candidate and record the blocked result honestly.

## What Would Change The Decision

To move this version from `blocked` to `releasable`, the next evidence should include:

1. one real version tag such as `v1.0.0` run through CI
2. one deeper runtime check around session lifecycle or assessor CRUD
3. a clearer source of truth for release acceptance boundaries

## Final Note

The important improvement in this pass is that the repo is now much better at proving a blocked release honestly.

That is a real step forward, even though the correct decision is still `blocked`.
