# Magento 2 Test Unit Module (Github Actions Services)

This workflow handles running Unit tests against a Magento module, using Github Actions Services.

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
  unit-tests-ghas:
    name: Unit Tests (GHAS)
    uses: samjuk/github-actions/.github/workflows/magento2-test-unit-module-ghas.yaml@master
    needs: static
    with:
      magento_version: ${{ matrix.magento_version }}
    strategy:
      fail-fast: false
      matrix:
        magento_version:
          - '2.4.8-p3'
          - '2.4.7-p8'
          - '2.4.6-p13'
          - '2.4.4-p13'
```