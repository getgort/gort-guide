Dynamic Command Configuration
=============================

Commands often require access to runtime variables, particularly when interacting with external
services, ranging from mundane values (like the URL of a downstream resource) to highly sensitive
information (like database passwords or access tokens).

One (terrible) way of providing these values to a command might be baking them into the
bundle's container image, but that has two problems:

#. It limits command reusability by requiring all users to use the same configuration.
#. It creates a security risk by making potentially sensitive values accessible to anybody who with access to the image.

*Dynamic command configuration* solves this problem by making it possible to securely store
configuration information so that it can be injected into worker containers at runtime as
specifically-named environment variables or files.

.. note:: Dynamic command configuration shouldn't
    be confused with the :doc:`config.yaml <bundle-configurations>` file
    that defines the commands, rules, and permissions present in each
    command bundle. That configuration is effectively static. The
    configuration we are concerned with is for the *execution* of
    individual commands.

    It's also dynamic in the sense that it can be changed on-the-fly
    by Gort administrators, with the changes taking effect nearly
    instantaneously without restarting any applications.

.. warning:: Currently dynamic configurations can only be stored in plain text in the Gort
    database. While a secure backend is currently in development, it is currently recommended
    that dynamic configuration not be used to inject highly sensitive values.


Core Concepts
-------------

Dynamic configuration allows users to define one or more key-value pairs that are injected
as variables into the execution environment of a command. The key is usually a simple name, like
"url" or "email".

.. note:: All configurations belong to a specific bundle. Dynamic configurations cannot be
    assigned to multiple bundles.

The actual environment variable name is constructed by converting this key into an all-caps name
using the pattern ``BUNDLE_KEY``. Dashes are also converted into underscores.

For example, a dynamic configuration named "user-email" that belongs to the "testing" bundle will
be injected into the command environment as ``TESTING_USER_EMAIL``.

A command can then access it as an environment variable (e.g. ``ENV['TESTING_USER_EMAIL']`` in
Ruby, ``os.environ['TESTING_USER_EMAIL']`` in Python, etc.)

.. warning:: Each command in a bundle will receive the same dynamic configuration
    environment. There is not currently a way to allow one command to
    receive one set of variables while another receives a different set.


Layers
------

There are four layers:

**bundle**
    Configurations at the *bundle* layer are applied to all of the commands in its respective
    :doc:`command bundle <commands-and-bundles>`. This layer can be overridden by any other layer.

**channel**
    Configurations made at the *channel* layer are applied to all commands in its bundle executed
    in a specific channel. This layer can override *bundle* layer configurations, and can in turn be
    overridden by *group* or *user* layer configurations.

**group**
    Configurations made at the *group* layer are applied to all commands in its bundle executed
    by a given :ref:`group <section-permissions-groups>`. This layer can override *bundle* and
    *channel* layer configurations, and can be overridden by *user* layer.

**user**
    Configurations made at the *user* layer are applied to all commands in its bundle executed
    by a particular :ref:`user <section-users>`. This layer can be override any other layer.


Layer Overriding
^^^^^^^^^^^^^^^^

For any given bundle, the same configuration can be defined in multiple layers. In this case, 
the layer with the highest precedence is the one that's used.

The layer precedence order is as follows:

1. User
2. Group
3. Channel
4. Bundle

This allows you to, for example, define a default set of user credentials at the bundle level
while allowing a specific group and even specific users to define their own credentials for more
specialized purposes.


Managing Dynamic Configuration Values
-------------------------------------

Dynamic configurations can be managed using the `gort config` commands. There are three:

1. ``gort config get``: Used to retrieve one or more non-secret configuration values.
2. ``gort config set``: Used to create or update a configuration value.
3. ``gort config delete``: Used to delete a configuration value.

The flags accepted by each of these commands are 

