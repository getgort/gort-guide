Quick Start
===========

This quick start page will tell you how to quickly get up and running with a very basic "development mode" Gort service running in a local container, communicating with either Slack or Discord.

The resulting service will be suitable for demo purposes only: do not use it in production!

Prerequisites
-------------

To install the demo version of Gort, you'll need the following:

* `Docker <https://docs.docker.com/get-docker/>`_ (if using ``docker compose``)

Create your Configuration File
------------------------------

.. tip::

    For more information, see: :doc:`configuration`.

1. Copy the example configuration file ``config.yml`` to ``development.yml``.

2. Make the following changes to the ``development.yml`` file:

   * Remove (or comment out) the ``kubernetes`` section.
   * If you're using Slack, remove (or comment out) the ``discord`` section.
   * If you're using Discord, remove (or comment out) the ``slack`` section.

Create Your Bot User
--------------------

Whichever chat implementation you use, you'll first have to create a bot user. Choose the section below that's appropriate for your preferred chat provider.

IMPORTANT: Both sections below involve the creation of a secret bot token. Please protect this token carefully: if someone steals it, they can make your bot do whatever they want. You don’t want that.

Create a Slack Bot User
^^^^^^^^^^^^^^^^^^^^^^^

1. If you haven't done so already, `create a new Slack workspace <https://slack.com/help/articles/206845317-Create-a-Slack-workspace>`.

2. Use this link to create a new Slack app: `<https://api.slack.com/apps?new_app=1>`. Choose to create your app "From an app manifest".

3. Select your workspace and click "Next".

4. Copy the contents of the manifest file `slackapp.yaml <https://github.com/getgort/gort/blob/main/slackapp.yaml>` into the code box below "Enter app manifest below", replacing the existing content. Click "Next".

5. Review the summary and click "Create" to create your app.

6. On the left-hand bar, under "Settings", click "Basic Information".

7. Under "App-Level Tokens", click "Generate Token and Scopes".

8. Enter a name for your token, click "Add Scope" and select "connections:write". Click "Generate".

9. Copy the app token that starts with ``xapp-`` and paste it into the ``slack`` section of your ``development.yml`` config file as ``app_token``. Click "Done".

10. On the left-hand bar, under "Settings", click "Install App".

11. You'll get a screen that says something like "Gort is requesting permission to access the $NAME Slack workspace"; click "Allow"

12. At the top of the screen, you should see "OAuth Tokens for Your Workspace" containing a "Bot User OAuth Token" that starts with ``xoxb-``. Copy that value, and paste it into the ``slack`` section of your ``development.yml`` config file as ``bot_token``.

Create a Discord Bot User
^^^^^^^^^^^^^^^^^^^^^^^^^

.. tip::

    For a more detailed walk-through, see https://www.writebots.com/discord-bot-token/.

1. Go to the Discord Developer Portal at https://discordapp.com/developers/applications/. This portal shows all of your applications and bots. Click the "New Application" button.

2. Follow the prompt to give your bot a name.

3. (Optional) If you're feeling creative, add an icon and description for your bot.

4. On the menu on the left side of the screen, click "Bot". It's the icon that looks like a little puzzle piece.

5. Click the blue "Add Bot" button, and confirm that you do, in fact, want to add your bot.

6. You should be taken to a page with a green message reading, "A wild bot has appeared!" and a "Token" field. The latter will have and a blue link you can click called "Click to Reveal Token". Click that link, and copy your bot token to your ``development.yml`` configuration file (specifically the ``bot_token`` field in your ``discord`` section).

7. Finally, in order to add your bot to your Discord Server, you'll need to navigate to the "OAuth2" tab on the left-hand menu.

8. Once there, scroll down to the "Oauth2 URL Generator" section. In the "Scopes" section, select the ``bot`` checkbox. A URL should appear at the bottom on the window: this will be your URL for adding your bot to a server.

9. Finally, scroll down to the "Bot Permissions" section and click the following checkboxes:

   * ``Send Messages``
   * ``Embed Links``
   * ``Read Message History``

10. Scroll up, copy the generated URL, and navigate to it by pasting it into a browser. Select the server to add the bot to, and confirm the selected permissions. If you get an "I'm not a robot" captcha, do what you have to do there (unless you actually are a robot).

11. You should now have successfully created a Discord Bot Token and added your own bot to a server!

Build the Gort Image (Optional)
-------------------------------

.. attention::
   This step requires that Docker be installed on your machine.

If you want to use the most absolutely bleeding-edge version of Gort, you can build your own local Gort image. If you don't mind using the stable version, you can skip this step and Docker will automatically download it for you.

To build your own local image you can use the ``make`` file included in the root of the Gort repository:

.. code:: shell

    make image

You can verify that this was successful by using the ``docker image ls`` command:

.. code:: shell

    $ docker image ls
    REPOSITORY     TAG       IMAGE ID       CREATED         SIZE
    getgort/gort   0.9.0     66fca0b90847   5 seconds ago   109MB
    getgort/gort   latest    66fca0b90847   5 seconds ago   109MB

This should indicate the presence of two images (actually, one image tagged twice) named ``getgort/gort``.

Starting Containerized Gort
---------------------------

Finally, from the root of the Gort repository, you can start Gort by using ``docker compose`` as follows:

.. code:: shell

    docker compose up

If everything works as intended, you will now be running three containers: 

1. Gort
2. Postgres (a database, to store user and bundle data)
3. Jaeger (for storing trace telemetry)

Bootstrapping Gort
------------------

.. tip::

    For more information, see: :doc:`bootstrapping`.

Before you can use Gort, you have to bootstrap it by creating the ``admin`` user.

You can do this using the ``gort bootstrap`` command and passing it the email address that your Slack provider knows you by, and the URL of the Gort controller API (by default this will be ``https://localhost:4000``):

.. code:: shell

    $ gort bootstrap --allow-insecure https://localhost:4000
    User "admin" created and credentials appended to gort config.

Because you haven't installed any TLS/SSL certificates, Gort will generate and use its own. Normally the Gort client will reject self-signed certificates, but the ``--allow-insecure`` flag turns those safeguards off.

Obviously, do not use this feature in production!

Using Gort
----------

You should now be able to use Gort in any Slack channel that includes your Gort bot. Any Gort commands should be prepended by a ``!``. For example, try typing the following in Slack:

``!help``

If everything works as expected, you should see an output something like the following:

.. image:: ../images/gort-help.png
    :alt: Gort help text

This instructs Gort to execute the ``help`` command, which is part of the ``gort`` bundle. Alternatively, you could have specified the bundle as well by typing something like:

``!gort:help user``
