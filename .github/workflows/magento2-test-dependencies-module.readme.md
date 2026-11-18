# Magento 2 Test Dependencies Module

Checks that a Magento module declares what its code uses, with [Yireo's ExtensionChecker](https://github.com/yireo/Yireo_ExtensionChecker).
It fails on a class, plugin target or layout handle from a module that is missing from `composer.json` `require` or from the `module.xml` sequence.

Our module tests install the module into a full Magento, so a missing dependency never shows up there.
It shows up on a store that does not happen to have that module installed.

The module is installed into the `magento-ci-testing-env` image with ExtensionChecker, and the scan runs without a database.
Run it once, on one Magento version: what a module declares does not change between versions.
ExtensionChecker needs Magento 2.4.6 or later.

`hide_needless` (default `true`) hides "possibly not needed" findings, because the checker reports `require-dev` tools such as PHPCS and PHPStan as not needed.
Set it to `false` for a stricter check, and list the tools in a `.yireo-extension-checker.json` in the module:

```json
{
    "ignore": ["samjuk/dev-standards", "magento/magento-coding-standard"]
}
```

It also fails on `*` version constraints, `require-dev` included.
The licence check is skipped, as it fails anything but OSL, AFL and MIT.

## Running it locally

The same scan, in the same image, from the module's folder (it needs Docker):

```sh
docker run --rm -i -v "$PWD":/module:ro samjuk/magento-ci-testing-env:2.4.8-php8.4 sh <<'SH'
set -e
mkdir -p extensions && cp -R /module extensions/module
MODULE=$(php -r 'echo simplexml_load_file("/module/etc/module.xml")->module["name"];')
composer require -q -W "$(jq -r .name /module/composer.json):@dev" yireo/magento2-extensionchecker:2.6.1
php -r '$c = include "app/etc/env.php"; unset($c["cache"]); file_put_contents("app/etc/env.php", "<?php return " . var_export($c, true) . ";");'
php bin/magento module:enable -q Yireo_ExtensionChecker "$MODULE"
cat > scan.php <<'PHP'
<?php
require 'app/bootstrap.php';
exit(Magento\Framework\App\Bootstrap::create(BP, $_SERVER)->getObjectManager()
    ->get(Yireo\ExtensionChecker\Console\Command\ScanCommand::class)
    ->run(new Symfony\Component\Console\Input\ArgvInput(), new Symfony\Component\Console\Output\ConsoleOutput()));
PHP
php scan.php --module "$MODULE" --hide-needless 1 --skip-license-check 1
SH
```

## Usage

```yaml
jobs:
  dependencies:
    name: Dependencies
    uses: samjuk/github-actions/.github/workflows/magento2-test-dependencies-module.yaml@master
```

It runs alongside static analysis, before the version matrix.
