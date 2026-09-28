# the Path - Boss

Canonical project knowledge lives under /docs.

Always begin with:
- docs/00_PROJECT_RULES.md
- docs/01_DECISION_INDEX.md
- docs/02_CURRENT_STATE.md

Before working on a topic:
1. Read DECISION_INDEX.
2. Load only the relevant FREEZE files.
3. Never silently modify a FREEZE decision.
4. If a frozen decision must change, create a new IDEA proposal first.
5. IDEA and REVIEW files are not approved game rules.
6. Only current FREEZE files represent approved design decisions.

Workflow:
IDEA -> REVIEW -> FREEZE

Keep context usage low.
Do not read every project file unless required.

## Game Vision Guardrail

`docs/03_GAME_OVERVIEW.md` contains the living overview of the game's identity, intended player experience, and design philosophy.

Read GAME_OVERVIEW before:
- proposing a major gameplay system
- changing the core loop
- designing careers, factory systems, progression or replayability
- making monetization decisions
- making architectural choices that constrain game design

It does not need to be loaded for routine coding, file operations, bug fixes or narrowly scoped implementation work.

GAME_OVERVIEW is not authoritative over FREEZE decisions.
If GAME_OVERVIEW conflicts with a current FREEZE file, the FREEZE decision wins and the inconsistency must be reported.

Do not silently simplify or reshape the project into a generic tycoon, idle game, hypercasual game or collection of disconnected mini-games.

Preserve the core identity:
- the player's career history becomes their future boss build
- time and choices have opportunity costs
- factory ownership is a new phase, not the end goal
- building a factory is easier than keeping it alive
- missing knowledge creates management problems, not arbitrary punishment
- failure should teach the player and create the motivation for another run
- a great boss does not know everything; they know what they know, what they do not know, and who should handle it
