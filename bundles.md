# Command Bundles

Command bundles are a set of related commands built into a Docker image or executed natively on the worker. Each bundle includes a list of the specific commands that can be executed, and a set of permission rules required to execute each command.

Command bundles can only be installed by an adequately-privileged user (generally an administrator). 

## Installing Command Bundles

Command bundles can be "default", in which case they're defined in the Gort configuration, or "installed", in which case they're explicitly installed by an administrator.

### Default Bundles

Automatically enabled.

```yaml
bundles:
- name: test
  description: A test bundle.
  long_description: >
    This is test bundle.
    There are many like it, but this one is mine.

  permissions:
    - test:echo
    - test:test

  docker:
    image: clockworksoul/relaytest
    tag: latest

  commands:
    echo:
      description: "Echos back anything sent to it, all at once."
      executable: "/bin/echo"
```

### Explicitly Installed Bundles

`gortctl install bundle`

Similar YML definition format to default bundles.

```yaml
---
gort_bundle_version: 1

name: test
version: 0.0.1
author: Matt Titmus <matthew.titmus@gmail.com>
homepage: https://github.com/clockworksoul/gort
description: A test bundle.
long_description: >
  This is test bundle.
  There are many like it, but this one is mine.

permissions:
  - test:echo
  - test:test

docker:
  image: ubuntu
  tag: 20.04

commands:
  echo:
    description: "Echos back anything sent to it, all at once."
    executable: "/bin/echo"
    rules:
      - must have test:echo
```

Disabled by default.

## Command Permissions
