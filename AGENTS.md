# AGENTS.md

Guidance for AI coding agents (Codex, Copilot, Claude Code and others) working on LinuxGSM. Human contributors should read [CONTRIBUTING.md](CONTRIBUTING.md); the rules below apply to everyone.

## Pull requests

- Target the `develop` branch. Never open a pull request against `master`.
- Title the pull request using [Conventional Commits](https://www.conventionalcommits.org/), for example `fix(steamcmd): retry failed downloads`. Pull requests are squashed and the title becomes the changelog entry.
- Build the pull request body from [.github/pull_request_template.md](.github/pull_request_template.md). Keep every heading and checklist, fill in each section, and tick only the boxes that are true.
  - `gh pr create --body` and `--body-file` do not apply the template, and neither do most agent integrations. Read the template file, fill it in, and pass the result with `--body-file`.
- Link issues with a closing keyword in the Description section: `Fixes #123`. Use one keyword per issue: `Fixes #123, fixes #456`. Replace the `#[issue]` placeholder; never leave it in.
  - Use `Related to #123` instead only when the pull request does not fully resolve the issue.
  - The Development sidebar cannot be set through `gh` or the GitHub API. The closing keyword is the only scriptable way to link an issue.
- The `PR Body Check` workflow fails pull requests that drop the template or leave the placeholder in place.

## Code

- LinuxGSM is written in bash. Modules live in `lgsm/modules/`; do not add Python or other runtimes to them.
- Run `shellcheck` and `bash -n` on changed scripts. Formatting is enforced by Prettier and Super-Linter in CI.
