Command Bundles
===============

Bundles (or "command bundles") are the packaging unit for collections of
one or more commands. They are sets of related commands that, when
installed in Gort, may be executed by users from any connected (and
allowed) chat service.

Bundle Configurations
---------------------

A bundle configuration is a `YAML <https://yaml.org/>`__-formatted
document that describes a single bundle, including its name,
description, version, `container image <commands-as-containers.md>`__,
and one or more commands. Additionally, each command definition includes
a name, description, and which binary in the container to execute when
the command is triggered by a user.

See :doc:`bundle-configurations` for more information.

Permissions and Rules
---------------------

Importantly, each command also includes one or more *rules*, which
allows operators fine-grained control over who is able to execute chat
commands, extending even to control over particular invocations of chat
commands.. Permissions are namespaced to the bundle they originate from,
so installing a bundle's permissions will never conflict with any
existing rules. Except for ``admin``, permissions are never
automatically assigned to users.

.. tip::

    See :doc:`permissions-and-rules` for more information.

Writing a Command Bundle
------------------------

Each references a single `Docker container
image <https://www.docker.com/resources/what-container>`__ that contains
all the binaries and other dependencies for executing one or more
commands. They also include some data about the commands, including a
small amount of documentation and other metadata.

.. tip::

    See :doc:`writing-a-command-bundle` for more information.

Managing Bundles
----------------

Bundles can be installed into Gort by an administrator (or any user with
the ``manage_commands`` permission) using the ``gort`` command-line
utility.

.. tip::

    See :doc:`managing-bundles` for more information.
