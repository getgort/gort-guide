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


Core Concepts
-------------

Dynamic configuration allows users to define one or more key-value pairs that are then injected
as variables into the execution environment of a command.

All configurations belong to a specific bundle. Configurations cannot be assigned to multiple bundles.

.. As a concrete example, let's look at Gort's `Pingdom
.. bundle <https://github.com/cogcmd/pingdom>`__. As we can
.. `see <https://github.com/cogcmd/pingdom/blob/ce0e124bd5dd75e2f50b1e9ca94a153d9ac87c13/config.yaml#L26-L32>`__,
.. the ``pingdom:check`` command expects three environment variables to be
.. set: ``PINGDOM_USER_EMAIL``, ``PINGDOM_USER_PASSWORD``, and
.. ``PINGDOM_APPLICATION_KEY``. Each of these credentials are required
.. before we can make a properly authenticated REST API request against
.. Pingdom's servers.

.. We can store these credentials in a simple YAML file and make it
.. available to Relay (we'll talk about exactly how to do that below, but
.. the details aren't important right now).

.. **Pingdom Dynamic Configuration.**

.. .. code:: YAML

..       PINGDOM_USER_EMAIL: me@mycompany.com
..       PINGDOM_USER_PASSWORD: supersecret
..       PINGDOM_APPLICATION_KEY: abcdefghijklmnopqrstuvwxyz

.. Relay will inject these values into the execution environment it builds
.. for each command in the ``pingdom`` bundle. Commands can then access
.. them as environment variables (e.g. ``ENV['PINGDOM_USER_EMAIL']`` in
.. Ruby, ``os.environ['PINGDOM_USER_EMAIL']`` in Python, etc.)

.. .. warning:: Each command in a bundle will receive the same dynamic configuration
..     environment. There is not currently a way to cause one command to
..     receive one set of variables while another receives a different set.

.. .. caution:: Any keys starting with the prefixes ``COG_`` or ``RELAY_`` will be
..     logged by Relay and ignored.

Layers
------

There are four layers:

**`bundle`**
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

Each lower level can override higher levels. Ex user can override group, can override channel, can override bundle.

Example

Managing Dynamic Configuration Values
-------------------------------------

Use the `gort config` command. 

.. There are currently two ways to manage dynamic configuration values. The
.. default method involves placing dynamic configuration YAML files on the
.. Relay host (either manually, or via the automation tooling of your
.. choice). The alternative allows Gort to centrally manage the
.. configurations on your behalf.

.. Manual Management of Dynamic Configuration
.. ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. Under manual management, a Relay will look in a directory tree to find
.. YAML files containing layered dynamic configuration values. The layers
.. will be merged as described above (``base``, then ``channel``, then
.. ``user``) and injected into the execution environment. As the files are
.. consulted on each command invocation (rather than cached), any changes
.. to the files will take effect on the next invocation of a command. This
.. is a tiny bit slower compared to caching the contents but ensures
.. commands are always run with the latest configuration.

.. To enable this mode, Relay must be told where your configuration files
.. will reside by setting the :ref:`RELAY_DYNAMIC_CONFIG_ROOT<relay_dynamic_config_root>`
.. configuration. If you are changing this value, you will need to restart
.. Relay for it to take effect.

.. Within the ``RELAY_DYNAMIC_CONFIG_ROOT`` directory, there should be a
.. directory for each bundle that needs dynamic configuration. Each of
.. these bundle directories will contain one or more YAML files (with
.. either a ``*.yaml`` or ``*.yml`` extension), with each file
.. corresponding to an individual layer. The naming conventions are as
.. follows:

.. -  base configuration layer: ``config.yaml``, always.

.. -  channel layers: ``channel_${LOWERCASE_ROOM_NAME}.yaml``. If desired, 1-on-1
..    interactions with Gort can be configured with a ``channel_direct.yaml``
..    file.

.. -  user layers: ``user_${LOWERCASE_COG_USERNAME}.yaml``

.. In the example directory tree below (which assumes a
.. ``RELAY_DYNAMIC_CONFIG_ROOT`` of ``/relay-config``), we have the
.. `heroku <https://github.com/cogcmd/heroku>`__ bundle with a single base
.. configuration, the `pingdom <https://github.com/cogcmd/pingdom>`__
.. bundle with a base layer, an "ops" channel layer, a 1-on-1 direct chat channel
.. layer, and a user layer for "chris". Finally, the
.. `twitter <https://github.com/cogcmd/twitter>`__ bundle has a single base
.. configuration layer.

.. ::

..   relay-config
..   ├── heroku
..   │   └── config.yaml
..   ├── pingdom
..   │   ├── config.yaml
..   │   ├── channel_ops.yaml
..   │   ├── channel_direct.yaml
..   │   └── user_chris.yaml
..   └── twitter
..       └── config.yaml

.. .. note::
..     *About Relays*

..     - :doc:`installing_and_managing_relays`
..     - `Annotated relay.conf <https://github.com/operable/go-relay/blob/master/example_relay.conf>`__

.. Gort-managed Dynamic Configuration
.. ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. While manually-managed dynamic configuration is simple, it can be
.. cumbersome if you run multiple Relays, or do not have filesystem access
.. to your Relay (as is the case with `Hosted
.. Gort <https://cog.operable.io>`__). In this case, you can submit your
.. dynamic configuration layer files to Gort and it will distribute the
.. values to your Relays as appropriate.

.. By default your Relay(s) already supports managed dynamic config, but
.. you can always disable it by setting :ref:`RELAY_MANAGED_DYNAMIC_CONFIG<relay_managed_dynamic_config>`
.. to ``false``. Managed Relays check in with their Gort server periodically
.. (every 5 seconds by default; see
.. :ref:`RELAY_MANAGED_DYNAMIC_CONFIG_INTERVAL<relay_managed_dynamic_config_interval>` ) to refresh their
.. configuration data.

.. .. note:: Currently, managed configuration mode requires each individual Relay
..     to be configured as such; it is not a centrally-enabled option.
..     Future versions of Gort and Relay may change this.

.. The easiest way submit configuration layers to Gort is by using
.. ``cogctl``, which in turn uses Gort's REST API.

.. .. warning:: These commands and the API they are built on *only* work for the
..     Gort-managed configuration. They will not have access to
..     manually-managed configuration files on Relay hosts. The manual
..     process is, well, *manual*.

.. Adding a base layer of dynamic configuration
.. ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. .. code:: shell

..     $ cogctl bundle config create pingdom ~/path/to/config.yaml --layer=base
..     Created base layer for 'pingdom' bundle

.. Here, the ``--layer`` option is not required; if not specified, "base"
.. is always the default.

.. Adding other layers is similar:

.. .. code:: shell

..     $ cogctl bundle config create pingdom ~/path/to/channel_ops.yaml --layer=channel/ops
..     Created channel/ops layer for 'pingdom' bundle
..     $ cogctl dynamic-config create pingdom ~/path/to/user_chris.yaml --layer=user/chris
..     Created user/chris layer for 'pingdom' bundle
..     $ cogctl dynamic-config create pingdom ~/path/to/channel_direct.yaml --layer=channel/direct
..     Created channel/direct layer for 'pingdom' bundle

.. Showing the layers that exist
.. ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. You can list all layers that are currently in place for a given bundle.

.. .. code:: shell

..     $ cogctl bundle config layers pingdom
..     base
..     channel/direct
..     channel/ops
..     user/chris

.. For any given layer, you can see the configuration that will be used.

.. .. code:: shell

..     $ cogctl bundle config info pingdom base
..     PINGDOM_USER_PASSWORD: "secret_dont_tell"
..     PINGDOM_USER_EMAIL: "cog@operable.io"
..     PINGDOM_APPLICATION_KEY: "blahblahblah"

.. Again, if you do not specify a layer, "base" is assumed. That is,
.. ``cogctl bundle config info pingdom`` is equivalent to the above command.

.. You can also see other layers:

.. .. code:: shell

..     $ cogctl bundle config info pingdom channel/ops
..     PINGDOM_USER_PASSWORD: "ops4life"
..     PINGDOM_USER_EMAIL: "cog_ops@operable.io"
..     PINGDOM_APPLICATION_KEY: "opsblahblahblah"

.. .. note::
..     | The ``cogctl bundle config info`` subcommand returns the contents
..       of *only* the specified layer; it does not show you the effective
..       configuration that might be injected into a command's execution
..       environment. You are shown exactly what was uploaded when you ran
..     |
..     | cogctl bundle config create $BUNDLE $PATH\_TO\_CONFIGURATION\_FILE --layer=$LAYER
..     |
..     | not the result of overlaying multiple layers on top of each other.

.. Deleting Configuration Layers
.. ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. Configuration layers can be deleted individually

.. .. code:: shell

..     $ cogctl bundle config delete pingdom
..     Deleted 'base' layer for bundle 'pingdom'
..     $ cogctl bundle config delete pingdom channel/ops
..     Deleted 'channel/ops' layer for bundle 'pingdom'

.. (As before, not specifying a layer defaults to operating on the ``base``
.. layer.)

.. Note that by deleting the "base" layer only deletes the base layer; any
.. channel or user layers will still be applied. If you wish to remove *all*
.. dynamic configuration, you must remove each layer individually. The
.. following pipelines may be useful:

.. .. code:: shell

..     # Remove ALL layers
..     cogctl bundle config layers pingdom | xargs -n1 cogctl bundle config delete pingdom

..     # Remove only channel layers
..     cogctl bundle config layers pingdom | grep "channel/" | xargs -n1 cogctl bundle config delete pingdom

..     # Remove only user layers
..     cogctl bundle config layers pingdom | grep "user/" | xargs -n1 cogctl bundle config delete pingdom


Future Steps
------------

Configuration files

File injection