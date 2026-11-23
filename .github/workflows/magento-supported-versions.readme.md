# Magento Supported Versions

Single source of truth for which Magento/Mage-OS versions we currently
support. Returns a JSON array of `{distribution, version, php}` objects
(`versions` output) for use in a test matrix, so each module doesn't have
to maintain its own copy of the supported-version list.

The Magento Open Source releases come from
[magento.watch](https://magento.watch) on every run, through
[github-action-magento-matrix](https://github.com/lbajsarowicz/github-action-magento-matrix):
each supported release line appears with its newest patch, and a line drops
out on its end-of-life date. A patch is used only once
`compute-software-requirements/manifest.json` has an entry for it; until
then the line stays on the previous patch and the run shows a warning naming
the missing release. Adding a release to the manifest (and building its CI
image) is all a new Magento patch needs. Mage-OS versions are not covered by
magento.watch: update `MAGE_OS_ENTRIES` in `magento-supported-versions.yaml`
when they change.

`php` picks the PHP versions per Magento release: `highest` (default, one job
per release), `lowest`, `boundaries` (lowest and highest), `all`, or a
comma-separated list such as `8.3,8.4`. Mage-OS and included entries have an
empty `php`, so the PHPUnit workflow uses the manifest's PHP version for them.

Some modules diverge from the standard list (extended support for an old
version, or frozen on old versions because they're EOL themselves) — use
`include`/`exclude` to adjust per-consumer without forking the list.
Entries are `distribution:version` (bare version implies `magento`).
`exclude` also accepts a bare glob (e.g. `2.4.9*`) matched against the
version part only, regardless of distribution.

The action sends one request to magento.watch per run, with the calling
repository's public name in its `User-Agent`; if the request fails, the list
bundled with the action release is used.

## Usage

```yaml
jobs:
  supported-versions:
    uses: samjuk/github-actions/.github/workflows/magento-supported-versions.yaml@master
    with:
      # all optional, one entry/pattern per line
      include: |
        2.4.3-p17
        mage-os:2.3.0
      exclude: |
        2.4.9*
      php: boundaries

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
      php_version: ${{ matrix.php }}
      run_unit_tests: true
      run_integration_tests: true
```
