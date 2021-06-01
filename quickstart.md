# Quick Start

## Creating a Slack Bot User

1. If you haven't done so already, create a new Slack workspace.

1. Use this link to create a new Slack (Classic) app: https://api.slack.com/apps?new_classic_app=1. Choose your application name and select the workspace you just created, and click "Create App".

1. Under "Add features and functionality", click "Bots". This will bring you to "App Home".

1. Click the "Add Legacy Bot User" button. Enter the display name and username, and click "Add".

1. On the left-hand bar, under "Settings", click "Basic Information", then click the "Install to Workspace" button.

1. You'll get a screen that says something like "Gort is requesting permission to access the $NAME Slack workspace"; click "Allow"

1. On left-hand bar, under "Features", click "OAuth & Permissions".

1. At the top of the screen, you should see "OAuth Tokens for Your Workspace" containing a "Bot User OAuth Token" that starts with `xoxb-`. Copy that value, and paste it into the `slack` section of your config as the `api_token`.

You should now be ready to begin using Gort!

## Development Mode

TBD