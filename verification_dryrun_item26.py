#!/usr/bin/env python3
"""Dry run for Status.md item 26: list effect_estimates (and subgroups) rows of
Tongyoo, REMAP-CAP and subgroup-derived trials that have no `verified` entry.

Read-only: the database is opened with SQLite's immutable URI flag, so nothing
is written and no journal is touched. Output goes to the terminal only.

Usage: python3 verification_dryrun_item26.py [path/to/cap_steroids_extraction.sqlite]
"""
import sqlite3
import sys
from pathlib import Path

DEFAULT_DB = Path.home() / "Desktop/cap-steroids-fulltext/_extraction/cap_steroids_extraction.sqlite"
db = Path(sys.argv[1]) if len(sys.argv) > 1 else DEFAULT_DB
if not db.exists():
    sys.exit(f"Database not found: {db}")

con = sqlite3.connect(f"file:{db}?immutable=1", uri=True)
con.row_factory = sqlite3.Row

trials = con.execute(
    """SELECT trial_id, final_set, sensitivity_flags FROM trials
       WHERE trial_id IN ('TONGYOO2016', 'REMAPCAP2025')
          OR sensitivity_flags LIKE '%subgroup_derived%'
       ORDER BY trial_id"""
).fetchall()
ids = [t["trial_id"] for t in trials]
print("Trials in scope:")
for t in trials:
    print(f"  {t['trial_id']:<20} {t['final_set']:<12} {t['sensitivity_flags'] or ''}")

q = ",".join("?" * len(ids))
todo = "(verified IS NULL OR TRIM(verified) = '')"

print("\n== effect_estimates rows lacking a verified entry ==")
rows = con.execute(
    f"""SELECT rowid, trial_id, outcome, timepoint, comparison, measure, estimate,
               ci_low, ci_high, se, adjusted, source_record_id, page, location
        FROM effect_estimates WHERE trial_id IN ({q}) AND {todo}
        ORDER BY trial_id, rowid""",
    ids,
).fetchall()
for r in rows:
    print(f"[{r['rowid']}] {r['trial_id']} | {r['outcome']} | {r['timepoint']} | {r['comparison']} | "
          f"{r['measure']} {r['estimate']} ({r['ci_low']} to {r['ci_high']}) se={r['se']} "
          f"adj={r['adjusted']} | {r['source_record_id']} p{r['page']} {r['location']}")
print(f"\n{len(rows)} effect_estimates rows to sign off")

print("\n== subgroups rows lacking a verified entry (counts by trial) ==")
for r in con.execute(
    f"""SELECT trial_id, COUNT(*) n FROM subgroups
        WHERE trial_id IN ({q}) AND {todo} GROUP BY trial_id ORDER BY trial_id""",
    ids,
):
    print(f"  {r['trial_id']:<20} {r['n']}")

print("\nNo changes made. Applying 'verified' entries needs a separate script that also writes `changelog`.")
