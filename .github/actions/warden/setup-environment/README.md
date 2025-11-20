# Warden Setup Environment

A Github Action to handle setting up a Warden Environment for local development.

This actions requires a `.env` file to be present in the repository before running. Either committed with the project, or created via the [Warden Create Environment Action](./../create-env/README.md).

## Inputs
See the [action.yml](./action.yml)

## Usage

```yaml
name: My Workflow
on:
    push:
        branches: [ master ]

jobs:
    setup-warden-environment:
        runs-on: ubuntu-latest
        steps:
            - uses: actions/checkout@v4
            - uses: samjuk/github-actions/.github/actions/warden/setup-environment@master
            # ... do other stuff
