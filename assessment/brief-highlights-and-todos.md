# Case Study Brief Highlights and Todos

## What This Case Study Is Really Testing

- This is mainly a judgment exercise, not a test-volume exercise.
- The role is a fullstack engineer with SDET depth who owns both product changes and the quality system around them.
- The real goal is to make missing inputs, silent regressions, and unsafe releases hard to ship unnoticed.
- Strong judgment with a small, sharp, reproducible system will score better than large but shallow coverage.
- AI is explicitly allowed; what matters is how well the output is verified and used.

## Core Expectations

- Assess the platform as a whole, across both `api/` and `web/`, including bugs that appear in the seam between them.
- Treat missing inputs as first-class risk, not just process noise.
- Enforce a Definition of Ready and Definition of Done through a real workflow gate.
- Build CI checks that go red automatically on real issues, without human intervention.
- Fix the most serious defects with real code changes, then prove the red-to-green transition.
- Make an honest release decision based on evidence, even if that means blocking the release.

## Quality Bar

- A change is not ready without a spec or PRD, acceptance criteria or test scenarios, and a short solution or design plan.
- Correctness is about stored data and computed outcome, not just what the UI appears to show.
- Honesty beats a fake green build; known risks should be disclosed with mitigation and ownership.
- Green must be earned by fixing defects, never by weakening or deleting checks.
- A few high-signal checks that catch real failures are better than broad shallow coverage.

## Severity Scale

- `P0 Blocker`: the main objective cannot be achieved at all and there is no workaround.
- `P1 Major`: it appears to work, but the data or logic is wrong underneath, or the objective only works with a manual workaround.
- `P2 Minor`: it works and the data is correct, but there is a limited non-blocking issue.
- `P3 Cosmetic`: visual or copy issue only, with no functional or data impact.
- Any data-integrity issue is at least `P1`.

## What Must Be Demonstrated

- One pull request that the workflow gate blocks.
- One pull request that the workflow gate passes.
- CI that runs on every change and catches the risk-carrying paths.
- A visible red-to-green history where checks fail before the fix and pass after the fix.
- A release gate tied to a tag or release event with a clear `releasable` or `blocked` outcome.

## Required Deliverables

- `/assessment/01-audit.md`
- `/assessment/02-quality-system.md`
- `/assessment/03-release-decision.md`
- Release notes in `RELEASE_NOTES.md` or `CHANGELOG.md`
- A release tag such as `v1.0.0`
- Two visible pull requests showing one blocked path and one passing path

## Best Way To Approach It

- Work the loop the brief describes: assess, build the gate, fix to green, then cut and judge the release.
- Rank risks, do not give a flat bug list.
- Separate missing or ambiguous spec from incorrect implementation.
- Focus on data integrity, critical flows, and release safety before cosmetic issues.
- Write assumptions down when the brief or product behavior is ambiguous.

## Kanban Todos

### Backlog

- Read the brief once end to end and extract explicit scoring criteria.
- Map the main product flows across `api/` and `web/`.
- Identify where missing specs, acceptance criteria, or design notes create risk.
- Note likely high-risk data flows before writing checks.

### Ready

- Draft the structure for `/assessment/01-audit.md`.
- Define the workflow gate rules for required inputs and required tests.
- Choose the smallest set of high-signal automated checks.
- Decide how the blocked PR and passing PR will be demonstrated.

### In Progress

- Audit the platform and collect evidence with severity ranking.
- Build the quality net and CI checks.
- Fix the `P0` and `P1` findings with real code changes.
- Add regression checks so the same defects cannot silently return.
- Prepare release notes and release gating logic.

### Review

- Confirm the gate blocks a PR with missing inputs or missing tests.
- Confirm the gate passes a compliant PR.
- Verify the red-to-green history is visible in commits or CI runs.
- Review whether any remaining `P0` or `P1` forces a blocked release decision.
- Make sure the release status is readable without digging through raw logs.

### Done

- Finalize `/assessment/01-audit.md`.
- Finalize `/assessment/02-quality-system.md`.
- Finalize `/assessment/03-release-decision.md`.
- Leave both PRs visible.
- Tag the release and attach release notes.
- Submit the public repo URL through the platform.
