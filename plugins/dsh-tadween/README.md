# dsh-tadween

[![npm](https://img.shields.io/npm/v/dsh-tadween)](https://www.npmjs.com/package/dsh-tadween)

**npm:** [`dsh-tadween`](https://www.npmjs.com/package/dsh-tadween) ·
**source:** [xerk/tadween-agent](https://github.com/xerk/tadween-agent/tree/tadween/plugins/dsh-tadween)

[DeepSeek Harness](https://github.com/deepseek-ai/deepseek-harness) (`dsh`) plugin for
[Tadween](https://tadween.app), the social media scheduler by Xerk LLC (based on the open-source Postiz). It connects the agent
to the Tadween MCP server so it can list your connected channels, fetch each platform's
posting rules, and schedule, draft, or publish posts across 28+ platforms (X, LinkedIn,
Instagram, Facebook, Threads, TikTok, YouTube, Reddit, Pinterest, Bluesky, Mastodon,
Discord, Slack, Telegram, and more).

## Install

From the repository:

```bash
dsh plugin --profile web add "github:xerk/tadween-agent#path:/plugins/dsh-tadween"
```

Or from npm:

```bash
dsh plugin --profile web add dsh-tadween
```

Then give it a Tadween API key. Copy it from **Tadween → Settings → API & MCP**
and export it before starting dsh, or put it in `$DSH_HOME/.env`:

```bash
export TADWEEN_API_KEY=your-api-key
dsh web
```

Restart the profile after installing. Ask the agent *"List my connected social media
accounts"* to verify the connection.

## What you get

The bundle mounts two rows:

| Row | Package | Role |
|---|---|---|
| `tadween` | `dsh-tadween` (this package) | Reads the API key, exposes `ctx.tadween` (`url`, `headers`), and registers the `tadween` skill that teaches the agent the posting workflow and the HTML content rules. |
| `tadween-mcp` | `@deepseek-ai/dsh-mcp-client` (shipped with dsh) | Connects to `https://studio.tadween.app/mcp` over streamable HTTP with a `Bearer` header and registers the server's tools. |

The model sees the Tadween MCP tools under the `mcp__tadween__` namespace:

| Tool | What it does |
|---|---|
| `mcp__tadween__integrationList` | List connected channels (optionally filtered by group) |
| `mcp__tadween__groupList` | List customer groups |
| `mcp__tadween__integrationSchema` | Posting rules, character limits, and required settings for a platform |
| `mcp__tadween__triggerTool` | Platform helpers (list Discord channels, search subreddits, list LinkedIn pages) |
| `mcp__tadween__schedulePostTool` | Schedule, draft, or immediately publish posts |
| `mcp__tadween__postsListTool` | List posts scheduled between two dates |
| `mcp__tadween__postSettingsTool` | Update settings of an unpublished post |
| `mcp__tadween__generateImageTool` | Generate an image for a post |
| `mcp__tadween__generateVideoOptions` / `videoFunctionTool` / `generateVideoTool` | Video generation options and generation |

The tool list comes from the server at connect time, so new Tadween tools appear without a
plugin update. See the [Tadween MCP tools reference](https://tadween.app/ai-agent).

## Configuration

Override the `tadween` row in your profile's `cordis.patch.yml` (`$DSH_HOME/profiles/web/cordis.patch.yml`).
A bare `id:` configures the existing row:

```yaml
- id: tadween
  config:
    apiKeyEnv: TADWEEN_API_KEY          # env var that holds the key (default)
    baseUrl: https://studio.tadween.app    # self-hosted: https://your-tadween-server.com
    skill: true                        # register the `tadween` workflow skill
```

| Field | Default | Description |
|---|---|---|
| `apiKeyEnv` | `TADWEEN_API_KEY` | Environment variable read at boot for the API key. |
| `apiKey` | `''` | Inline key. Prefer the env var; this exists for patch-level overrides. |
| `baseUrl` | `https://studio.tadween.app` | Tadween host. The MCP endpoint is `<baseUrl>/mcp`. Self-hosted instances point this at their backend. |
| `skill` | `true` | Register the `tadween` skill on `ctx.skills`. |

Without a key the `tadween` row logs a warning naming the variable to set, and the
`tadween-mcp` row registers no tools. dsh keeps booting.

## Self-hosted Tadween

The MCP server is part of the Tadween backend and listens at `/mcp` (Bearer auth). Point
`baseUrl` at your backend and make sure your reverse proxy forwards `/mcp` with streaming
HTTP enabled. See [Reverse Proxies](https://github.com/xerk/tadween#readme).

## Development

```bash
cd plugins/dsh-tadween
pnpm install
pnpm test
```

Link a local checkout into a profile:

```bash
dsh plugin --profile web add /absolute/path/to/tadween-agent/plugins/dsh-tadween
```

## Related

- [Tadween CLI](https://github.com/xerk/tadween-agent) — the `tadween` command-line tool and the Claude Code / Cursor / Grok plugins in this repository.
- [Tadween for AI agents (MCP)](https://tadween.app/ai-agent)

## Credits and license

Based on [`dsh-postiz`](https://github.com/gitroomhq/postiz-agent/tree/main/plugins/dsh-postiz) by gitroomhq (Nevo David).
AGPL-3.0, same as the rest of this repository.
