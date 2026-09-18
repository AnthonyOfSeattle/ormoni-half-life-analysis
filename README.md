# Take-home: IV PK Elimination Half-Life Ranking

## Background

125 peptide variants plus 3 control peptides were dosed IV (single bolus) into
3 animals each. Plasma was sampled at:

`pre-bleed, 5min, 20min, 30min, 1hr, 2hr, 8hr, 16hr, 24hr, 36hr, 48hr, 72hr`

and peptide concentration was quantified by LC-MS. `pre-bleed` is a pre-dose
blank (drawn before the animal received anything).

**Library design.** All 125 library variants share a common 14-residue
scaffold with 3 variable positions, each filled from a set of 5 natural amino
acids (5 x 5 x 5 = 125 designed variants). Only natural amino acids are used.

**Controls.** 3 additional peptides (same length, random natural sequence,
not part of the designed library) were included as internal benchmarks:
`CTRL_short`, `CTRL_medium`, and `CTRL_long`, expected by design to show a
short, medium, and long elimination half-life respectively. Use these as a
sanity check on your own method.

## Task

For each of the 128 molecules, determine the **elimination (terminal)
half-life** — not the early distribution-phase decline — and produce a
ranking from longest to shortest predicted elimination half-life.

Real bioanalytical data is never perfectly clean. Part of this exercise is
deciding what in the raw data you trust enough to base your estimate on, and
being able to explain that decision.

## Data

`data/pk_data.csv` — one row per (animal, molecule, timepoint):

| column | description |
|---|---|
| `animal_id` | 1, 2, or 3 |
| `molecule_id` | `LIB001`-`LIB125` (library) or `CTRL_short`/`CTRL_medium`/`CTRL_long` (controls) |
| `sequence` | full amino acid sequence |
| `is_control` | True for the 3 control peptides |
| `timepoint_label` | e.g. `pre-bleed`, `5min`, `8hr` |
| `hours_post_dose` | numeric hours post-dose (blank for `pre-bleed`) |
| `concentration_ng_ml` | plasma concentration, ng/mL |

## Deliverables

1. **Code/notebook** you used to get from raw data to your answer.
2. **A ranked table**: `molecule_id`, your estimated elimination half-life
   (hours), and rank (1 = longest half-life). CSV is fine.
3. **A short written rationale** (bullets are fine, aim for ~5-10 sentences):
   what you excluded from the raw data (if anything) and why, what
   assumptions you made, how confident you are in the ranking, and what
   you'd want to check next if you had more time.

## Using AI tools

You're welcome and encouraged to use whatever AI coding assistant you
normally use. In your rationale, briefly note where it helped and whether
there was anywhere you had to correct or override what it produced.

## Time

Budget 2 focused hours; 4 hours as a hard cap. We're weighing
your judgment and reasoning at least as much as the polish of the final
ranking — a well-reasoned, partially-complete answer beats a confident
answer with no explanation of the choices behind it.

We'll go over your approach together afterward and extend the analysis live.
