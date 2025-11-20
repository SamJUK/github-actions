# Magento 2 Test Unit Module (Warden)

This workflow handles running Unit tests against a Magento module, using Warden.

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
  unit-tests-warden:
    name: Unit Tests (Warden)
    uses: samjuk/github-actions/.github/workflows/magento2-test-unit-module-warden.yaml@master
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