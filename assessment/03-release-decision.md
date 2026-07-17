# 03 Release Decision

Status: Updated on July 17, 2026 after the first quality-system implementation pass.

Current release call: `blocked`

## Decision

This version should not yet be called `releasable`.

The repository now has a real quality system, but the current evidence still supports a `blocked` release decision rather than a confident shipment decision.

## What Exists Now

The release decision is no longer based on guesswork alone. The repository now contains:

- a PR body quality gate
- backend regression checks for login tenant-selection behavior, invite URL generation, and first runtime session flows
- a frontend production build gate
- a tag-based release verdict flow
- draft release notes

That is a meaningful improvement over the earlier state of the repo.

## Evidence Considered

Evidence now present in the repository:

- PR input validation in `scripts/check-pr-body.sh`
- CI workflow in `.github/workflows/quality-gate.yml`
- backend regression specs in:
  - `api/spec/requests/api/v1/authentication_spec.rb`
  - `api/spec/requests/api/v1/sessions_create_spec.rb`
  - `api/spec/requests/api/v1/sessions_candidate_spec.rb`
  - `api/spec/requests/api/v1/sessions_audio_complete_spec.rb`
  - `api/spec/models/session_spec.rb`
- request-spec host fix in `api/spec/rails_helper.rb`
- release verdict logic in `scripts/release-verdict.sh`
- draft release notes in `RELEASE_NOTES.md`
- updated audit in `assessment/01-audit.md`
- updated quality-system description in `assessment/02-quality-system.md`
- local backend regression verification with `13 examples, 0 failures`

## What Is Green Enough To Count As Real Progress

The following are real improvements and should count as completed work:

- missing PR inputs can now be blocked automatically
- login tenant-selection behavior has targeted regression coverage
- first runtime session flows now have targeted backend regression coverage
- invite URL generation has targeted regression coverage
- frontend build health is now checked in CI
- release verdict generation exists for version tags
- stale frontend signup drift was removed
- several setup and documentation mismatches were corrected

## Why The Release Is Still Blocked

### B-001 `P1 Major` - Coverage is still too narrow

The quality system is real, but it still covers only a small part of the platform.

Still not covered well enough:

- live interview runtime flow
- websocket-driven session lifecycle beyond the first create/candidate/audio-complete seams
- reconnect behavior
- broader assessor workflows
- end-to-end UI and API flow confidence

Why this blocks release:

- a green result from the current checks would still overstate release confidence

### B-002 `P1 Major` - The repository still lacks a strong product source of truth

The assessment artifacts help, but the repository still does not contain a durable product source of truth such as:

- a stable PRD
- clear feature-level acceptance criteria
- broader traceability outside the assessment work

Why this blocks release:

- release approval still depends too much on inference from code and setup docs

### B-003 Operational Evidence Gap - Final passing-path proof still needs to stay visible

The mechanism for passing and blocked PRs exists, and the tag-based release gate exists, but the final assessment story depends on keeping the proof visible:

- one blocked PR example
- one passing PR example
- a clear red-to-green commit trail
- a real tagged release-gate run if included in the final submission

Why this matters:

- the assessment asks for visible evidence, not only local reasoning

## Recommendation

Keep the release decision as `blocked`.

That is the most accurate and defensible decision at this stage.

## What Would Change The Decision To `releasable`

The release call could move to `releasable` if the following evidence is added:

1. final green CI proof on the passing branch remains visible
2. blocked and passing PR examples remain visible
3. the red-to-green history remains easy to inspect
4. at least one more runtime-critical flow gains automated or direct verification
5. if a release tag is used for the submission, the tagged release-verdict run is visible

## Final Note

The most important change in this pass is not that the repo is suddenly release-ready.

The important change is that the repo is now much better at proving when a release should be blocked, and that is exactly what a credible quality system should do first.
