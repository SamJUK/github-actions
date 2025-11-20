# Magento 2 Test Unit Project (Warden)

This workflow handles running Unit tests against a Magento project, using Warden.

## Usage

```yaml
name: My Workflow
on:
    push:
        branches: [ master ]
    pull_request:
        branches: [ master ]

jobs:
  unit-tests-warden:
    name: Unit Tests (Warden)
    needs: static
    uses: samjuk/github-actions/.github/workflows/magento2-test-unit-project-warden.yaml@master
    with:
      test_directory: 'app/code/SamJUK/*/Test/Unit/'
```