+--------------------------------+----------+----------+----------+--------------------------------------------------------------------------------------------+
| Flags                          | Get      | Set      | Delete   | Description                                                                                |
+================================+==========+==========+==========+============================================================================================+
| ``-b bundle, --bundle=bundle`` | Required | Required | Required | The name of the bundle to configure.                                                       |
+--------------------------------+----------+----------+----------+--------------------------------------------------------------------------------------------+
| ``-l layer, --layer=layer``    | Optional | Optional | Optional | One of: ``bundle``, ``channel``, ``group``, ``user``. Default: ``bundle``.                 |
+--------------------------------+----------+----------+----------+--------------------------------------------------------------------------------------------+
| ``-o owner, --owner=owner``    | Required | Required | Required | The owning channel, group, or user.                                                        |
+--------------------------------+----------+----------+----------+--------------------------------------------------------------------------------------------+
| ``-k key, --key=key``          | Required | Required | Required | The name of the configuration.                                                             |
+--------------------------------+----------+----------+----------+--------------------------------------------------------------------------------------------+
| ``-s, --secret``               | n/a      | Optional | n/a      | Makes a configuration value secret. secret values cannot be read using ``got config get``. |
+--------------------------------+----------+----------+----------+--------------------------------------------------------------------------------------------+

.. Here, the ``--layer`` option is not required; if not specified, "base"
.. is always the default.

.. Adding other layers is similar:

.. .. code:: shell

..     $ gort bundle config create pingdom ~/path/to/channel_ops.yaml --layer=channel/ops
..     Created channel/ops layer for 'pingdom' bundle
..     $ gort dynamic-config create pingdom ~/path/to/user_chris.yaml --layer=user/chris
..     Created user/chris layer for 'pingdom' bundle
..     $ gort dynamic-config create pingdom ~/path/to/channel_direct.yaml --layer=channel/direct
..     Created channel/direct layer for 'pingdom' bundle

.. Showing the layers that exist
.. ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. You can list all layers that are currently in place for a given bundle.

.. .. code:: shell

..     $ gort bundle config layers pingdom
..     base
..     channel/direct
..     channel/ops
..     user/chris

.. For any given layer, you can see the configuration that will be used.

.. .. code:: shell

..     $ gort bundle config info pingdom base
..     PINGDOM_USER_PASSWORD: "secret_dont_tell"
..     PINGDOM_USER_EMAIL: "cog@operable.io"
..     PINGDOM_APPLICATION_KEY: "blahblahblah"

.. Again, if you do not specify a layer, "base" is assumed. That is,
.. ``gort bundle config info pingdom`` is equivalent to the above command.

.. You can also see other layers:

.. .. code:: shell

..     $ gort bundle config info pingdom channel/ops
..     PINGDOM_USER_PASSWORD: "ops4life"
..     PINGDOM_USER_EMAIL: "cog_ops@operable.io"
..     PINGDOM_APPLICATION_KEY: "opsblahblahblah"

.. .. note::
..     | The ``gort bundle config info`` subcommand returns the contents
..       of *only* the specified layer; it does not show you the effective
..       configuration that might be injected into a command's execution
..       environment. You are shown exactly what was uploaded when you ran
..     |
..     | gort bundle config create $BUNDLE $PATH\_TO\_CONFIGURATION\_FILE --layer=$LAYER
..     |
..     | not the result of overlaying multiple layers on top of each other.

.. Deleting Configuration Layers
.. ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. Configuration layers can be deleted individually

.. .. code:: shell

..     $ gort bundle config delete pingdom
..     Deleted 'base' layer for bundle 'pingdom'
..     $ gort bundle config delete pingdom channel/ops
..     Deleted 'channel/ops' layer for bundle 'pingdom'

.. (As before, not specifying a layer defaults to operating on the ``base``
.. layer.)

.. Note that by deleting the "base" layer only deletes the base layer; any
.. channel or user layers will still be applied. If you wish to remove *all*
.. dynamic configuration, you must remove each layer individually. The
.. following pipelines may be useful:

.. .. code:: shell

..     # Remove ALL layers
..     gort bundle config layers pingdom | xargs -n1 gort bundle config delete pingdom

..     # Remove only channel layers
..     gort bundle config layers pingdom | grep "channel/" | xargs -n1 gort bundle config delete pingdom

..     # Remove only user layers
..     gort bundle config layers pingdom | grep "user/" | xargs -n1 gort bundle config delete pingdom


Future Steps
------------

This feature is in a state of minimal viability, and many new features are planned for it. Including:

1. The development of an optional secure backend. Initially this will support Hashicorp Vault.
2. Allowing configuration value to be defined as code.
3. Allowing configuration values to be injected as files (and not just environment variables).