# Magento 2 Test PHPUnit Project (Github Actions Services)

This workflow runs PHPUnit-based tests against a full Magento project (a repo that already commits its own `composer.json`/`composer.lock` - e.g. a real storefront project, not a standalone module), using Github Actions Services. `setup:di:compile` always runs after install. Unit and integration tests are each opt-in via `run_unit_tests`/`run_integration_tests` (both default `false`).

`test_directory` and `integration_test_directory` (both default `app/code/*/*/Test/Unit`/`app/code/*/*/Test/Integration`, relative to `project_path`) are globs targeting every custom module under `app/code`, not one specific module. Resolved natively by PHPUnit's `<directory>` element (injected into `dev/tests/unit/phpunit.xml.dist`/`dev/tests/integration/phpunit.xml.dist` as a scoped `Project_*_Tests` suite, with the `project_path` -> `dev/tests/{unit,integration}` traversal added automatically) rather than shell-expanded - Magento's own stock suites can't be reused directly since they also pull in `vendor/magento/module-*` (unit) or the core `testsuite/` directory (integration), which would run the entire core suite alongside your own code.

`project_path` (default `.`) points at the checked-out project's own directory — override it if the project lives somewhere other than the checkout root.

Unlike the module variant, a project pins its own exact Magento version via its committed `composer.lock` (`composer install`, not `composer require` against a floating version) - `magento_version` should be hardcoded to match that pin, not driven from [magento-supported-versions](./magento-supported-versions.readme.md)'s matrix, which the project's lock file can't flex across.

`magento_distribution` (default `magento`) switches to `mage-os` for a Mage-OS project - swaps the `compute-software-requirements` lookup to the `mage-os` manifest key. Unlike the module variant there's no container image to swap (this workflow's container is a distribution-agnostic PHP runtime, not a pre-built Magento install), so this only affects the computed PHP/service versions. `php_version` overrides the computed PHP version, same as the module variant.

2.4.4 and earlier aren't supported for `run_integration_tests` - those versions default to `search-engine: elasticsearch7`/`elasticsearch-host` instead of `opensearch-host`, which this workflow doesn't account for, so search installation fails.

## Usage

```yaml
name: My Workflow
on:
    push:
        branches: [ master ]
    pull_request:
        branches: [ master ]

jobs:
  # ... stuff
  phpunit-tests-ghas:
    name: PHPUnit Tests (GHAS)
    uses: samjuk/github-actions/.github/workflows/magento2-test-phpunit-project-ghas.yaml@master
    needs: static
    with:
      magento_version: '2.4.8-p5' # match this project's own composer.lock pin
      run_unit_tests: true
      run_integration_tests: true
```
