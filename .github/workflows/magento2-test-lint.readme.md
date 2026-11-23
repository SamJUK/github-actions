# Magento 2 Test Lint

This workflow handles linting a Magento 2 project to opinionated standards: `composer validate`, `php -l`, yamllint and xmllint.
`php: false` skips `php -l`, for a caller that lints on several PHP versions itself, as [magento2-module](./magento2-module.readme.md) does.

## Usage

```yaml
name: Magento 2 Test Lint
on:
    push:
        branches: [ master ]
    pull_request:
        branches: [ master ]
jobs:
    lint:
        name: Linter
        uses: samjuk/github-actions/.github/workflows/magento2-test-lint@master
```