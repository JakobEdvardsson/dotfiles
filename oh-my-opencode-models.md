# oh-my-opencode-slim — Fireworks model recommendations

Provider: `fireworks-ai` · Models: `accounts/fireworks/models/<slug>`

## What it is
Multi-agent orchestration plugin for opencode. An Orchestrator plans and
auto-delegates to specialized sub-agents, each on its own model.

Repo: https://github.com/alvinunreal/oh-my-opencode-slim

## Agent → role → recommended model

| Agent | Role | Model | $/M in·out |
|---|---|---|---|
| Orchestrator | Master delegator / coordinator | deepseek-v4-pro-0813 | $1.32 · $3.96 |
| Oracle | Architecture, hard debugging, review | glm-5p3-flash *(pending)* | flash-cost |
| Explorer | Codebase recon | deepseek-v4-flash-0731 | $0.22 · $0.66 |
| Librarian | External docs/knowledge | deepseek-v4-flash-0731 | $0.22 · $0.66 |
| Fixer | Scoped implementation | deepseek-v4-flash-0731 | $0.22 · $0.66 |
| Designer | UI/UX, frontend | glm-5p3-flash *(pending)* | flash-cost |
| Observer (opt) | Vision (screenshots/PDFs) | glm-5p3-flash *(pending)* | flash-cost |
| Council | Multi-model consensus | synth=glm-5p3-flash + diverse councillors | — |

> **GLM-5.3-Flash (z.ai)** — first natively multimodal GLM-5 model. 320B total /
> 18B active (MoE), 1M token context. Outperforms GLM-5.2, approaches Claude
> Opus 4.8 on coding/agentic, at flash cost. Once it lands on Fireworks, it's
> the pick for Oracle + Designer + Observer (and a candidate for Orchestrator).
> Exact Fireworks slug (e.g. `glm-5p3-flash`) is TBD until listed.

## Auto-switching
- Orchestrator auto-routes each task to the right specialist (background
  sub-agent) → different models used automatically per task.
- `/preset` swaps the whole team's models at runtime (manual).

## Highest-confidence picks
- deepseek-v4-flash-0731 (already in use) — Explorer/Librarian/Fixer
- deepseek-v4-pro-0813 — Orchestrator
- glm-5p3-flash — Oracle / Designer / Observer (when available)

## Install
1. `npx oh-my-opencode-slim@latest install`
2. Edit `~/.config/opencode/oh-my-opencode-slim.json` → add `fireworks` preset
3. `opencode models --refresh` then `ping all agents`
4. Optional: Herdr multiplexer integration (each agent in its own pane)
