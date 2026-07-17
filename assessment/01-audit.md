# 01 Audit

Status: Draft v1, based on repository review and targeted local verification on July 17, 2026.

Current release call: `blocked`

## Executive Summary

- The platform is still not release-ready in its current state.
- The repo now contains a real quality gate, backend regression checks, draft release notes, and tag-based release-verdict scaffolding.
- The remaining blockers are narrower and clearer than before: coverage is still too thin for release confidence, and the repo still lacks a trustworthy product source of truth such as a PRD or explicit acceptance criteria outside the case-study artifacts.
- Earlier code-level risks around tenant-aware login, invite URL generation, setup truthfulness, port consistency, and dead signup contract drift have been reduced or fixed in this pass.
- This draft is intentionally honest about scope: it includes some targeted execution verification, but not yet a full end-to-end runtime pass over assessor and candidate journeys.

Update note:
The repo now has a PR template, a PR-body gate, a CI workflow, initial backend regression specs, a tag-triggered release-verdict workflow path, and draft release notes. Release is still blocked because the checks are intentionally narrow and the runtime interview flows are not yet verified end to end.

## Scope And Method

- Reviewed the brief and the root repo documentation.
- Reviewed `api/README.md`, `web/README.md`, auth/routing files, session/interview flow files, and selected frontend auth pages.
- Searched the repo for CI workflows, test files, and non-code product artifacts such as specs, PRDs, acceptance criteria, ADRs, and release notes.
- Ran targeted regression checks and builds through the Dockerized stack.
- Did not yet run the full assessor and candidate journeys end to end, so findings that depend on live user flow behavior are still marked as pending runtime verification.

## Ship Or Do-Not-Ship Line

- Do not ship this version to a client in its current state.
- Even before runtime testing, the repo fails the brief's bar for a trustworthy engineering quality gate.
- The release process is currently too dependent on manual inspection and inference.

## Ranked Findings

### F-001 `P1 Major` - Quality gate coverage is still too narrow for release confidence

Impact:
The platform can still regress on critical behavior without being caught automatically. The current gate is now real, but it only covers PR inputs, a frontend build, and two backend regression paths.

Why this is `P1`:
The system may still be runnable, but safe release is still only reachable with manual validation and human vigilance. That matches the brief's `P1` bar.

Evidence:
- A first workflow now exists at [.github/workflows/quality-gate.yml](/home/rewog/Projects/ai-interview-platform/.github/workflows/quality-gate.yml).
- The PR-input gate now exists through [.github/PULL_REQUEST_TEMPLATE.md](/home/rewog/Projects/ai-interview-platform/.github/PULL_REQUEST_TEMPLATE.md) and [scripts/check-pr-body.sh](/home/rewog/Projects/ai-interview-platform/scripts/check-pr-body.sh).
- Initial backend regression specs now exist at [api/spec/requests/api/v1/authentication_spec.rb](/home/rewog/Projects/ai-interview-platform/api/spec/requests/api/v1/authentication_spec.rb) and [api/spec/models/session_spec.rb](/home/rewog/Projects/ai-interview-platform/api/spec/models/session_spec.rb).
- A tag-triggered release verdict now exists through [scripts/release-verdict.sh](/home/rewog/Projects/ai-interview-platform/scripts/release-verdict.sh) and the release-tag branch of [.github/workflows/quality-gate.yml](/home/rewog/Projects/ai-interview-platform/.github/workflows/quality-gate.yml).
- There is still no visible automated coverage for the live interview flow, session lifecycle, candidate reconnect logic, or assessor CRUD paths beyond build-time verification.

How found:
Static repository scan, targeted file review, and first-pass gate implementation.

Spec status:
Partially addressed, but still remaining as a release risk.

Final status:
Remaining.

### F-002 `P1 Major` - Repo lacks the required delivery inputs for safe build and release decisions

Impact:
There is no clear source of truth for intended behavior, acceptance boundaries, or design intent. That makes audit findings harder to classify and makes release approval depend on reverse-engineering the product from code.

Why this is `P1`:
The brief defines missing inputs as a first-class blocker for trustworthy delivery. In practice, engineering can only proceed here by inference and manual judgment.

