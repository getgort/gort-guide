# Quick Start

TBD
<!--
1. Create a new Slack workspace.

2. Create a new Slack app: https://api.slack.com/apps?new_app=1 -- Click "Create New App"

You'll need to choose the app name and workspace to develop your app in.

3. Click from an app manifest.

    Select your workspace from the dropdown

    Copy/paste the following in the box labeled "Enter app manifest below"

```
_metadata:
  major_version: 1
  minor_version: 1
display_information:
  name: Gort
  description: Gort is a chatbot framework designed from the ground up for chatops.
  background_color: "#AAAAAA"
features:
  app_home:
    home_tab_enabled: true
    messages_tab_enabled: true
    messages_tab_read_only_enabled: false
  bot_user:
    display_name: gort
    always_online: true
oauth_config:
  scopes:
    bot:
      - app_mentions:read
      - calls:read
      - calls:write
      - channels:history
      - channels:join
      - channels:manage
      - channels:read
      - chat:write
      - chat:write.customize
      - chat:write.public
      - commands
      - dnd:read
      - emoji:read
      - groups:history
      - groups:read
      - groups:write
      - im:history
      - im:read
      - im:write
      - incoming-webhook
      - links:read
      - links:write
      - mpim:history
      - mpim:read
      - mpim:write
      - reactions:read
      - reactions:write
      - reminders:read
      - reminders:write
      - remote_files:read
      - remote_files:share
      - remote_files:write
      - team:read
      - usergroups:read
      - usergroups:write
      - users.profile:read
      - users:read
      - users:read.email
      - users:write
    user:
      - calls:read
      - calls:write
      - channels:history
      - channels:read
      - channels:write
      - chat:write
      - dnd:read
      - dnd:write
      - emoji:read
      - files:read
      - files:write
      - groups:history
      - groups:read
      - groups:write
      - identity.avatar
      - identity.basic
      - identity.email
      - identity.team
      - im:history
      - im:read
      - im:write
      - links:read
      - links:write
      - mpim:history
      - mpim:read
      - mpim:write
      - pins:read
      - pins:write
      - reactions:read
      - reactions:write
      - search:read
      - stars:read
      - stars:write
      - team:read
      - usergroups:read
      - usergroups:write
      - users.profile:read
      - users.profile:write
      - users:read
      - users:read.email
      - users:write
```




2. In box labeled "Building Apps for Slack", section "Install your app", click "Install to Workspace"

You'll get a screen that says something like "Gort is requesting permission to access the $NAME Slack workspace"; click "Allow"

On left-hand bar, click "OAuth & Permissions". 

At the top of the screen, you should see "OAuth Tokens for Your Workspace" containing a "Bot User OAuth Token" that starts with `xoxb-`. 

Copy that value, and paste it into your config YAML





Get  "Bot User OAuth Token"

## Development Mode



 -->
