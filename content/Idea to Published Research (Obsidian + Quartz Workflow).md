---
title: From Idea to Published Research — My Obsidian + Quartz Workflow
tags:
  - workflow
  - obsidian
  - quartz
  - publishing
  - pkm
created: 2026-03-26
status: published
publish: true
---
# From Idea to Published Research

Most ideas die in your notes app. Not because they weren't worth developing — but because the path from "rough thought" to "something shareable" has too many friction points. A new tool to learn. A format to figure out. A deployment step that requires twenty minutes of setup you haven't done yet.

This post documents the system I built to eliminate that friction. It uses **Obsidian** as the writing environment and **Quartz** as the publishing engine. Once set up, going from a raw note to a live research site takes a single command.

Here's the full pipeline before we go into each stage:

```mermaid
flowchart LR
    A(["💡 Raw Idea"]):::seed

    subgraph WRITE ["✍️  Write"]
        B["📥 Capture Inbox/"]:::capture
        C["📝 Draft Research/Topic/"]:::draft
        D["🔍 Refine Add index.md"]:::refine
    end

    subgraph SHIP ["🚀  Ship"]
        F["⚙️ publish.sh"]:::script
        G["🤖 GitHub Actions build + deploy"]:::ci
    end

    H(["🌐 Live Site ~2 min"]):::live
    E{{"Ready?"}}:::gate

    A --> B --> C --> D --> E
    E -->|"not yet"| C
    E -->|"ship it"| F
    F --> G --> H

    classDef seed    fill:#ffd43b,stroke:#f59f00,color:#1a1a2e,font-weight:bold
    classDef capture fill:#74c0fc,stroke:#339af0,color:#1a1a2e
    classDef draft   fill:#a9e34b,stroke:#74b816,color:#1a1a2e
    classDef refine  fill:#63e6be,stroke:#20c997,color:#1a1a2e
    classDef gate    fill:#e599f7,stroke:#cc5de8,color:#1a1a2e,font-weight:bold
    classDef script  fill:#ffa94d,stroke:#f76707,color:#1a1a2e,font-weight:bold
    classDef ci      fill:#748ffc,stroke:#4c6ef5,color:#fff
    classDef live    fill:#69db7c,stroke:#2f9e44,color:#1a1a2e,font-weight:bold
```

---

## How the Vault is Organized

Before anything else, you need a structure that doesn't get in your way. Here's what mine looks like:

```mermaid
flowchart TD
    VAULT[("🗂️ Obsidian Vault")]:::root

    VAULT --> IB["📥 Inbox/ Fleeting captures · process weekly"]:::inbox
    VAULT --> DL["📅 Daily/ Work logs"]:::daily
    VAULT --> NO["📝 Notes/ Permanent atomic notes"]:::notes
    VAULT --> RE["🔬 Research/"]:::research
    VAULT --> TP["🧩 Templates/"]:::tmpl

    RE --> TOPIC["📁 Topic folder e.g. SDD/"]:::topic

    TOPIC --> IDX["🟢 index.md Site landing page"]:::pub
    TOPIC --> ART["📄 main-article.md"]:::pub
    TOPIC --> TPF["📋 templates, references"]:::pub
    TOPIC --> EX["🔒 examples/ Private — never published"]:::priv

    classDef root    fill:#1a1a2e,stroke:#4c6ef5,color:#fff,font-weight:bold
    classDef inbox   fill:#74c0fc,stroke:#339af0,color:#1a1a2e
    classDef daily   fill:#a9e34b,stroke:#74b816,color:#1a1a2e
    classDef notes   fill:#63e6be,stroke:#20c997,color:#1a1a2e
    classDef research fill:#ffd43b,stroke:#f59f00,color:#1a1a2e
    classDef tmpl    fill:#e599f7,stroke:#cc5de8,color:#1a1a2e
    classDef topic   fill:#ffa94d,stroke:#f76707,color:#1a1a2e,font-weight:bold
    classDef pub     fill:#d3f9d8,stroke:#2f9e44,color:#1a1a2e
    classDef priv    fill:#ffc9c9,stroke:#e03131,color:#1a1a2e,font-weight:bold
```

The key distinction: `Research/Topic/` is where publishable work lives. Everything else is internal scaffolding. The `examples/` folder under each topic stays private — it never gets synced to the live site.

---

## Stage 1 — Capture: Get the Idea Out

**Goal:** Don't lose the thought. Quality doesn't matter here.

Every idea starts in `Inbox/` or a Daily note. One line is enough:

```
- [ ] Idea: coding agents need structured context to avoid hallucination
```

Speed is the only priority at this stage. You move on when you want to develop it further — not before.

---

## Stage 2 — Draft: Give It a Home

**Goal:** Move the idea into a proper research folder and start building it out.

Every topic gets its own folder: `Research/Topic/note.md`. Use frontmatter to track where a note is in its lifecycle:

```yaml
---
title: "Your Research Title"
status: draft        # draft | in-review | approved
tags: [ai, research]
created: 2026-03-26
---
```

