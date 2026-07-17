# Magento Supported Versions

Single source of truth for which Magento/Mage-OS versions we currently
support. Returns a JSON array of `{distribution, version}` objects
(`versions` output) for use in a test matrix, so each module doesn't have
to maintain its own copy of the supported-version list.

Update the `BASE_ENTRIES` list in `magento-supported-versions.yaml` when
support changes org-wide (new release, EOL) — every consumer picks it up
automatically on their next run.

Some modules diverge from the standard list (extended support for an old
version, or frozen on old versions because they're EOL themselves) — use
`include`/`exclude` to adjust per-consumer without forking the list.
Entries are `distribution:version` (bare version implies `magento`).
`exclude` also accepts a bare glob (e.g. `2.4.9*`) matched against the
version part only, regardless of distribution.

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
