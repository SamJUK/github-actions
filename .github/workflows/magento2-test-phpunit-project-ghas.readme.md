# Magento 2 Test PHPUnit Project (Github Actions Services)

This workflow runs PHPUnit-based tests against a full Magento project (a repo that already commits its own `composer.json`/`composer.lock` - e.g. a real storefront project, not a standalone module), using Github Actions Services. `setup:di:compile` always runs after install. Unit and integration tests are each opt-in via `run_unit_tests`/`run_integration_tests` (both default `false`).

Unlike the module variant, a project has no fixed test layout, so `test_directory` (unit tests, relative to `project_path`) and `integration_test_directory` (relative to `project_path/dev/tests/integration`) are both explicit overridable inputs rather than a derived convention.

`project_path` (default `.`) points at the checked-out project's own directory — override it if the project lives somewhere other than the checkout root.

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
    uses: samjuk/github-actions/.github/workflows/magento2-test-phpunit-project-ghas.yaml@master
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
