# Magento Supported Versions

Single source of truth for which Magento versions we currently support.
Returns a JSON array (`versions` output) for use in a test matrix, so each
module doesn't have to maintain its own copy of the supported-version list.

Update the `BASE_VERSIONS` list in `magento-supported-versions.yaml` when
support changes org-wide (new release, EOL) — every consumer picks it up
automatically on their next run.

Some modules diverge from the standard list (extended support for an old
version, or frozen on old versions because they're EOL themselves) — use
`include`/`exclude` to adjust per-consumer without forking the list.
`exclude` supports glob patterns (e.g. `2.4.9*` to drop every 2.4.9 patch).

## Usage

```yaml
jobs:
  supported-versions:
    uses: samjuk/github-actions/.github/workflows/magento-supported-versions.yaml@master
    with:
      # both optional, one version/pattern per line
      include: |
        2.4.3-p17
      exclude: |
        2.4.9*

  phpunit-tests-ghas:
    needs: [static, supported-versions]
    strategy:
      fail-fast: false
      matrix:
        magento_version: ${{ fromJson(needs.supported-versions.outputs.versions) }}
    uses: samjuk/github-actions/.github/workflows/magento2-test-phpunit-module-ghas.yaml@master
    with:
      magento_version: ${{ matrix.magento_version }}
      run_unit_tests: true
      run_integration_tests: true
```