**The rules here:**
- One folder per topic
- One idea per file — keep notes atomic
- Use `[[wikilinks]]` to connect ideas as they develop

The `status` field does a lot of work. It tells you at a glance what's ready to ship and what still needs attention.

---

## Stage 3 — Refine: Get It Ready to Publish

**Goal:** Make sure the content is complete, correct, and won't break when Quartz renders it.

Before a topic goes live, it needs an `index.md` — the landing page visitors hit first:

```markdown
---
title: "Topic Name"
---

# Topic Name

One-line description of what this research covers.

## Research
- [[main-article]] — What it covers.

## Templates / Resources
- [[template-file]] — What it's for.
```

Run through this checklist before moving on:

```mermaid
flowchart LR
    C1(["① Frontmatter complete"]):::step
    C2(["② index.md exists"]):::step
    C3(["③ Mermaid diagrams tested locally"]):::step
    C4(["④ No private folders in index"]):::step
    C5(["⑤ Wikilinks resolve"]):::step
    GO{{"✅ Ship it"}}:::go

    C1 -->|"✓"| C2 -->|"✓"| C3 -->|"✓"| C4 -->|"✓"| C5 -->|"✓"| GO

    classDef step fill:#e7f5ff,stroke:#339af0,color:#1a1a2e,font-weight:bold
    classDef go   fill:#69db7c,stroke:#2f9e44,color:#1a1a2e,font-weight:bold
```

A few things that break silently if you skip them — worth knowing upfront:

| Rule | Why |
|------|-----|
| Mermaid `<tag>` in node labels → use `{tag}` | HTML tags break Mermaid 11 parser |
| `# H1` heading in body → remove it | Quartz renders the title from frontmatter |
| HTML comments before `---` frontmatter → move them after | Frontmatter must start on line 1 |

---

## Stage 4 — Publish: One Command to Go Live

**Goal:** Sync your Obsidian notes to Quartz and deploy to GitHub Pages.

### Understanding the Architecture First

Obsidian and Quartz are two completely separate systems on your machine. They don't talk to each other automatically. The bridge between them is a script called `publish.sh` that lives inside the Quartz repo.

```mermaid
flowchart LR
    OB[("📓 Obsidian Vault Research/SDD/")]:::vault
    QZ[["⚙️ publish.sh rsync + git push"]]:::script
    GH[("🐙 GitHub Repo VenkateshDas/sdd-site")]:::repo
    CI["🤖 GitHub Actions npm ci → quartz build"]:::ci
    WB(["🌐 venkateshdas .github.io/sdd-site"]):::live

    OB -->|"rsync copies changed files"| QZ
    QZ -->|"git push origin main"| GH
    GH -->|"triggers on push"| CI
    CI -->|"deploys in ~2 min"| WB

    classDef vault  fill:#1a1a2e,stroke:#748ffc,color:#fff,font-weight:bold
    classDef script fill:#ffa94d,stroke:#f76707,color:#1a1a2e,font-weight:bold
    classDef repo   fill:#1a1a2e,stroke:#69db7c,color:#fff,font-weight:bold
    classDef ci     fill:#748ffc,stroke:#4c6ef5,color:#fff
    classDef live   fill:#69db7c,stroke:#2f9e44,color:#1a1a2e,font-weight:bold
```

Nothing moves until you run the script. Once you do, three things happen automatically:
1. Changed files are copied from `Research/SDD/` → `quartz-sdd/content/` using `rsync`
2. The changes are committed and pushed to GitHub
3. GitHub Actions picks up the push and deploys the site

### One-Time Setup

```bash
# 1. Clone Quartz
git clone https://github.com/jackyzha0/quartz quartz-topic
cd quartz-topic && npm install

# 2. Point it at your GitHub repo
git remote set-url origin https://github.com/YOUR_ORG/topic-site.git
git push -u origin v4:main

# 3. GitHub → Settings → Pages → Source: GitHub Actions
```

Then open `publish.sh` and update the `VAULT` variable to point at your Obsidian topic folder — this is the only line that connects the two systems:

```bash
VAULT="/Users/YOUR_NAME/Library/Mobile Documents/.../Research/YOUR_TOPIC"
```

### Controlling What Gets Published

By default, `rsync` copies everything. To keep certain folders private, add `--exclude` flags:

```bash
rsync -a --delete --delete-excluded \
  --exclude='.DS_Store' \
  --exclude='*.canvas' \
  --exclude='.obsidian/' \
  --exclude='examples/' \       ← private internal samples
  --exclude='drafts/' \         ← work in progress
  "$VAULT/" "$CONTENT_DIR/"
```

The `--delete-excluded` flag is important — without it, folders you've excluded will stay in `content/` from previous syncs even after you add the exclude rule.

### What Gets Published vs. What Stays Private

| Published | Excluded |
|-----------|----------|
| All `.md` files in your topic folder | `examples/` folder |
| Subfolders | `.DS_Store` · `*.canvas` · `.obsidian/` |
| New files added since last run | Files deleted in Obsidian are deleted in `content/` too |

