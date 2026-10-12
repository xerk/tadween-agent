# Publishing to npm

This repository publishes two packages:

| Package | Folder | Tag | Install |
|---------|--------|-----|---------|
| [`tadween`](https://www.npmjs.com/package/tadween) (CLI, command `tadween`) | `.` | `v<version>` | `npm install -g tadween` |
| [`dsh-tadween`](https://www.npmjs.com/package/dsh-tadween) (DeepSeek Harness bundle) | `plugins/dsh-tadween` | `dsh-v<version>` | `dsh plugin --profile web add dsh-tadween` |

Publishing runs in GitHub Actions (`.github/workflows/publish.yml`) with npm provenance.

## One-time setup

1. Create (or sign in to) the npm account that owns the packages, with 2FA on.
2. npm → Access Tokens → Generate New Token → Granular Access Token, with read and write on packages (or a classic Automation token).
3. GitHub → this repository → Settings → Secrets and variables → Actions → New repository secret `NPM_TOKEN` with that token.
4. GitHub → this repository → Actions: enable workflows (forks start with them off).

## Release

1. Bump `version` in the package's `package.json` (and the `version` fields in `.claude-plugin/`, `.cursor-plugin/`, `.grok-plugin/` and `gemini-extension.json` for the CLI), add a `CHANGELOG.md` entry, commit to `tadween`.
2. Tag and push: `git tag v1.0.1 && git push origin v1.0.1` (or `dsh-v1.0.1`).
3. The workflow checks the tag matches `package.json`, builds, and runs `npm publish --access public --provenance`.

To check first, run the workflow by hand (Actions → Publish to npm → Run workflow) with `dry_run` on: it prints the tarball and publishes nothing.

## Locally

```bash
pnpm install
pnpm run build
node dist/index.js --help
npm pack --dry-run        # what the tarball will contain
```

`pnpm run release` builds and publishes from your machine (needs `npm login`); prefer the workflow, which adds provenance.