Evidence:
- A documentation scan surfaced [README.md](/home/rewog/Projects/ai-interview-platform/README.md), [api/README.md](/home/rewog/Projects/ai-interview-platform/api/README.md), [web/README.md](/home/rewog/Projects/ai-interview-platform/web/README.md), [RELEASE_NOTES.md](/home/rewog/Projects/ai-interview-platform/RELEASE_NOTES.md), and the case-study artifacts under [`assessment/`](/home/rewog/Projects/ai-interview-platform/assessment).
- The repo still lacks a stable product source of truth such as a real PRD, explicit acceptance criteria tied to product flows, ADRs, or traceability outside the assessment artifacts created for this exercise.

How found:
Repository-wide artifact scan focused on non-code delivery inputs.

Spec status:
Missing input.

Final status:
Remaining.

### F-003 `P1 Major` - Login can bind a valid user to the wrong tenant

Impact:
An assessor can authenticate successfully but be scoped to the wrong organization. That creates a direct data-integrity and tenant-isolation risk: reads and writes can happen under the wrong tenant context while still appearing valid to the user.

Why this is `P1`:
Any data-integrity issue is at least `P1` under the brief's scale. This is not a cosmetic problem or a pure setup nuisance; it affects which tenant's data the user operates on.

Evidence:
- Login now requires explicit tenant context and resolves a canonical organization scheme at [api/app/controllers/api/v1/authentication_controller.rb](/home/rewog/Projects/ai-interview-platform/api/app/controllers/api/v1/authentication_controller.rb#L16).
- The tenant resolver then trusts the JWT `scheme` claim first for later requests at [api/app/middlewares/tenant_resolver_middleware.rb](/home/rewog/Projects/ai-interview-platform/api/app/middlewares/tenant_resolver_middleware.rb#L33).
- The frontend API client now sends `X-Tenant-Scheme` together with authenticated requests at [web/src/services/api.ts](/home/rewog/Projects/ai-interview-platform/web/src/services/api.ts#L14).
- A regression spec now covers missing tenant context and canonical scheme encoding at [api/spec/requests/api/v1/authentication_spec.rb](/home/rewog/Projects/ai-interview-platform/api/spec/requests/api/v1/authentication_spec.rb).

How found:
Static trace across login token generation, request middleware, and frontend request construction.

Spec status:
First-pass fix implemented.

Final status:
Fixed, pending runtime verification.

### F-004 `P1 Major` - Candidate invite links appear to be generated from the API base URL, not the web app URL

Impact:
The assessor-facing flow can generate and copy a candidate link that points to the wrong host or port. In local development it likely sends the candidate to the Rails service instead of the Vite app, and in deployment it appears configured to use the API domain rather than the web domain.

Why this is `P1`:
The core objective is still reachable only with a manual workaround, such as editing the URL host before sending it. That matches the brief's `P1` bar for a major issue.

Evidence:
- Session invite URLs now prefer `WEB_BASE_URL`, with a local development fallback to the frontend port, at [api/app/models/session.rb](/home/rewog/Projects/ai-interview-platform/api/app/models/session.rb#L28).
- The API README now distinguishes `APP_BASE_URL` from `WEB_BASE_URL` at [api/README.md](/home/rewog/Projects/ai-interview-platform/api/README.md#L30).
- The sample config now includes `WEB_BASE_URL` at [api/config/application.yml.sample](/home/rewog/Projects/ai-interview-platform/api/config/application.yml.sample#L23).
- The Kubernetes config now includes a `WEB_BASE_URL` placeholder at [api/k8s/configmap.yaml](/home/rewog/Projects/ai-interview-platform/api/k8s/configmap.yaml#L21).
- The candidate interview route actually lives in the web app at [web/src/App.tsx](/home/rewog/Projects/ai-interview-platform/web/src/App.tsx#L57).
- The assessor invite page copies `session.invite_url` directly and presents it as the candidate link at [web/src/pages/assessments/AssessmentInvitePage.tsx](/home/rewog/Projects/ai-interview-platform/web/src/pages/assessments/AssessmentInvitePage.tsx#L179).
- A regression spec now covers invite URL generation at [api/spec/models/session_spec.rb](/home/rewog/Projects/ai-interview-platform/api/spec/models/session_spec.rb).

How found:
Cross-check between backend URL generation, environment documentation, deployed config, and the web route that serves the candidate interview page.

Spec status:
First-pass fix implemented.

Final status:
Fixed, pending runtime verification.

### F-005 `P2 Minor` - Local setup instructions are internally inconsistent and point to the wrong frontend directory

Impact:
A new engineer following the docs literally is likely to fail local setup or waste time reconciling contradictory instructions. This hurts reproducibility and trust in the repo before deeper testing even starts.

Evidence:
- The backend README now points to `../web` at [api/README.md](/home/rewog/Projects/ai-interview-platform/api/README.md#L79).
- The services summary now references `web/` correctly at [api/README.md](/home/rewog/Projects/ai-interview-platform/api/README.md#L98).

How found:
Cross-check between repo structure and documented startup commands.

Spec status:
Documentation corrected.

Final status:
Fixed.

### F-006 `P2 Minor` - Frontend and documentation disagree on the backend default port

Impact:
Developers can point the web app at the wrong backend by following defaults. That increases false-negative debugging and makes environment setup less trustworthy.

Evidence:
- The web README now says the backend default is `http://localhost:3001` at [web/README.md](/home/rewog/Projects/ai-interview-platform/web/README.md#L7).
- The same README later instructs `VITE_API_BASE_URL=http://localhost:3001/api/v1` and `VITE_WS_BASE_URL=ws://localhost:3001` at [web/README.md](/home/rewog/Projects/ai-interview-platform/web/README.md#L23).
- The API README says the Rails server runs on port `3001` at [api/README.md](/home/rewog/Projects/ai-interview-platform/api/README.md#L74).
- The frontend API client now falls back to port `3001` in code at [web/src/services/api.ts](/home/rewog/Projects/ai-interview-platform/web/src/services/api.ts#L4).
- The frontend env example now also points to port `3001` at [web/.env.example](/home/rewog/Projects/ai-interview-platform/web/.env.example#L1).

How found:
Cross-check between docs and frontend client defaults.

Spec status:
Code and docs aligned.

Final status:
Fixed.

### F-007 `P2 Minor` - Frontend auth surface was drifting from the backend contract

Impact:
The codebase contains a signup client and signup page behavior that do not match the backend routes currently exposed. Even if not user-reachable today, this is a contract drift risk and a sign that the frontend and API are not being validated together.

Evidence:
- The backend routes file exposes `POST /api/v1/auth/login` but no signup route at [api/config/routes.rb](/home/rewog/Projects/ai-interview-platform/api/config/routes.rb#L8).
- The stale frontend signup client has now been removed from [web/src/services/auth.ts](/home/rewog/Projects/ai-interview-platform/web/src/services/auth.ts).
- The dormant signup page has now been removed from the frontend auth surface.
- The main router only mounts `/login` and does not expose a signup path at [web/src/App.tsx](/home/rewog/Projects/ai-interview-platform/web/src/App.tsx#L23).

How found:
Static contract comparison across the web service layer, page layer, and backend routes.

Spec status:
Dead-code path removed to align frontend behavior with the backend contract.

Final status:
Fixed.

## Systemic Pattern

- The recurring pattern is not just "a few bugs."
- The stronger signal is that repo truth is fragmented across code, docs, and implicit assumptions.
- Setup, auth, tenant scoping, and release safety are not being enforced by one trustworthy system.
- That makes this codebase vulnerable to exactly the failure mode the brief is trying to screen for: silent drift between intent, implementation, and release confidence.

## Immediate Gating Recommendation

- Block release work until a minimal quality net exists.
- First build the workflow gate and CI skeleton before broad feature fixes.
- Prioritize checks that protect tenant binding, invite-link correctness, auth contract correctness, and one or two critical end-to-end data paths.
- Treat missing product inputs as explicit audit items, not background context.

## Next Verification Pass

- Run the API and web app locally and validate the documented setup path end to end.
- Verify that assessor login resolves the intended tenant rather than defaulting to the first organization.
- Verify that copied candidate invite links open the actual interview UI without host or port rewriting.
- Trace one critical assessor flow and one candidate flow across API persistence and UI rendering.
- Verify whether tenant resolution, JWT handling, and candidate invite flows behave correctly under real requests.
