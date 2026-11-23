# Magento 2 Module CI

The whole CI for a Magento 2 module in one call: lint, static analysis, declared dependencies, then PHPUnit (unit, DI compile and integration) on every supported Magento and Mage-OS version.
A change here reaches every module that uses it, with no pull request per module.

```yaml
name: Continuous Integration

on:
  push:
    branches: [master]
  pull_request:
    branches: [master]

jobs:
  ci:
    uses: samjuk/github-actions/.github/workflows/magento2-module.yaml@<sha> # magento-module/v1.0.0
```

Pin a [release](./release.readme.md) commit and let Dependabot raise the bumps.

| Input | Default | What it does |
| ----- | ------- | ------------ |
| `directory` | `.` | Module directory, relative to the repository root |
| `exclude` | | Versions or globs to skip in the PHPUnit matrix, one per line, as in [magento-supported-versions](./magento-supported-versions.readme.md) |
| `run_unit_tests` | `true` | Runs `Test/Unit` when it exists |
| `run_integration_tests` | `true` | Runs `Test/Integration` when it exists |

The DI compile always runs. A module with neither test directory gets a warning, not a failure.

`php -l` runs in each PHPUnit cell on that cell's PHP, so syntax newer than the oldest supported Magento's PHP fails in its cell. PHPCS, PHPStan, the other linters and the dependency check run once: their answer doesn't change between versions.

Require only `Required` in the branch ruleset. The matrix check names include the Magento version, so they change with every release.
Each job is one of the workflows below, so the details and local reproduction steps live in their readmes:
[lint](./magento2-test-lint.readme.md), [static](./magento2-test-static.readme.md), [dependencies](./magento2-test-dependencies-module.readme.md), [PHPUnit](./magento2-test-phpunit-module-ghas.readme.md).
