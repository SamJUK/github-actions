# Magento Compute Software Requirements

A Github Action to handle computing software requirements for use with a certain version of Magento.

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
      composer: ${{ steps.compute-software-requirements.outputs.composer }}
      php: ${{ steps.compute-software-requirements.outputs.php }}
      mysql: ${{ steps.compute-software-requirements.outputs.mysql }}
      mariadb: ${{ steps.compute-software-requirements.outputs.mariadb }}
      elasticsearch: ${{ steps.compute-software-requirements.outputs.elasticsearch }}
      opensearch: ${{ steps.compute-software-requirements.outputs.opensearch }}
      redis: ${{ steps.compute-software-requirements.outputs.redis }}
      valkey: ${{ steps.compute-software-requirements.outputs.valkey }}
      apache: ${{ steps.compute-software-requirements.outputs.apache }}
      nginx: ${{ steps.compute-software-requirements.outputs.nginx }}
      varnish: ${{ steps.compute-software-requirements.outputs.varnish }}
      rabbitmq: ${{ steps.compute-software-requirements.outputs.rabbitmq }}
      activemq_artemis: ${{ steps.compute-software-requirements.outputs.activemq_artemis }}
    steps:
      - name: Checkout Local Actions
        uses: actions/checkout@v4
      - name: Compute Software Requirements
        id: compute-software-requirements
        uses: samjuk/github-actions/.github/actions/magento/compute-software-requirements@master
        with:
          magento_version: ${{ inputs.magento_version }}

  debug:
    needs: compute-software-requirements
    runs-on: ubuntu-latest
    steps:
      - run: |
          echo "Deploying environment with the following software versions"
          echo "Composer: ${{ needs.compute-software-requirements.outputs.composer }}"
          echo "PHP: ${{ needs.compute-software-requirements.outputs.php }}"
          echo "MySQL: ${{ needs.compute-software-requirements.outputs.mysql }}"
          echo "MariaDB: ${{ needs.compute-software-requirements.outputs.mariadb }}""
```