### Every Publish Thereafter

```bash
./publish.sh              # sync → commit → push → live in ~2 min
./publish.sh --preview    # sync + local preview only (no push)
```

Here's what the script does end-to-end:

```mermaid
flowchart TD
    START(["▶ ./publish.sh"]):::start

    START --> RS["⚡ rsync Research/Topic/ → content/ excludes: examples · .DS_Store · *.canvas"]:::sync

    RS --> CH{{"Any changes?"}}:::gate

    CH -->|"nothing changed"| ND(["💤 No changes. Nothing to publish."]):::skip
    CH -->|"files changed"| GC["📦 git commit sync: Obsidian → Quartz · timestamp"]:::git
    GC --> GP["⬆️ git push origin main"]:::git
    GP --> GA["🤖 GitHub Actions npm ci → quartz build"]:::ci
    GA --> LIVE(["🌐 Live on GitHub Pages ~2 minutes"]):::live

    classDef start fill:#ffd43b,stroke:#f59f00,color:#1a1a2e,font-weight:bold
    classDef sync  fill:#74c0fc,stroke:#339af0,color:#1a1a2e
    classDef gate  fill:#e599f7,stroke:#cc5de8,color:#1a1a2e,font-weight:bold
    classDef skip  fill:#f1f3f5,stroke:#868e96,color:#495057
    classDef git   fill:#a9e34b,stroke:#74b816,color:#1a1a2e
    classDef ci    fill:#748ffc,stroke:#4c6ef5,color:#fff
    classDef live  fill:#69db7c,stroke:#2f9e44,color:#1a1a2e,font-weight:bold
```

---

## Scaling to Multiple Topics

Each topic gets its own Quartz repo. Sites stay independent and focused.

```mermaid
flowchart LR
    VAULT[("🗂️ Obsidian Vault Research/")]:::root

    subgraph TOPICS ["📁 Topic Folders"]
        S1["SDD/"]:::t1
        S2["NextTopic/"]:::t2
        S3["AnotherTopic/"]:::t3
    end

    subgraph SITES ["🌐 Live Sites"]
        R1(["quartz-sdd github.io/sdd-site"]):::s1
        R2(["quartz-nexttopic github.io/nexttopic"]):::s2
        R3(["quartz-anothertopic github.io/anothertopic"]):::s3
    end

    VAULT --> S1 & S2 & S3
    S1 -->|"publish.sh"| R1
    S2 -->|"publish.sh"| R2
    S3 -->|"publish.sh"| R3

    classDef root fill:#1a1a2e,stroke:#748ffc,color:#fff,font-weight:bold
    classDef t1   fill:#ffd43b,stroke:#f59f00,color:#1a1a2e
    classDef t2   fill:#ffa94d,stroke:#f76707,color:#1a1a2e
    classDef t3   fill:#e599f7,stroke:#cc5de8,color:#1a1a2e
    classDef s1   fill:#dbe4ff,stroke:#4c6ef5,color:#1a1a2e,font-weight:bold
    classDef s2   fill:#d3f9d8,stroke:#2f9e44,color:#1a1a2e,font-weight:bold
    classDef s3   fill:#f3d9fa,stroke:#9c36b5,color:#1a1a2e,font-weight:bold
```

When to spin up a new repo:

```mermaid
flowchart TD
    Q{{"Is this topic self-contained and independently shareable?"}}:::gate

    Q -->|"Yes"| NR["🆕 Create a new Quartz repo"]:::new
    Q -->|"No"| EX{{"Does it belong with existing published research?"}}:::gate

    EX -->|"Yes"| ADD["➕ Add to existing topic folder"]:::add
    EX -->|"No"| DRAFT["📋 Keep as draft in Research/ — don't publish yet"]:::draft

    classDef gate  fill:#e599f7,stroke:#cc5de8,color:#1a1a2e,font-weight:bold
    classDef new   fill:#d3f9d8,stroke:#2f9e44,color:#1a1a2e,font-weight:bold
    classDef add   fill:#dbe4ff,stroke:#4c6ef5,color:#1a1a2e,font-weight:bold
    classDef draft fill:#fff3bf,stroke:#f59f00,color:#1a1a2e
```

---

## Local Preview Tips

Before pushing, always verify locally:

```bash
# Sync from Obsidian + start local preview (no push)
./publish.sh --preview

# Force clean rebuild — clears stale cached pages
rm -rf public/ && npx quartz build --serve

# Inspect what will be committed before pushing
git diff --staged content/
```

---

## The Mental Model

The whole system rests on one insight: **Obsidian and Quartz never talk to each other directly.** `publish.sh` is the only connection. If you edit a note in Obsidian and don't run the script, the live site won't change.

That's a feature, not a bug. You control exactly when your work goes public.

---

## References

- Quartz docs: https://quartz.jzhao.xyz
- Quartz Syncer plugin (publish directly from Obsidian UI — future option): https://github.com/saberzero1/quartz-syncer
- SDD site repo: https://github.com/VenkateshDas/sdd-site
