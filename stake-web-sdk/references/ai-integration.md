# Stake Engine — AI Integration

Distilled from `docs/ai-integration/` on stake-engine.com.

Stake Engine ships an MCP (Model Context Protocol) server that gives any MCP-compatible AI client full-text search and retrieval over the official documentation. Paired with the **Hayden** agent prompt, the result is a documentation expert that grounds answers in cited routes.

## MCP Server

Repo: `https://github.com/StakeEngine/docs` (subfolder `mcp-server/`).

### What it does

Indexes every `+page.svx` under `src/routes/docs/` and `src/routes/faq/` into `data/docs-index.json`, then runs as a stdio MCP server.

### Transport

stdio. The client launches `node dist/index.js` as a child process.

### Tools exposed

| Tool | Purpose |
|------|---------|
| `search_docs` | Full-text keyword search. Params: `query` (required), `section` (`"docs"` / `"faq"`), `limit` (1–50, default 10). Scoring weights: title (15), tags (6), description (4–6), route path (2), body term frequency (up to 5 per term). |
| `get_page` | Full page content by `route` (e.g. `/docs/api/play`). Suggests partial matches on miss. |
| `list_pages` | Browse all pages, optional filter by `section` or route `prefix`. |
| `get_section_tree` | Hierarchical navigation tree, optional `section` filter. |

### Resources / prompts

- Resource URI `stake-engine-docs://agent-prompt` returns the Hayden system prompt.
- Prompt name `hayden` accepts a `question` argument and returns a ready-to-send prompt.

### Build

```bash
git clone https://github.com/StakeEngine/docs.git
cd docs/mcp-server
pnpm install
pnpm run build      # runs build:index then build:server
node dist/index.js  # verifies server starts
```

`pnpm run build:index` alone is enough when only docs content changed.

### Client wiring

All clients use the same shape, only the config-file path differs. Use the **absolute path** to `dist/index.js`.

```json
{
  "mcpServers": {
    "stake-engine-docs": {
      "command": "node",
      "args": ["/path/to/stake-engine-docs/mcp-server/dist/index.js"]
    }
  }
}
```

| Client | Config path |
|--------|-------------|
| Claude Code | `.mcp.json` (project root) |
| Claude Desktop | `claude_desktop_config.json` |
| Cursor | `.cursor/mcp.json` |
| Windsurf | `.windsurf/mcp.json` |

## Hayden Agent

Hayden is a system prompt — not a binary — that turns any MCP-connected assistant into a Stake Engine docs expert. It instructs the model to:

1. Call `search_docs` first.
2. Call `get_page` for details on hits.
3. Cite `Source: /route/path` for every claim.
4. Fall back to `list_pages` / `get_section_tree` when search returns nothing.
5. Never fabricate documentation.

The prompt does **not** hardcode the docs structure — sections are discovered dynamically via `get_section_tree`, so it stays current as docs evolve.

### Setup by client

| Client | Where to paste the prompt |
|--------|---------------------------|
| Claude Code | `.claude/agents/hayden.md`; invoke with `@hayden` after restart. |
| Claude Desktop | New **Project** → **Project Instructions**. |
| Cursor | `.cursor/rules/stake-docs.mdc` (under YAML frontmatter with `alwaysApply: true`). |
| Windsurf | `.windsurf/rules/stake-docs.md`. |
| Custom | Fetch via MCP resource `stake-engine-docs://agent-prompt` or prompt name `hayden`. |

The prompt requires the MCP server to be configured first.
