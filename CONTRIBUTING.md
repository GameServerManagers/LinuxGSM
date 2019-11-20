
# Contributing to LinuxGSM

👍🎉 Thank you for taking the time to contribute! 🎉👍

The following is a set of guidelines for contributing to LinuxGSM, which are hosted in the [GameServerManagers Organization](https://github.com/gameservermanagers) on GitHub. These are mostly guidelines, not rules. Use your best judgment, and feel free to propose changes to this document in a pull request.

#### Table of Contents

## Code of Conduct

This project and everyone participating in it is governed by the [LinuxGSM Code of Conduct](https://github.com/atom/linuxgsm/blob/master/CODE_OF_CONDUCT.md). By participating, you are expected to uphold this code. Please report unacceptable behaviour to [daniel.gibbs@linuxgsm.com](mailto:daniel.gibbs@linuxgsm.com).

## Bug/Enhancement Contibutions
###  🐛Reporting Bugs

This section guides you through submitting a bug report for LinuxGSM. Following these guidelines helps maintainers and the community understand your report  📝, reproduce the behavior  💻  💻, and find related reports  🔎.

### 🎉Suggesting Enhancements

This section guides you through submitting an enhancement suggestion for LinuxGSM, including completely new features and minor improvements to existing functionality. Following these guidelines helps maintainers and the community understand your suggestion 📝 and find related suggestions 🔎.

### :video_game: Game Server Specific Issues
LinuxGSM is a management script that acts as a wrapper around game servers. These game servers are developed by different game developers such as Valve, Epic and Facepunch to name a few. LinuxGSM has no control over the development and limited knowledge issues directly relating to the game servers themselves. The same also applies for any mods, add-ons, maps etc. 

If there is an issue with a specific game server or mod the best action may be to contact the game/mod developers on there support forums. If it is unclear smoe community members might be able to help . 

A [list](https://docs.linuxgsm.com/support/game-server) of game developer forums is available on the [LinuxGSM docs](https://docs.linuxgsm.com/support/game-server).

## Code Contributions
### Testing
### Pull Requests

The process described here has several goals:

- Maintain LinuxGSM quality.
- Fix problems that are important to users.
- Engage the community in working toward the best possible LinuxGSM
- Enable a sustainable system for LinuxGSM maintainers to review contributions

Please follow these steps to have your contribution considered by the maintainers:

1. Follow all instructions in [the template](PULL_REQUEST_TEMPLATE.md)
2. Follow the [styleguides](#styleguides)
3. After you submit your pull request, verify that all [status checks](https://help.github.com/articles/about-status-checks/) are passing 
<details><summary>What if the status checks are failing?</summary>If a status check is failing, and you believe that the failure is unrelated to your change, please leave a comment on the pull request explaining why you believe the failure is unrelated. A maintainer will re-run the status check for you. If we conclude that the failure was a false positive, then we will open an issue to track that problem with our status check suite.</details>

While the prerequisites above must be satisfied prior to having your pull request reviewed, the reviewer(s) may ask you to complete additional design work, tests, or other changes before your pull request can be ultimately accepted.
#### Pull Request naming convention
When naming a pull request ensure that it is following [Conventional Commits](https://www.conventionalcommits.org/) standards; as this is what is used for generating the [changelog](https://github.com/GameServerManagers/LinuxGSM/releases) for the next release.

The pull request subject line should always be able to complete the following sentence:

> If applied, this commit will *your subject line here*

For example:

-   If applied, this commit will  _refactor subsystem X for readability_
-   If applied, this commit will  _update getting started documentation_
-   If applied, this commit will  _remove deprecated methods_
-   If applied, this commit will  _release version 1.0.0_
-   If applied, this commit will  _merge pull request #123 from user/branch_

Notice how this doesn’t work for the other non-imperative forms:

-   If applied, this commit will  _fixed bug with Y_
-   If applied, this commit will  _changing behavior of X_
-   If applied, this commit will  _more fixes for broken stuff_
-   If applied, this commit will  _sweet new API methods_

Below is an example of the subject line for a pull request.

feat(alerts): add slack support to alerts

fix(csgoserver): remove SteamCMD auth requirement 32-bit workaround 

Once the Pull Request is created it is now time to wait. The Pull Request will need to be reviewed by LinuxGSM developers who regularly work on the project. They will accept, reject or recommend changes to the Pull Request. This can take time or your pull request will be held until a time that is appropriate to merge into the project so please be patient. One of the developers may leave a review to make changes or make changes themselves to make the commit ready. Once this review process is completed congratulations your commit will be merged ready for the next release.

Once merged in to the develop branch where it will be tested with other new features and code. When the code is at a point to release it will be merged in to the master branch which will make it live.

Pull Requests (PR) let others review changes a developer has been making in a branch. Once a PR is opened, a branch can be reviewed with other developers giving feedback and also add follow-up commits (LinuxGSM core devs only) before changes are merged into the base branch.

LinuxGSM uses Pull Requests to allow developers to submit code that is ready or nearly ready to be merged into the `develop` branch. To make the process easier a checklist template has been created to guide the submission.

Various unit tests are carried out to check that the PR does not break LinuxGSM and follows standards. Feedback is given by the tests once they are completed.

If the PR is not quite ready for merge but is ready for review and feedback ensure the subject of the PR conains `[WIP]`(Work in Progress).
### Styleguides
#### Git Commit Messages
#### BASH Styleguide
#### Documentation Styleguide
## Issue and Pull Request Labels
