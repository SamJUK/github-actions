# Release

Tags a release for each family of workflows whose files changed since its last tag, as `<family>/vX.Y.Z`.

| Family | Entry points |
| --- | --- |
| `magento-module` | [magento2-module](./magento2-module.readme.md) |
| `magento-store` | magento-store, published-build, composer-changes, docker-prune-pr |

A family's files are its entry points plus everything they reach through `$/` references, readmes excluded.
A change elsewhere in the repository releases nothing, so consumers only get bump PRs for what they run.

The bump comes from the Conventional Commits since the family's last tag: `!` or `BREAKING CHANGE:` is major, `feat` minor, anything else patch.
The first release of a family is `v1.0.0`.

Each tag points at its own commit: HEAD's tree, with HEAD as parent, on no branch.
Dependabot reads the family from the tags on a commit and takes the wrong one when two families share it, so they never do.

Run it when there is something to release: from the Actions tab (dry run by default), or locally with `bin/release.sh [--dry-run]` on an up-to-date master.

## Consuming a release

Pin the commit, with the tag as a comment, and let Dependabot raise the bumps:

```yaml
jobs:
  ci:
    uses: SamJUK/github-actions/.github/workflows/magento2-module.yaml@<sha> # magento-module/v1.0.0
```

```yaml
# .github/dependabot.yml
version: 2
updates:
  - package-ecosystem: github-actions
    directory: /
    schedule:
      interval: monthly
    cooldown:
      default-days: 0
```
