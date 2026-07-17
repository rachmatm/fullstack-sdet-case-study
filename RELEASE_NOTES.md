# Release Notes

## v1.0.0 Candidate

Status: draft candidate for the first gated release

### This Version Claims To Deliver

- tenant-aware assessor login that requires explicit tenant context
- candidate invite URLs that prefer the web host over the API host
- a pull-request quality gate for required delivery inputs
- backend regression checks for tenant-aware login and invite URL generation
- frontend production build verification in CI
- a Docker-based local environment for the API, web app, database, and worker

### Quality Gates Included

- PR-body validation via `scripts/check-pr-body.sh`
- backend regression specs for authentication and session invite URLs
- frontend production build
- release verdict generation on version tags

### Known Limits Before Final Ship Decision

- broader runtime interview flows are not yet covered end to end in automated checks
- the final `releasable` or `blocked` recommendation must still be recorded in `assessment/03-release-decision.md`
- any remaining `P0` or `P1` findings must still block release unless explicitly accepted with owner and mitigation
