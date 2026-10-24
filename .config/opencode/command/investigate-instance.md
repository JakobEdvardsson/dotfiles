---
description: Investigate an Aura production/staging database by DBID (read-only).
---

Investigate the Aura database referenced below, following the neo4j-cloud repo's
`aura-production-incident-investigation` skill.

$ARGUMENTS

Prerequisites:

- Run from the **neo4j-cloud** checkout in the aura dev environment (needs
  `agents/skills/…`, `bin/database-manager`, `bin/ak` on `PATH`, and
  `DATABASE_MANAGER_USER_SERVICE_KEY` exported). If the skill file is not in the
  current working tree, locate the checkout (e.g. `~/code/neo4j-cloud`) first.
- The skill is **not** loaded as an OpenCode skill, so read it directly and follow
  the workflow:
  - `agents/skills/aura-production-incident-investigation/SKILL.md`
  - the `references/` files it links
  - the shared files under `agents/skills/_shared/`

How to run it:

- The **first token is the DBID**. Anything after it is optional context: an
  Incident.io link (`INC-…`), a Linear ticket (`ENG-…`), or the target
  environment (default `production`, i.e. `--dbm-environment production`).
- Run the skill's GCP auth preflight (the two `gcloud auth print-access-token`
  checks) before the first `db-logs`/`gcloud` command. On `STALE`, stop and ask
  the user to re-auth — do not treat an empty profile as "nothing was logged".
- If the DBID is not given, ask for it rather than guessing.

Guardrails (the skill's, restated — this is a live production system):

- **Read-only.** Never create, patch, scale, cordon, quarantine, transfer,
  destroy, annotate, label, delete, restart, exec, or port-forward anything, and
  only use the allowed `database-manager` read subcommands (`details`,
  `tombstone`, `orchestras`, `get-auth-token`).
- Do not change the machine-wide kube context; use `ak --url "$(ak-url …)"`.
  `omni k8s connect` requires the user's explicit approval first.
- Bound log windows (`--window` ≤ 4h, or `--window-start`/`--window-end` for
  stale incidents) and cap manual `gcloud logging read` queries at 3.
- The incident.io key is read-only: never attempt to post or update an incident.
  Draft any update text and hand it to the user to post.

Finish with the skill's bounded verdict — separating Kubernetes resource state,
control-plane/operator evidence, and runtime evidence — plus the Logs Explorer
links for the filters you actually ran.
