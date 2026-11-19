# SamJUK/github-actions

This repository contains production ready, reusable Github actions and workflows.

## Actions
| Action                                                                                                     | Description                                                                |
| ---------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------- |
| [magento/compute-software-requirements](./.github/actions/magento/compute-software-requirements/README.md) | Takes a Magento version input, an computes the  required software versions |


## Workflows
| Workflow | Description |
| -------- | ----------- |
| [magento2-module](./.github/workflows/magento2-module.readme.md) | The whole CI for a Magento module in one call: lint, static, dependencies and PHPUnit across the supported versions
| [magento2-test-lint](./.github/workflows/magento2-test-lint.readme.md) | Handles linting a Magento 2 project to opinionated standards
| [magento2-test-static](./.github/workflows/magento2-test-static.readme.md) | Handles performing opinionated static analysis against a Magento 2 project
| [magento-supported-versions](./.github/workflows/magento-supported-versions.readme.md) | Single source of truth for supported Magento versions, for use in a test matrix
| [magento2-test-phpunit-module-ghas](./.github/workflows/magento2-test-phpunit-module-ghas.readme.md) | PHPUnit tests for a Magento module (unit + DI compile + integration), using GitHub Actions Services
| [magento2-test-dependencies-module](./.github/workflows/magento2-test-dependencies-module.readme.md) | Checks a Magento module declares its dependencies in composer.json and module.xml (Yireo ExtensionChecker)
| [magento2-test-phpunit-project-ghas](./.github/workflows/magento2-test-phpunit-project-ghas.readme.md) | PHPUnit tests for a Magento project (unit + DI compile + integration), using GitHub Actions Services
