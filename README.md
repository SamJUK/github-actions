# SamJUK/github-actions

This repository contains production ready, reusable Github actions and workflows.

## Actions
| Action                                                                                                     | Description                                                                |
| ---------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------- |
| [magento/compute-software-requirements](./.github/actions/magento/compute-software-requirements/README.md) | Takes a Magento version input, an computes the  required software versions |
| [warden/create-env](./.github/actions/warden/create-env/README.md)                                         | Handles generating a complete warden `.env` file from inputs with defaults |
| [warden/setup-environment](./.github/actions/warden/setup-environment/README.md)                           | Handles setting up, and starting a warden environment in Github Actions |


## Workflows
| Workflow | Description |
| -------- | ----------- |
| [magento2-test-lint](./github/workflows/magento2-test-lint.readme.md) | Handles linting a Magento 2 project to opinionated standards
| [magento2-test-static](./github/workflows/magento2-test-static.readme.md) | Handles performing opinionated static analysis against a Magento 2 project 
| [magento2-test-unit-module-ghas](./github/workflows/magento2-test-unit-module-ghas.readme.md) | Handles running Unit tests against a Magento module, using Github Actions Services
| [magento2-test-unit-module-warden](./github/workflows/magento2-test-unit-module-warden.readme.md) | Handles running Unit tests against a Magento module using Warden
| [magento2-test-unit-project-ghas](./github/workflows/magento2-test-unit-project-ghas.readme.md) | Handles running Unit tests against a Magento project, using Github Actions Services
| [magento2-test-unit-project-warden](./github/workflows/magento2-test-unit-project-warden.readme.md) | Handles running Unit tests against a Magento project using Warden