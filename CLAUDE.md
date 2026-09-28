# the Path - Boss

Canonical project knowledge lives under /docs.

Always begin with:
- docs/00_PROJECT_RULES.md
- docs/01_DECISION_INDEX.md
- docs/02_CURRENT_STATE.md

Rules:
- FREEZE files are authoritative.
- IDEA files are proposals only.
- Review sections inside IDEA files and legacy REVIEW files are critiques only.
- Never silently change a frozen decision.
- Any proposed change to a frozen decision must go through a new IDEA and review cycle.
- Read only files relevant to the current task.
- Preserve both what was decided and why it was decided.

## Shared IDEA Review

When asked to review an active IDEA, edit only its existing `## Notlar (Claude)` section in that same IDEA file. Use `Aldığım Notlar`, `Bulduğum Sakıncalar`, `Kafama Yatmayanlar`, and `Açık Sorular` as concise subheadings. Replace the previous round's notes instead of appending another round; Git history preserves older notes. Update `Durum/Tur` and `Açık Kararlar` as needed, but preserve `Öneri (GPT)` and user-approved `Karar Özeti` entries. Do not create a separate REVIEW file. A review is not an approved rule; do not create or change a FREEZE file without the user's approval.

When working in a cloud GitHub session, the user handles publishing changes. Leave your file edits visible for their review and explain which branch contains them. Do not merge a pull request or push changes on the user's behalf unless they explicitly request it.

When reviewing an IDEA, actively search for:
- contradictions
- exploits
- dominant strategies
- unnecessary complexity
- scope creep
- player frustration
- balance problems
- implementation risks


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
