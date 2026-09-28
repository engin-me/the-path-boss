# Project Rules

## Source of Truth

Approved game design decisions live in `docs/freeze/`.

Priority:
1. PROJECT_RULES
2. Current FREEZE decisions
3. User's current explicit instruction
4. IDEA and REVIEW material

IDEA and REVIEW files are not implementation specifications.

`docs/03_GAME_OVERVIEW.md` is the living vision document.
It protects the identity and intended experience of the game, but it is not a frozen specification.

FREEZE files define exact approved decisions.
GAME_OVERVIEW defines the broader design intent those decisions should normally serve.

If a new approved FREEZE materially changes the game's vision, GAME_OVERVIEW should later be updated to reflect the new approved direction.

## Design Workflow

1. An idea is developed.
2. Create `IDEA-XXX_<topic>.md`.
3. The other AI reviews it.
4. Create `REV-XXX_<model>_<topic>.md`.
5. Revise if necessary.
6. After user approval, create `FRZ-XXX_<topic>.md`.
7. Update `01_DECISION_INDEX.md`.
8. Update `02_CURRENT_STATE.md`.

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

Then load only relevant FREEZE, IDEA and REVIEW files.

## Decision History

Every final decision must record:
- WHAT was decided
- WHY it was decided
- what alternatives were rejected when relevant
- dependencies on other decisions
