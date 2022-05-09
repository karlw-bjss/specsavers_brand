# POC for new release procedure and automation

To make releases easier and improve some aspects, I propose the following new procedure plus a POC of automation to help.

Note new containerised names are used for environments throughout, but can apply to the non-containerised equivalents.

## Changes to release procedures

### Release cut and Beta
When a release cut is taken, it is tagged as a pre-release called `YY.MM.n-betaB` (e.g. `22.05.0-beta1`). When deploying to a Beta
environment, it is this tag which should be deployed rather than the release branch. This will allow us to quickly check which
precise version of the code is on the environment.

### Hotfixes
When hotfixes are needed, they are merged into the release branch as currently. However, before these are deployed to Beta, a
new beta release is tagged (e.g. `22.05.0-beta2`) and this is deployed to the environment.

### Release Candidates
Once any required hotfixes have been appled and testing is complete on Beta/Reg, a Release Candidate pre-release is tagged from the
latest Beta (e.g. `22.05.0-rc1`). This can then be deployed to RC for final testing. If more changes are needed, a new beta release
should be created before tagging again as an RC.

### Release
The final release is tagged from the latest Release Candidate when testing is complete. At this point, a PR should be raised to merge
any hotfixes back to develop (if needed).

### "Dot" releases
Where a dot release is required, merging to the release branch should wait until the final `.0` release (or previous dot release) has
been tagged. This should then follow the above procedure to create new beta, RC and release tags. For example, if `22.05.1` is required:
- Wait until `22.05.0` has been tagged and released, then merge any tickets for the dot release in.
- Tag `22.05.1-beta1`
- Test and apply any hotfixes, creating new beta releases as needed.
- Tag `22.05.1-rc1` from the latest beta and test on RC.
- Tag `22.05.1` and raise a PR back to develop (if needed).

#### Accelerated "dot" release
If a dot release must be tested on beta before the previous full or dot release has been tagged:
- Create a branch to stage these changes called e.g. `dot-22.05.2`
- Deploy this branch to beta and test
- Once the previous release has been tagged, merge into the release branch and follow the procedure above

### Artifacts
Included in the example automations is the generation of artifacts on the brand release for each release which bundles brand and frontend.
If adopted, this would allow the deployment to the server to avoid use of git, instead just grabbing the artifact. It would also allow
common tasks (e.g. composer install) to be performed during this release procedure before deployment, among others.

### Automations
Included are POC automations, written using Github Actions and Bash scripts. The following are included:
- `release_cut` creates the release branch and its first beta release on both brand and frontend.
- `tag_next_prerelease` will tag the next sequential beta from the release branch, or the next sequential Release Candidate from the latest beta.
- `tag_release` will tag a release from the latest RC

Some parts are placeholders. They could be extended to automate the deployment, send emails, etc.
