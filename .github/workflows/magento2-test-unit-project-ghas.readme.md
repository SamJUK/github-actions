# Magento 2 Test Unit Project (Github Actions Services)

This workflow handles running Unit tests against a Magento project, using Github Actions Services.

## Usage

```yaml
name: My Workflow
on:
    push:
        branches: [ master ]
    pull_request:
        branches: [ master ]

jobs:
  unit-tests-ghas:
    name: Unit Tests (GHAS)
    needs: static
    uses: samjuk/github-actions/.github/workflows/magento2-test-unit-project-ghas.yaml@master
    with:
      magento_version: '2.4.7-p8'
      test_directory: 'app/code/SamJUK/*/Test/Unit/'
```