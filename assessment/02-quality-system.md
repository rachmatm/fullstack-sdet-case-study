# 02 Quality System

Status: Draft v1, started on July 17, 2026 and updated after first implementation pass.

## Objective

Build a small, sharp quality system that does two jobs:

- block work that is missing its required inputs
- catch high-risk regressions in the platform before release

This document is intentionally grounded in the current repo state. The repo started without a visible CI workflow, without a committed automated test suite, and without a formal workflow gate, so the first step has been to create the minimum trustworthy system rather than over-designing a large one.

## Implemented In This First Pass

The first version of the quality system is now present in the repo:

- PR template at `.github/PULL_REQUEST_TEMPLATE.md`
- PR-body validation script at `scripts/check-pr-body.sh`
- CI workflow at `.github/workflows/quality-gate.yml`
- Backend RSpec bootstrap under `api/spec/`
- Initial regression specs for tenant-aware login and candidate invite URL generation
- Tag-triggered release-verdict path in `scripts/release-verdict.sh`
- Draft release notes in `RELEASE_NOTES.md`

This is intentionally a narrow first slice, not a complete release net.

## What The Net Must Protect

Based on the current audit, the first version of the net should protect these risk classes:

1. Tenant and auth correctness
   A valid login must bind the user to the intended tenant, not an implicit fallback.
2. Candidate invite flow correctness
   Generated invite links must open the real candidate interview UI, not the API host.
3. Frontend/backend contract correctness
   Publicly exposed frontend flows must match the backend routes that actually exist.
4. Local reproducibility
   Setup instructions and runtime defaults must match the repository layout and active ports.
5. Release honesty
   A release must surface `releasable` or `blocked` from evidence, not manual optimism.

## Quality Principles

- Green is earned by fixing defects, not weakening checks.
- Missing inputs are a release risk, not process trivia.
- Data integrity is more important than UI appearance.
- A few high-signal checks are better than broad low-signal coverage.
- The gate should make the right path easier than the unsafe path.

## Workflow Gate Design

The workflow gate should run on pull requests and block merge when required delivery inputs are missing.

### Required PR Inputs

Every PR should provide:

- linked spec or PRD reference
- acceptance criteria or test scenarios
- short solution or design plan
- evidence of tests or reason no automated test applies
- release risk note

### Proposed Enforcement

- Add a pull request template that requires all fields above.
- Add a CI check that fails when the PR body leaves required sections blank.
- Keep the required written artifacts in `/assessment` for this case study, since the brief explicitly asks for that folder.

### Demonstration Requirement

To satisfy the brief, the gate should be demonstrated with:

- one PR blocked because it lacks required inputs or tests
- one PR passing because it includes the required inputs and evidence

## Code And Release Checks

### Checks That Already Exist

- `web` has a build command: `npm run build`
- backend regression specs can be run with `bundle exec rspec spec/requests/api/v1/authentication_spec.rb spec/models/session_spec.rb`
- release tags matching `v*` now produce a release-verdict job in CI

### Checks Still Missing

- no visible frontend test runner committed
- no broader backend coverage for session lifecycle, live interview state, or assessor CRUD
- no real tag execution has been recorded yet for the new release gate

### First Checks Added

1. Workflow input gate
   Validate PR template completeness.
2. Frontend build gate
   Run `npm run build` in `web`.
3. Backend regression gate
   Add a small backend spec suite for the highest-risk flows.

### Next Checks To Add

1. Session lifecycle regression coverage
   Cover session start, end, and candidate invite flows more deeply.
2. Contract and runtime checks
   Cover assessor CRUD paths and one candidate journey end to end.
3. Lightweight release evidence capture
   Record the first real tagged CI run and fold its verdict into the release-decision document.

## Initial Regression Targets

The first regression checks should target the findings already confirmed in the audit.

### R1 Tenant Resolution

Goal:
Prevent login from silently binding a user to the wrong tenant.

What to test:

- login fails or requires explicit tenant context when tenant scheme is missing
- login uses the provided tenant scheme instead of defaulting to the first organization
- subsequent authenticated requests resolve the same tenant from the JWT claim

Likely test level:

- backend request or controller specs around authentication and tenant middleware

### R2 Invite Link Correctness

Goal:
Ensure copied candidate invite links point to the interview UI host.

What to test:

- session invite URL uses the intended web base URL
- invite link includes `/interview/:token`
- assessor create-session flow exposes the same URL that the candidate route can actually open

Likely test level:

- backend model or request spec for `Session#invite_url`
- optional frontend integration check around invite display and copy action

### R3 Auth Contract Drift

Goal:
Catch frontend routes or service calls that do not match backend capabilities.

What to test:

- login route exists and is callable
- removed or dormant auth paths do not still reference nonexistent backend routes

Likely test level:

- lightweight contract script or targeted frontend static check
- backend routing spec if introduced

### R4 Setup Truthfulness

Goal:
Prevent docs from pointing engineers at the wrong directories or ports.

What to test:

- README startup paths match actual repo layout
- documented default ports match configured defaults

Likely test level:

- lightweight repo script that checks key README snippets against expected values

## Proposed Implementation Order

1. Create the PR template and blocking workflow-input check.
2. Add a basic GitHub Actions workflow for the smallest trustworthy set of checks.
3. Add backend regression tests for tenant resolution and invite URL generation.
4. Add a frontend build check.
5. Remove or implement dormant frontend/backend contract drift.
6. Reuse the same net on release tags and produce a release verdict.

## What This System Protects

- Prevents missing spec and test context from merging silently.
- Catches the highest-confidence broken seams already found in the audit.
- Creates evidence for a real release decision.
- Gives the next engineer a reproducible baseline to extend.

## Current Gaps

- The frontend currently has no visible test runner, only a build step.
- The backend now has an initial committed spec suite, but only for two targeted risks.
- The first release-gate workflow exists, but it still needs one real tagged execution to prove the full artifact path.
- Runtime validation still needs to confirm the static audit findings end to end.

## Next Build Step

The next practical step is to widen coverage around the live interview lifecycle and one assessor CRUD path, because the first gate is now in place and the biggest remaining risk is still runtime behavior that has not been verified end to end.
