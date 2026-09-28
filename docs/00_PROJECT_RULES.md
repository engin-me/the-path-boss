# Project Rules

## Source of Truth

Approved game design decisions live in `docs/freeze/`.

Priority:
1. PROJECT_RULES
2. Current FREEZE decisions
3. User's current explicit instruction
4. IDEA and REVIEW material

IDEA files, including their review and proposed decision sections, are not implementation specifications. Legacy REVIEW files are historical critiques.

`docs/03_GAME_OVERVIEW.md` is the living vision document.
It protects the identity and intended experience of the game, but it is not a frozen specification.

FREEZE files define exact approved decisions.
GAME_OVERVIEW defines the broader design intent those decisions should normally serve.

If a new approved FREEZE materially changes the game's vision, GAME_OVERVIEW should later be updated to reflect the new approved direction.

## Design Workflow

1. Develop an idea in one active `IDEA-XXX_<topic>.md` file. Keep exactly these top-level sections: `Durum/Tur`, `Öneri (GPT)`, `Notlar (Claude)`, `Açık Kararlar`, `Karar Özeti`.
2. Claude reviews the IDEA and updates `Notlar (Claude)` in that same file. Codex revises `Öneri (GPT)` in that file. Both update the current round in place; Git history preserves previous rounds.
3. Track unresolved choices in `Açık Kararlar`. Present the outcome to the user. A proposed resolution is not an approved decision.
4. After user approval, create `FRZ-XXX_<topic>.md` recording WHAT and WHY, then update `01_DECISION_INDEX.md` and `02_CURRENT_STATE.md`. Link the approved FREEZE from the IDEA file.

Do not create separate REVIEW files for new review rounds. Existing REVIEW files remain historical records. Each `Karar Özeti` entry is one line that states WHAT was decided and WHY. Mark unapproved proposals as open, not final.

For Claude cloud sessions, GitHub is the file exchange. A cloud edit reaches the local checkout only after the user publishes it and the local checkout is updated. The user handles publishing Git changes; the AIs do not push or merge without an explicit request.
Once the user says the review is published, Codex reads the updated IDEA file and reports the outcome without asking the user to relay the review text.

## Freeze Rule

A frozen decision is never silently rewritten.

If a frozen design must change:
- create a new IDEA
- explain why the old decision is insufficient
- review the change
- create a new freeze version
- mark the previous freeze as SUPERSEDED

## Token Discipline

Do not load every project document.

First read:
- PROJECT_RULES
- DECISION_INDEX
- CURRENT_STATE

Then load only relevant FREEZE and IDEA files, and legacy REVIEW files when their history is needed.

## Decision History

Every final decision must record:
- WHAT was decided
- WHY it was decided
- what alternatives were rejected when relevant
- dependencies on other decisions
