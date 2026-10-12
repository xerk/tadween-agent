<p align="center">
  <img src="assets/logo.svg" alt="Tadween" width="96" />
</p>

<p align="center">
  <strong>Schedule posts with agents to:</strong><br />
  <a href="https://tadween.app/chatgpt">ChatGPT</a> ·
  <a href="https://tadween.app/claude">Claude</a> ·
  <a href="https://tadween.app/cursor">Cursor</a> ·
  <a href="https://tadween.app/ai-agent">Claude Code, Codex, Gemini CLI and other MCP clients</a> ·
  <a href="https://tadween.app/ai-agent">AI Agents CLI</a>
</p>

> Tadween CLI and agent skill. Based on [Postiz](https://github.com/gitroomhq/postiz-agent) by gitroomhq, licensed under AGPL-3.0 (see [LICENSE](LICENSE)). Tadween is a product of Xerk LLC.

## Install as a skill

```bash
npx skills add xerk/tadween-agent
```

### Claude Code plugin

```bash
/plugin marketplace add xerk/tadween-agent
/plugin install tadween@tadween-agent
```

### Grok Build plugin

This repo carries its own `.grok-plugin/plugin.json` manifest and `.grok-plugin/marketplace.json` catalog, so it can be added to Grok Build as a marketplace source directly.

The Grok plugin also bundles the hosted Tadween MCP server (`https://studio.tadween.app/mcp-oauth-dynamic`) via the `mcpServers` field in `.grok-plugin/plugin.json` — you'll be asked to sign in to Tadween on first connection; no token or local install needed. The Claude Code and Cursor plugins are skill/CLI-only and do not register an MCP server.

### Cursor plugin

This repo ships a [Cursor plugin](https://cursor.com/docs/reference/plugins) manifest at `.cursor-plugin/plugin.json`.

- **Local install (development):**

  ```bash
  git clone https://github.com/xerk/tadween-agent.git
  ln -s "$(pwd)/tadween-agent" ~/.cursor/plugins/local/tadween
  ```

  then restart Cursor or run **Developer: Reload Window**.

The plugin exposes the `tadween` skill, which drives the `tadween` CLI (the CLI handles media uploads, which is required for image/video posts). Make sure the CLI is installed (`npm install -g tadween`) and authenticated (`tadween auth:login` or `export TADWEEN_API_KEY=...`) before asking the agent to post.

### Gemini CLI extension

This repo is a [Gemini CLI extension](https://geminicli.com/docs/extensions/) (`gemini-extension.json` at the root).

```bash
gemini extensions install https://github.com/xerk/tadween-agent
```

It installs the `tadween` skill and the hosted Tadween MCP server (`https://studio.tadween.app/mcp-oauth-dynamic`). Gemini CLI opens a browser to sign in to Tadween on first use; run `/mcp auth tadween` to re-authenticate. The skill drives the `tadween` CLI for media uploads, so install it with `npm install -g tadween` for image or video posts.

### Qwen Code

Qwen Code installs Claude Code marketplaces directly, so no separate manifest is needed:

```bash
qwen extensions install xerk/tadween-agent:tadween
```

### DeepSeek Harness plugin

This repo ships a [DeepSeek Harness](https://github.com/deepseek-ai/deepseek-harness) (`dsh`) bundle at [`plugins/dsh-tadween`](plugins/dsh-tadween). It connects the agent to the hosted Tadween MCP server and registers a `tadween` workflow skill.

```bash
dsh plugin --profile web add "github:xerk/tadween-agent#path:/plugins/dsh-tadween"
export TADWEEN_API_KEY=your-api-key   # Tadween → Settings → API & MCP
dsh web
```

The Tadween tools then appear as `mcp__tadween__*` (`integrationList`, `integrationSchema`, `schedulePostTool`, ...). Self-hosted instances override `baseUrl` on the `tadween` row. See the [plugin README](plugins/dsh-tadween/README.md) for configuration.

# Tadween CLI

**Social media automation CLI for AI agents** - Schedule posts across 28+ platforms programmatically.

The Tadween CLI provides a command-line interface to the Tadween API, enabling developers and AI agents to automate social media posting, manage content, and handle media uploads across platforms like Twitter/X, LinkedIn, Reddit, YouTube, TikTok, Instagram, Facebook, and more.

---

## Installation

### From npm (Recommended)

```bash
npm install -g tadween
# or
pnpm install -g tadween
```

---

## Authentication

### Option 1: OAuth2 (Recommended)

Authenticate using the device flow — no client ID or secret needed:

```bash
tadween auth:login
```

This will:
1. Display a one-time code in your terminal
2. Open your browser to authorize
3. Automatically save credentials to `~/.tadween/credentials.json`

```bash
# Check current auth status (verifies credentials are still valid)
tadween auth:status

# Remove stored credentials
tadween auth:logout
```

#### Self-Hosting the Auth Server

By default, `tadween auth:login` uses the auth server at `cli-auth.tadween.app` (override with `--auth-server` or `TADWEEN_AUTH_SERVER`). If you want to self-host the OAuth2 device flow server, follow the guide in [`server/SERVER.md`](./server/SERVER.md).

### Option 2: API Key

```bash
export TADWEEN_API_KEY=your_api_key_here
```

**Optional:** Custom API endpoint

```bash
export TADWEEN_API_URL=https://studio.tadween.app/api   # default; set it for a self-hosted instance
```

> **Note:** OAuth2 credentials take priority over the API key when both are present.

---

## Commands

### Discovery & Settings

**List all connected integrations**
```bash
tadween integrations:list
tadween integrations:list --group "customer-id"
```

Returns integration IDs, provider names, and metadata. Use `--group` to return only the channels assigned to a specific group (customer).

**List all groups (customers)**
```bash
tadween integrations:groups
```

Returns all groups (customers) for your organization as `{id, name}`. Use a group's `id` with `integrations:list --group` to filter channels.

**Get integration settings schema**
```bash
tadween integrations:settings <integration-id>
```

Returns character limits, required settings, and available tools for fetching dynamic data.

**Trigger integration tools**
```bash
tadween integrations:trigger <integration-id> <method-name>
tadween integrations:trigger <integration-id> <method-name> -d '{"key":"value"}'
```

Fetch dynamic data like Reddit flairs, YouTube playlists, LinkedIn companies, etc.

**Examples:**
```bash
# Get Reddit flairs
tadween integrations:trigger reddit-123 getFlairs -d '{"subreddit":"programming"}'

# Get YouTube playlists
tadween integrations:trigger youtube-456 getPlaylists

# Get LinkedIn companies
tadween integrations:trigger linkedin-789 getCompanies
```

---

### Creating Posts

**Simple scheduled post**
```bash
tadween posts:create -c "Content" -s "2024-12-31T12:00:00Z" -i "integration-id"
```

**Draft post**
```bash
tadween posts:create -c "Content" -s "2024-12-31T12:00:00Z" -t draft -i "integration-id"
```

**Post with media**
```bash
tadween posts:create -c "Content" -m "img1.jpg,img2.jpg" -s "2024-12-31T12:00:00Z" -i "integration-id"
```

**Post with comments** (each comment can have its own media)
```bash
tadween posts:create \
  -c "Main post" -m "main.jpg" \
  -c "First comment" -m "comment1.jpg" \
  -c "Second comment" -m "comment2.jpg,comment3.jpg" \
  -s "2024-12-31T12:00:00Z" \
  -i "integration-id"
```

**Multi-platform post**
```bash
tadween posts:create -c "Content" -s "2024-12-31T12:00:00Z" -i "twitter-id,linkedin-id,facebook-id"
```

**Platform-specific settings**
```bash
tadween posts:create \
  -c "Content" \
  -s "2024-12-31T12:00:00Z" \
  --settings '{"subreddit":[{"value":{"subreddit":"programming","title":"Post Title","type":"text"}}]}' \
  -i "reddit-id"
```

**Complex post from JSON file**
```bash
tadween posts:create --json post.json
```

**Options:**
- `-c, --content` - Post/comment content (use multiple times for posts with comments)
- `-s, --date` - Schedule date in ISO 8601 format (REQUIRED)
- `-t, --type` - Post type: "schedule" or "draft" (default: "schedule")
- `-m, --media` - Comma-separated media URLs for corresponding `-c`
- `-i, --integrations` - Comma-separated integration IDs (required)
- `-d, --delay` - Delay between comments in minutes (default: 0)
- `--settings` - Platform-specific settings as JSON string
- `-j, --json` - Path to JSON file with full post structure
- `--shortLink` - Use short links (default: true)

---

### Managing Posts

**List posts**
```bash
tadween posts:list
tadween posts:list --startDate "2024-01-01T00:00:00Z" --endDate "2024-12-31T23:59:59Z"
tadween posts:list --customer "customer-id"
```

Defaults to last 30 days to next 30 days if dates not specified. Each returned post includes its current `settings` (returned as a JSON string — `JSON.parse` it). The intended workflow is `posts:list` (read current settings) → `posts:settings` (patch them).

**Delete post**
```bash
tadween posts:delete <post-id>
```

**Change post status (draft ↔ schedule)**
```bash
tadween posts:status <post-id> --status draft
tadween posts:status <post-id> --status schedule
```

Move a scheduled post back to a draft, or promote a draft into the publishing queue. Switching to `draft` also terminates any workflow that's already running for the post, so it won't publish. Switching to `schedule` queues the post for publishing at its stored date.

**Update a post's provider-specific settings**
```bash
tadween posts:settings <post-id> --settings '{"content_posting_method":"DIRECT_POST"}'
tadween posts:settings <post-id> --settings '{"subreddit":[{"value":{"subreddit":"/r/selfhosted","title":"My title","type":"self","is_flair_required":true}}]}'
```

Patches a post's settings server-side. The backend **merges** the object — only the keys you pass change, everything else is preserved — so pass a partial object, not the full settings blob. Only **DRAFT/QUEUE** (unpublished) posts can be updated; published posts are rejected. Pass the **main post id**, not a comment id. Do **not** include `__type` — the backend adds it automatically from the integration.

---

### Analytics

**Get platform analytics**
```bash
tadween analytics:platform <integration-id>
tadween analytics:platform <integration-id> -d 30
```

Returns metrics like followers, impressions, and engagement over time for a specific integration/channel. The `-d` flag specifies the number of days to look back (default: 7).

**Get post analytics**
```bash
tadween analytics:post <post-id>
tadween analytics:post <post-id> -d 30
```

Returns metrics like likes, comments, shares, and impressions for a specific published post.

**⚠️ If `analytics:post` returns `{"missing": true}`**, the post was published but the platform didn't return a usable post ID. You must resolve this before analytics will work:

```bash
# 1. List available content from the provider
tadween posts:missing <post-id>

# 2. Connect the correct content to the post
tadween posts:connect <post-id> --release-id "7321456789012345678"

# 3. Analytics will now work
tadween analytics:post <post-id>
```

---

### Connecting Missing Posts

Some platforms (e.g. TikTok) don't return a post ID immediately after publishing. The post's `releaseId` is set to `"missing"` and analytics won't work until resolved.

**List available content from the provider**
```bash
tadween posts:missing <post-id>
```

Returns an array of `{id, url}` items representing recent content from the provider. Returns an empty array if the provider doesn't support this feature.

**Connect a post to its published content**
```bash
tadween posts:connect <post-id> --release-id "<content-id>"
```

---

### Media Upload

**Upload file and get URL**
```bash
tadween upload <file-path>
```

**⚠️ IMPORTANT: Upload Files Before Posting**

You **must** upload media files to Tadween before using them in posts. Many platforms (especially TikTok, Instagram, and YouTube) require verified/trusted URLs and will reject external links.

**Workflow:**
1. Upload your file using `tadween upload`
2. Extract the returned URL
3. Use that URL in your post's `-m` parameter

**Supported formats:**
- **Images:** PNG, JPG, JPEG, GIF
- **Videos:** MP4

**Example:**
```bash
# 1. Upload the file first
RESULT=$(tadween upload video.mp4)
PATH=$(echo "$RESULT" | jq -r '.path')

# 2. Use the Tadween URL in your post
tadween posts:create -c "Check out my video!" -s "2024-12-31T12:00:00Z" -m "$PATH" -i "tiktok-id"
```

**Why this is required:**
- **TikTok, Instagram, YouTube** only accept URLs from trusted domains
- **Security:** Platforms verify media sources to prevent abuse
- **Reliability:** Tadween ensures your media is always accessible

---

### Clipping

Turn a long YouTube video into short vertical clips with burned-in captions. The best parts are picked automatically and every clip is saved to your media library. Pass integrations to also get a **draft** post per clip on every channel (nothing is scheduled or published).

**Start a clipping**
```bash
tadween clipping:create "https://www.youtube.com/watch?v=VIDEO_ID"
tadween clipping:create "https://www.youtube.com/watch?v=VIDEO_ID" -n 3 -f crop -i "tiktok-id,instagram-id"
```

| Option | Alias | Description |
|--------|-------|-------------|
| `--integrations` | `-i` | Comma-separated integration IDs to create a draft post for every clip |
| `--clips` | `-n` | Maximum number of clips, 1-10 (default: 5) |
| `--fit` | `-f` | `blur` (default) keeps the whole picture over a blurred copy of itself, `crop` fills the clip and cuts the sides |

Returns `{"id": "<clipping-id>"}` right away — clipping takes several minutes.

**Check the status and get the clips**
```bash
tadween clipping:status <clipping-id>
```

The `status` moves through `analysing`, `transcribing` (only when the video has no usable captions), `picking` and `rendering`, and ends on `completed` or `failed`. When completed, every clip carries its `title`, `content`, hosted video `path` and `thumbnail`. When failed, `error` says why and the clipping minutes are given back.

**List clippings**
```bash
tadween clipping:list
tadween clipping:list --page 2
```

Clipping uses the clipping minutes of your subscription: one minute for every minute of the source video. Only one clipping runs at a time per account.

---

## Platform-Specific Features

### Reddit
```bash
# Get available flairs
tadween integrations:trigger reddit-id getFlairs -d '{"subreddit":"programming"}'

# Post with subreddit and flair
tadween posts:create \
  -c "Content" \
  -s "2024-12-31T12:00:00Z" \
  --settings '{"subreddit":[{"value":{"subreddit":"programming","title":"My Post","type":"text","is_flair_required":true,"flair":{"id":"flair-123","name":"Discussion"}}}]}' \
  -i "reddit-id"
```

### YouTube
```bash
# Get playlists
tadween integrations:trigger youtube-id getPlaylists

# Upload video FIRST (required!)
VIDEO=$(tadween upload video.mp4)
VIDEO_URL=$(echo "$VIDEO" | jq -r '.path')

# Post with uploaded video URL
tadween posts:create \
  -c "Video description" \
  -s "2024-12-31T12:00:00Z" \
  --settings '{"title":"Video Title","type":"public","tags":[{"value":"tech","label":"Tech"}],"playlistId":"playlist-id"}' \
  -m "$VIDEO_URL" \
  -i "youtube-id"
```

### TikTok
```bash
# Upload video FIRST (TikTok only accepts verified URLs!)
VIDEO=$(tadween upload video.mp4)
VIDEO_URL=$(echo "$VIDEO" | jq -r '.path')

# Post with uploaded video URL
tadween posts:create \
  -c "Video caption #fyp" \
  -s "2024-12-31T12:00:00Z" \
  --settings '{"privacy_level":"PUBLIC_TO_EVERYONE","duet":true,"stitch":true,"content_posting_method":"DIRECT_POST"}' \
  -m "$VIDEO_URL" \
  -i "tiktok-id"
```

### LinkedIn
```bash
# Get companies you can post to
tadween integrations:trigger linkedin-id getCompanies

# Post as company
tadween posts:create \
  -c "Company announcement" \
  -s "2024-12-31T12:00:00Z" \
  --settings '{"companyId":"company-123"}' \
  -i "linkedin-id"
```

### X (Twitter)
```bash
# Create thread
tadween posts:create \
  -c "Thread 1/3 🧵" \
  -c "Thread 2/3" \
  -c "Thread 3/3" \
  -s "2024-12-31T12:00:00Z" \
  -d 2000 \
  -i "twitter-id"

# With reply settings
tadween posts:create \
  -c "Tweet content" \
  -s "2024-12-31T12:00:00Z" \
  --settings '{"who_can_reply_post":"everyone"}' \
  -i "twitter-id"
```

### Instagram
```bash
# Upload image FIRST (Instagram requires verified URLs!)
IMAGE=$(tadween upload image.jpg)
IMAGE_URL=$(echo "$IMAGE" | jq -r '.path')

# Regular post
tadween posts:create \
  -c "Caption #hashtag" \
  -s "2024-12-31T12:00:00Z" \
  --settings '{"post_type":"post"}' \
  -m "$IMAGE_URL" \
  -i "instagram-id"

# Story (upload first)
STORY=$(tadween upload story.jpg)
STORY_URL=$(echo "$STORY" | jq -r '.path')

tadween posts:create \
  -c "" \
  -s "2024-12-31T12:00:00Z" \
  --settings '{"post_type":"story"}' \
  -m "$STORY_URL" \
  -i "instagram-id"
```

**See [PROVIDER_SETTINGS.md](./PROVIDER_SETTINGS.md) for all 28+ platforms.**

---

## Features for AI Agents

### Discovery Workflow
The CLI enables dynamic discovery of integration capabilities:

1. **List integrations** - Get available social media accounts
2. **Get settings** - Retrieve character limits, required fields, and available tools
3. **Trigger tools** - Fetch dynamic data (flairs, playlists, boards, etc.)
4. **Create posts** - Use discovered data in posts
5. **Analyze** - Get post analytics; if `{"missing": true}` is returned, resolve with `posts:missing` + `posts:connect`

This allows AI agents to adapt to different platforms without hardcoded knowledge.

### JSON Mode
For complex posts with multiple platforms and settings:

```bash
tadween posts:create --json complex-post.json
```

JSON structure:
```json
{
  "integrations": ["twitter-123", "linkedin-456"],
  "posts": [
    {
      "provider": "twitter",
      "post": [
        {
          "content": "Tweet version",
          "image": ["twitter-image.jpg"]
        }
      ]
    },
    {
      "provider": "linkedin",
      "post": [
        {
          "content": "LinkedIn version with more context...",
          "image": ["linkedin-image.jpg"]
        }
      ],
      "settings": {
        "__type": "linkedin",
        "companyId": "company-123"
      }
    }
  ]
}
```

### All Output is JSON
Every command outputs JSON for easy parsing:

```bash
INTEGRATIONS=$(tadween integrations:list | jq -r '.')
REDDIT_ID=$(echo "$INTEGRATIONS" | jq -r '.[] | select(.identifier=="reddit") | .id')
```

### Threading Support
Comments are automatically converted to threads/replies based on platform:
- **Twitter/X**: Thread of tweets
- **Reddit**: Comment replies
- **LinkedIn**: Comment on post
- **Instagram**: First comment

```bash
tadween posts:create \
  -c "Main post" \
  -c "Comment 1" \
  -c "Comment 2" \
  -i "integration-id"
```

---

## Common Workflows

### Reddit Post with Flair
```bash
#!/bin/bash
REDDIT_ID=$(tadween integrations:list | jq -r '.[] | select(.identifier=="reddit") | .id')
FLAIRS=$(tadween integrations:trigger "$REDDIT_ID" getFlairs -d '{"subreddit":"programming"}')
FLAIR_ID=$(echo "$FLAIRS" | jq -r '.output[0].id')

tadween posts:create \
  -c "My post content" \
  -s "2024-12-31T12:00:00Z" \
  --settings "{\"subreddit\":[{\"value\":{\"subreddit\":\"programming\",\"title\":\"Post Title\",\"type\":\"text\",\"is_flair_required\":true,\"flair\":{\"id\":\"$FLAIR_ID\",\"name\":\"Discussion\"}}}]}" \
  -i "$REDDIT_ID"
```

### YouTube Video Upload
```bash
#!/bin/bash
VIDEO=$(tadween upload video.mp4)
VIDEO_PATH=$(echo "$VIDEO" | jq -r '.path')

tadween posts:create \
  -c "Video description..." \
  -s "2024-12-31T12:00:00Z" \
  --settings '{"title":"My Video","type":"public","tags":[{"value":"tech","label":"Tech"}]}' \
  -m "$VIDEO_PATH" \
  -i "youtube-id"
```

### Multi-Platform Campaign
```bash
#!/bin/bash
tadween posts:create \
  -c "Same content everywhere" \
  -s "2024-12-31T12:00:00Z" \
  -m "image.jpg" \
  -i "twitter-id,linkedin-id,facebook-id"
```

### Batch Scheduling
```bash
#!/bin/bash
DATES=("2024-02-14T09:00:00Z" "2024-02-15T09:00:00Z" "2024-02-16T09:00:00Z")
CONTENT=("Monday motivation 💪" "Tuesday tips 💡" "Wednesday wisdom 🧠")

for i in "${!DATES[@]}"; do
  tadween posts:create \
    -c "${CONTENT[$i]}" \
    -s "${DATES[$i]}" \
    -i "twitter-id"
done
```

---

## Documentation

**For AI Agents:**
- **[SKILL.md](./SKILL.md)** - Complete skill reference with patterns and examples

**Deep-Dive Guides:**
- **[HOW_TO_RUN.md](./HOW_TO_RUN.md)** - Installation and setup methods
- **[COMMAND_LINE_GUIDE.md](./COMMAND_LINE_GUIDE.md)** - Complete command syntax reference
- **[PROVIDER_SETTINGS.md](./PROVIDER_SETTINGS.md)** - All platform settings schemas
- **[INTEGRATION_TOOLS_WORKFLOW.md](./INTEGRATION_TOOLS_WORKFLOW.md)** - Tools workflow guide
- **[INTEGRATION_SETTINGS_DISCOVERY.md](./INTEGRATION_SETTINGS_DISCOVERY.md)** - Settings discovery
- **[SUPPORTED_FILE_TYPES.md](./SUPPORTED_FILE_TYPES.md)** - Media format reference
- **[PROJECT_STRUCTURE.md](./PROJECT_STRUCTURE.md)** - Code architecture
- **[PUBLISHING.md](./PUBLISHING.md)** - npm publishing guide

**Examples:**
- **[examples/EXAMPLES.md](./examples/EXAMPLES.md)** - Comprehensive examples
- **[examples/](./examples/)** - Ready-to-use scripts and JSON files

---

## API Endpoints

The CLI interacts with these Tadween API endpoints:

| Endpoint | Method | Purpose |
|----------|--------|---------|
| `/public/v1/posts` | POST | Create a post |
| `/public/v1/posts` | GET | List posts |
| `/public/v1/posts/:id` | DELETE | Delete a post |
| `/public/v1/posts/:id/settings` | PUT | Update a post's provider settings (merged; unpublished only) |
| `/public/v1/posts/:id/missing` | GET | Get missing content from provider |
| `/public/v1/posts/:id/release-id` | PUT | Update release ID for a post |
| `/public/v1/integrations` | GET | List integrations (optional `?group=` filter) |
| `/public/v1/groups` | GET | List groups (customers) |
| `/public/v1/integration-settings/:id` | GET | Get integration settings |
| `/public/v1/integration-trigger/:id` | POST | Trigger integration tool |
| `/public/v1/analytics/:integration` | GET | Get platform analytics |
| `/public/v1/analytics/post/:postId` | GET | Get post analytics |
| `/public/v1/upload` | POST | Upload media |
| `/public/v1/clipping` | POST | Start clipping a YouTube video |
| `/public/v1/clipping` | GET | List clippings (optional `?page=`) |
| `/public/v1/clipping/:id` | GET | Get a clipping and its clips |

---

## Environment Variables

| Variable | Required | Default | Description |
|----------|----------|---------|-------------|
| `TADWEEN_API_KEY` | No* | - | Your Tadween API key |
| `TADWEEN_API_URL` | No | `https://studio.tadween.app/api` | Custom API endpoint |
| `TADWEEN_AUTH_SERVER` | No | `https://cli-auth.tadween.app` | Custom auth server URL |

*Either OAuth2 (via `tadween auth:login`) or `TADWEEN_API_KEY` is required.

---

## Error Handling

The CLI provides clear error messages with exit codes:

- **Exit code 0**: Success
- **Exit code 1**: Error occurred

**Common errors:**

| Error | Solution |
|-------|----------|
| `Not authenticated` | Run `tadween auth:login` or set `TADWEEN_API_KEY` |
| `Integration not found` | Run `integrations:list` to get valid IDs |
| `startDate/endDate required` | Use ISO 8601 format: `"2024-12-31T12:00:00Z"` |
| `Invalid settings` | Check `integrations:settings` for required fields |
| `Tool not found` | Check available tools in `integrations:settings` output |
| `Upload failed` | Verify file exists and format is supported |
| `analytics:post` returns `{"missing": true}` | Run `posts:missing <id>` then `posts:connect <id> --release-id "<rid>"` |

---

## Development

### Project Structure

```
src/
├── index.ts              # CLI entry point with yargs
├── api.ts                # PostizAPI client class
├── config.ts             # Configuration (OAuth2 + API key)
└── commands/
    ├── auth.ts           # OAuth2 authentication (login/logout/status)
    ├── posts.ts          # Post management commands
    ├── integrations.ts   # Integration commands
    ├── analytics.ts      # Analytics commands
    └── upload.ts         # Media upload command
examples/                 # Example scripts and JSON files
package.json
tsconfig.json
tsup.config.ts            # Build configuration
README.md                 # This file
SKILL.md                  # AI agent reference
```

### Scripts

```bash
pnpm run dev       # Watch mode for development
pnpm run build     # Build the CLI
pnpm run start     # Run the built CLI
```

### Building

The CLI uses `tsup` for bundling:

```bash
pnpm run build
```

Output in `dist/`:
- `index.js` - Bundled executable with shebang
- `index.js.map` - Source map

---

## Quick Reference

```bash
# Authentication
tadween auth:login                                              # OAuth2 device flow
tadween auth:status                                             # Check auth
tadween auth:logout                                             # Remove credentials
export TADWEEN_API_KEY=your_key                                 # Or use API key

# Discovery
tadween integrations:list                           # List integrations
tadween integrations:list --group "<group-id>"      # List integrations in a group
tadween integrations:groups                         # List groups (customers)
tadween integrations:settings <id>                  # Get settings
tadween integrations:trigger <id> <method> -d '{}'  # Fetch data

# Posting (date is required)
tadween posts:create -c "text" -s "2024-12-31T12:00:00Z" -i "id"                    # Simple
tadween posts:create -c "text" -s "2024-12-31T12:00:00Z" -t draft -i "id"          # Draft
tadween posts:create -c "text" -m "img.jpg" -s "2024-12-31T12:00:00Z" -i "id"      # With media
tadween posts:create -c "main" -c "comment" -s "2024-12-31T12:00:00Z" -i "id"      # With comment
tadween posts:create -c "text" -s "2024-12-31T12:00:00Z" --settings '{}' -i "id"   # Platform-specific
tadween posts:create --json file.json                                               # Complex

# Management
tadween posts:list                                  # List posts
tadween posts:delete <id>                          # Delete post
tadween posts:status <id> --status draft           # Move to draft (stops workflow)
tadween posts:status <id> --status schedule        # Queue draft for publishing
tadween posts:settings <id> --settings '{}'        # Patch a post's settings (merged; DRAFT/QUEUE only)
tadween upload <file>                              # Upload media

# Analytics
tadween analytics:platform <id>                    # Platform analytics (7 days)
tadween analytics:platform <id> -d 30             # Platform analytics (30 days)
tadween analytics:post <id>                        # Post analytics (7 days)
tadween analytics:post <id> -d 30                 # Post analytics (30 days)
# If analytics:post returns {"missing": true}, resolve it:
tadween posts:missing <id>                         # List provider content
tadween posts:connect <id> --release-id "<rid>"    # Connect content to post

# Help
tadween --help                                     # Show help
tadween posts:create --help                        # Command help
```

---

## Contributing

Issues and pull requests: [xerk/tadween-agent](https://github.com/xerk/tadween-agent).

1. Fork the repository
2. Create a feature branch from `tadween`
3. Make your changes in `src/`
4. Build: `pnpm run build`
5. Submit a pull request

---

## Credits and license

Tadween CLI is based on the [Postiz CLI and agent skill](https://github.com/gitroomhq/postiz-agent) by gitroomhq (Nevo David), and stays under the same license: AGPL-3.0. See [LICENSE](LICENSE).

---

## Links

- **Website:** [tadween.app](https://tadween.app)
- **AI agents and MCP:** [tadween.app/ai-agent](https://tadween.app/ai-agent)
- **GitHub:** [xerk/tadween-agent](https://github.com/xerk/tadween-agent)
- **Issues:** [Report bugs](https://github.com/xerk/tadween-agent/issues)

---

## Supported Platforms

28+ platforms including:

| Platform | Integration Tools | Settings |
|----------|------------------|----------|
| Twitter/X | getLists, getCommunities | who_can_reply_post |
| LinkedIn | getCompanies | companyId, carousel |
| Reddit | getFlairs, searchSubreddits | subreddit, title, flair |
| YouTube | getPlaylists, getCategories | title, type, tags, playlistId |
| TikTok | - | content_posting_method, privacy_level, comment, brand toggles, duet/stitch/video_made_with_ai (video only), autoAddMusic (photo only) |
| Instagram | - | post_type (post/story) |
| Facebook | getPages | - |
| Pinterest | getBoards, getBoardSections | - |
| Discord | getChannels | - |
| Slack | getChannels | - |
| And 18+ more... | | |

**See [PROVIDER_SETTINGS.md](./PROVIDER_SETTINGS.md) for complete documentation.**
