# Command Bundles

A command bundle is a set of related commands that, when installed in Gort, may be executed by users from any connected (and allowed) chat service. It specifies which binary to execute, who may execute the commands (i.e., which users with which permissions), and which relay should execute it.

*Currently, Gort only supports commands that have been built into a Docker image, but a future iteration will support the execution of commands natively on a relay's host.*

## Installing Command Bundles

Command bundles can installed "by default" by including them in the Gort configuration, or explicitly installed by an administrator.

The YAML used for each of these cases is nearly identical, and includes the following sections:

* **The name and description.** This name is how the bundle will be referenced both via user commands and internally, so it has to be unique to an installation. Attempting to install a command bundle with the same name will result in an error.

* **Docker image.** The Docker image that contains all of the bundle's commands. One image per bundle.

* **Permissions.** A list of the permissions (arbitrary strings, at this point) utilized by this bundle.

* **A list of commands.** Zero or more commands that can be invoked in the bundle and their associated executables. The command name, as defined here, will be the command invoked by users; it doesn't have to match the name of the binary.

### Default Bundles

Default bundles are automatically installed by including them in the `bundles` section of the Gort configuration, as follows:

```yaml
bundles:
- name: test
  description: A test bundle.
  long_description: >
    This is test bundle.
    There are many like it, but this one is mine.

  docker:
    image: clockworksoul/relaytest
    tag: latest

  permissions:
    - echo

  commands:
    echo:
      description: "Echos back anything sent to it, all at once."
      executable: "/bin/echo"
      rules:
        - must have test:echo
```

As the name "default" suggests, bundles installed this way don't have to be installed by an administrator. They are also automatically enabled.

### Explicitly Installed Bundles

Command bundles can only be installed by an adequately-privileged user (generally an administrator). 

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
  - echo

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


## Enabling and Disabling Bundles
