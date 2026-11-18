# Magento 2 Test Static Analysis

This workflow handles performing opinionated static analysis against a Magento 2 module.

PHPCS runs the Magento2 standard from a global install.

PHPStan runs after `composer update` in `directory` (a module's lock file never reaches a store), so only what the module declares is installed, and a class from an undeclared dependency fails as an unknown class.
It uses the module's own `vendor/bin/phpstan` when it has one, otherwise a global PHPStan.
The module's `phpstan.neon` or `phpstan.neon.dist` wins: `phpstan_level` only applies without one, and `paths` defaults to the module root.
`vendor` and `Test/Integration` are always excluded, as integration tests use `Magento\TestFramework`, which only exists inside a Magento install.
Errors fail the job.

## Usage

```yaml
name: Magento 2 Test Static Analysis
on:
    push:
        branches: [ master ]
    pull_request:
        branches: [ master ]
jobs:
    lint:
        name: Linter
        uses: samjuk/github-actions/.github/workflows/magento2-test-lint@master
    static-analysis:
        name: Static Analysis
        needs: lint
        uses: samjuk/github-actions/.github/workflows/magento2-test-static@master
```