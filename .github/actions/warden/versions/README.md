# warden/versions

Reads a project's Warden `.env` and outputs the service versions it runs.
The keys match [magento/compute-software-requirements](../../magento/compute-software-requirements/README.md), so a workflow can take its service versions from the `.env` the team already maintains instead of the Magento version manifest.

```yaml
- uses: samjuk/github-actions/.github/actions/warden/versions@master
  id: warden
  with:
    env_file: .env # default
- run: echo "PHP ${{ steps.warden.outputs.php }}, ${{ steps.warden.outputs.db_distribution }} ${{ steps.warden.outputs.mariadb }}${{ steps.warden.outputs.mysql }}"
```

| Output | Source in `.env` | Empty when |
| ------ | ---------------- | ---------- |
| `php` | `PHP_VERSION` | never |
| `composer` | `COMPOSER_VERSION` | not set |
| `node` | `NODE_VERSION` | not set |
| `db_distribution` | `MYSQL_DISTRIBUTION` | `WARDEN_DB=0` |
| `mariadb`, `mysql` | `MYSQL_DISTRIBUTION_VERSION`, then `MARIADB_VERSION` | the database is off, or is the other distribution |
| `opensearch` | `OPENSEARCH_VERSION` | `WARDEN_OPENSEARCH` is not `1` |
| `elasticsearch` | `ELASTICSEARCH_VERSION` | `WARDEN_ELASTICSEARCH` is not `1` |
| `redis` | `REDIS_VERSION` | `WARDEN_REDIS=0` |
| `valkey` | `VALKEY_VERSION` | `WARDEN_VALKEY` is not `1` |
| `nginx` | `NGINX_VERSION` | `WARDEN_NGINX=0` |
| `varnish` | `VARNISH_VERSION` | `WARDEN_VARNISH` is not `1` |
| `rabbitmq` | `RABBITMQ_VERSION` | `WARDEN_RABBITMQ` is not `1` |

Unset keys take Warden 0.16.1's defaults, including its per environment type rules: on a `magento2` environment Elasticsearch, Varnish and RabbitMQ are on unless switched off.
The file is parsed, never sourced, and the last assignment of a key wins.
