# Magento Supported Versions

The Magento and Mage-OS versions our modules are tested against, as a test matrix (`versions`: `[{distribution, version}]`).
It's our list, not Adobe's, so it can keep a version Adobe has dropped.

- **The list:** [`versions.json`](../actions/magento/supported-versions/versions.json). Each version needs a [compute-software-requirements](../actions/magento/compute-software-requirements/README.md) entry; the self-test checks.
- **Updates:** `_update-magento-versions.yaml` opens a PR on Mondays, or when run by hand. It syncs the requirements from [magento-compatability](https://github.com/SamJUK/magento-compatability) and moves each version to its newest patch that has a CI image. New release lines are logged, not added.
- **Per module:** `include` adds `distribution:version` (a bare version means `magento`). `exclude` also takes a version glob, e.g. `2.4.9*`.
- **Not tested:** Adobe Commerce extended support patches (e.g. 2.4.4-p14, 2.4.5-p15). compute-software-requirements has their requirements, but they're not on the public mirrors, so there's no CI image and [magento.works](https://magento.works/) can't confirm them.
- **2.4.4** is left out: it defaults to Elasticsearch 7, which the integration test config doesn't handle.

## Usage

```yaml
jobs:
  supported-versions:
    uses: samjuk/github-actions/.github/workflows/magento-supported-versions.yaml@master
    with:
      # both optional, one entry/pattern per line
      include: |
        2.4.3-p17
        mage-os:2.3.0
      exclude: |
        2.4.9*

  phpunit-tests-ghas:
    needs: [static, supported-versions]
    strategy:
      fail-fast: false
      matrix:
        include: ${{ fromJson(needs.supported-versions.outputs.versions) }}
    uses: samjuk/github-actions/.github/workflows/magento2-test-phpunit-module-ghas.yaml@master
    with:
      magento_version: ${{ matrix.version }}
      magento_distribution: ${{ matrix.distribution }}
      run_unit_tests: true
      run_integration_tests: true
```
