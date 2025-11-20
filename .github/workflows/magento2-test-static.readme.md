# Magento 2 Test Static Analysis

This workflow handles performing opinionated static analysis against a Magento 2 project.

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