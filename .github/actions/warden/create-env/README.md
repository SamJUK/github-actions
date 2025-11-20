# Warden Create Environment

A Github Action to handle creating a Warden Environment file for standing up a new Warden environment.


## Inputs

See the [action.yml](./action.yml)

## Usage

```yaml
name: My Workflow
on:
  push:
    branches: [ master ]

jobs:
    create-warden-environment:
        runs-on: ubuntu-latest
        steps:
            - name: Create Warden Environment
              id: create-warden-environment
              uses: samjuk/github-actions/.github/actions/warden/create-env@master
              with:
                  php_version: '8.3'
                  mysql_version: '8.0'
                  elasticsearch_version: '7.10.2'
            # ... do other stuff
```