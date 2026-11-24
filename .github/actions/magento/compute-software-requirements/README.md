# Magento Compute Software Requirements

A Github Action to handle computing software requirements for use with a certain version of Magento.

Versions live in `manifest.json`, synced weekly from [magento-compatability](https://github.com/SamJUK/magento-compatability).
`database` and `cache` choose the PHPUnit services; MySQL and Redis when unset.

## Inputs

See the [action.yaml](./action.yaml)

## Usage

```yaml
name: My Workflow
on:
  push:
    branches: [ master ]

jobs:
  compute-software-requirements:
    runs-on: ubuntu-latest
    outputs:
      php: ${{ steps.compute-software-requirements.outputs.php }}
      # One output per manifest key, plus database_image and cache_image: see action.yaml
    steps:
      - name: Compute Software Requirements
        id: compute-software-requirements
        uses: samjuk/github-actions/.github/actions/magento/compute-software-requirements@master
        with:
          magento_version: ${{ inputs.magento_version }}

  debug:
    needs: compute-software-requirements
    runs-on: ubuntu-latest
    steps:
      - run: echo "PHP ${{ needs.compute-software-requirements.outputs.php }}"
```