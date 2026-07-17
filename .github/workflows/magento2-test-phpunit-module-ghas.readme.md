# Magento 2 Test PHPUnit Module (Github Actions Services)

This workflow runs PHPUnit-based tests against a Magento module, using Github Actions Services. `setup:di:compile` always runs after install. Unit and integration tests are each opt-in via `run_unit_tests`/`run_integration_tests` (both default `false`).

**Recommended: set both to `true` always**, even if the module doesn't have one of the two test types yet. The workflow checks whether `Test/Unit`/`Test/Integration` actually exist and skips whichever is missing, so there's no CI wiring to come back and update later when you add the other one — it just starts running. If *neither* directory exists despite both being requested, the job fails loudly instead of silently reporting green with zero tests run (almost certainly a misconfigured `module_path`, not an intentional "no tests" module).

`module_path` (default: `./extensions/${{ github.event.repository.name }}`) points at the checked-out module's own directory — override it if the module composer.json lives somewhere other than the checkout root (e.g. a fixture in a monorepo). `Test/Unit` and `Test/Integration` are always expected as subdirectories of `module_path`, per Magento's standard module layout — there's no separate override for these.

2.4.4 and earlier aren't supported for `run_integration_tests` - those versions default to `search-engine: elasticsearch7`/`elasticsearch-host` instead of `opensearch-host`, which this workflow doesn't account for, so search installation fails. Already excluded from [magento-supported-versions](./magento-supported-versions.readme.md)'s base list for this reason - don't `include:` it back in for a consumer that enables `run_integration_tests`.

## Usage

Get the version matrix from [magento-supported-versions](./magento-supported-versions.readme.md) rather than hardcoding one, so every consumer picks up support changes automatically:

```yaml
name: My Workflow
on:
    push:
        branches: [ master ]
    pull_request:
        branches: [ master ]

jobs:
  # ... stuff
  supported-versions:
    uses: samjuk/github-actions/.github/workflows/magento-supported-versions.yaml@master

  phpunit-tests-ghas:
    name: PHPUnit Tests (GHAS)
    uses: samjuk/github-actions/.github/workflows/magento2-test-phpunit-module-ghas.yaml@master
    needs: [static, supported-versions]
    with:
      magento_version: ${{ matrix.magento_version }}
      run_unit_tests: true
      run_integration_tests: true
    strategy:
      fail-fast: false
      matrix:
        magento_version: ${{ fromJson(needs.supported-versions.outputs.versions) }}
```
