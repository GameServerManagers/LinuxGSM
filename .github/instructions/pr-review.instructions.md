---
title: "LinuxGSM PR Review Guidance"
applyTo: "**"
description: "Use when reviewing pull requests in LinuxGSM; prioritize regressions, behavior changes, shell safety, and missing tests over style-only feedback."
---

Focus review effort on correctness and operational safety first.

Primary priorities:

- Identify behavior regressions and compatibility risks.
- Flag unsafe shell patterns (`rm -rf`, unquoted vars, unchecked command failures).
- Verify workflow changes do not weaken permissions or secret handling.
- Check for missing tests/validation when logic changes.
- Confirm labels, templates, and automation rules stay internally consistent.

Feedback expectations:

- Give concrete, actionable findings with file and reason.
- Prefer high-signal issues over style nits.
- If no defects are found, state that clearly and mention residual risk areas.
- Suggest minimal, low-risk fixes before proposing broad refactors.

LinuxGSM-specific checks:

- Shell scripts should preserve robust defaults (`set -euo pipefail` where appropriate).
- Label/workflow updates should avoid duplicate or stale taxonomy.
- Automation should fail safe (log and continue for advisory AI; block on true CI errors).
- Keep issue/PR automation rules aligned with templates and existing labels.
