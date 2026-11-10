#!/usr/bin/env python3
"""Step 3 (NEXT_STEPS.md / Status.md item 13): carry the 10 Nov 2026 lead decisions on Wafy 2021, Mikami 2007 and
Nafae 2013 into the extraction database, which is the source of `build_handoff.py`. Until this is done the next
hand-off export reverts them (Wafy would return to the analysis set as 'pending').

The values come from the repository's `trials.csv` (edited by hand on 10 Nov), not from this script:
  trials.final_set, trials.final_set_reason, trials.sensitivity_flags  <- trials.csv
  trials.decision_date                                                 <- 2026-11-10 (date of the lead decisions)

DRY RUN BY DEFAULT. Without --apply the real database is opened read-only (SQLite immutable mode) and nothing is
written anywhere: the script copies it into memory, applies the changes there, and reports what would change and
whether the hand-off would now match trials.csv. With --apply it first makes a backup copy next to the database
(`<db>.bak-2026-11-10-decisions`; an existing backup is never overwritten), then writes the changes, one
`changelog` row per changed field, and regenerates csv/ as the earlier apply_*.py scripts do.

Usage:
  python3 apply_decisions_2026-11-10.py [--db PATH] [--trials-csv PATH]            # dry run
  python3 apply_decisions_2026-11-10.py --apply [--db PATH] [--trials-csv PATH]    # writes (after backup)
Idempotent: rerunning after --apply reports no changes.
"""
import argparse
import csv
import shutil
import sqlite3
import sys
from pathlib import Path

TODAY = "2026-11-10"
WHO = "Claude (recording lead decisions of R. Lewis, 2026-11-10)"
TRIALS = {
    "WAFY2021": "Excluded on study-integrity grounds (lead decision 10 Nov 2026)",
    "MIKAMI2007": "Mortality confirmed as not reported (lead decision 10 Nov 2026)",
    "NAFAE2013": "Placebo denominator 19 kept, 20 in S-den (lead decision 10 Nov 2026)",
}
FIELDS = ["final_set", "final_set_reason", "sensitivity_flags"]
HERE = Path(__file__).resolve().parent
DEFAULT_DB = Path.home() / "Desktop/CAP-steroids-resources/cap-steroids-fulltext/_extraction/cap_steroids_extraction.sqlite"

ap = argparse.ArgumentParser()
ap.add_argument("--db", type=Path, default=DEFAULT_DB)
ap.add_argument("--trials-csv", type=Path, default=HERE / "trials.csv")
ap.add_argument("--apply", action="store_true", help="write the changes (after making a backup)")
args = ap.parse_args()

if not args.db.exists():
    sys.exit(f"Database not found: {args.db}")
if not args.trials_csv.exists():
    sys.exit(f"trials.csv not found: {args.trials_csv}")
journal = Path(str(args.db) + "-journal")
if journal.exists():
    sys.exit(f"Hot rollback journal present ({journal.name}). Do not open the database until it is resolved "
             "(see Status.md 4 Nov, item 2).")

want = {r["trial_id"]: r for r in csv.DictReader(open(args.trials_csv, newline="", encoding="utf-8"))}
missing = [t for t in TRIALS if t not in want]
if missing:
    sys.exit(f"Not in {args.trials_csv.name}: {missing}")

if args.apply:
    backup = Path(str(args.db) + ".bak-2026-11-10-decisions")
    if backup.exists():
        print(f"Backup already exists, not overwritten: {backup}")
    else:
        shutil.copy2(args.db, backup)
        print(f"Backup written: {backup}")
    con = sqlite3.connect(args.db)
else:
    src = sqlite3.connect(f"file:{args.db}?immutable=1", uri=True)
    con = sqlite3.connect(":memory:")
    src.backup(con)
    src.close()
con.row_factory = sqlite3.Row
cur = con.cursor()

changes = []
for tid, why in TRIALS.items():
    row = cur.execute("select final_set, final_set_reason, sensitivity_flags, decision_date from trials where trial_id=?",
                      (tid,)).fetchone()
    if row is None:
        sys.exit(f"{tid} not in the database")
    new = {f: want[tid][f] for f in FIELDS}
    new["decision_date"] = TODAY
    for field, value in new.items():
        old = row[field] if row[field] is not None else ""
        if old != value:
            changes.append((tid, field, old, value, why))

print(f"\nMode: {'APPLY' if args.apply else 'DRY RUN (nothing is written)'}   database: {args.db}")
if not changes:
    print("No changes: the database already matches the lead decisions.")
for tid, field, old, new, why in changes:
    print(f"\n{tid}.{field}\n  old: {old!r}\n  new: {new!r}\n  reason: {why}")

for tid, field, old, new, why in changes:
    cur.execute(f"update trials set {field}=? where trial_id=?", (new, tid))
    cur.execute("insert into changelog values(?,?,?,?,?,?,?,?)",
                (TODAY, WHO, "trials", tid, field, old, new, why))

# Checks on the (in-memory or real) result
ok = cur.execute("pragma integrity_check").fetchone()[0] == "ok"
handoff = [r[0] for r in cur.execute(
    "select trial_id from trials where final_set in ('primary','sensitivity','pending') order by trial_id")]
print(f"\nIntegrity check: {'ok' if ok else 'FAILED'}")
print(f"Wafy 2021 in the hand-off set (build_handoff.py selects primary, sensitivity, pending): "
      f"{'YES (the exclusion would be reverted)' if 'WAFY2021' in handoff else 'no'}")
mism = [(t, f) for t in TRIALS for f in FIELDS
        if (cur.execute(f"select {f} from trials where trial_id=?", (t,)).fetchone()[0] or "") != want[t][f]]
print(f"Fields still differing from {args.trials_csv.name}: {mism if mism else 'none'}")
print(f"Rows that would be added to changelog: {len(changes)}")
print("v_mortality rows for the three trials:",
      {t: cur.execute("select count(*) from v_mortality where trial_id=?", (t,)).fetchone()[0] for t in TRIALS})

if args.apply:
    if not ok:
        con.rollback()
        sys.exit("Integrity check failed; rolled back.")
    con.commit()
    import pandas as pd  # same export as apply_rob2_consensus_2026-11-04.py
    out = args.db.parent / "csv"
    out.mkdir(exist_ok=True)
    for t in ["records", "trials", "arms", "outcomes_binary", "outcomes_continuous", "effect_estimates", "subgroups",
              "rob2_signals", "rob2_judgements", "record_roles", "issues", "changelog"]:
        pd.read_sql(f"select * from {t}", con).to_csv(out / f"{t}.csv", index=False)
    pd.read_sql("select * from v_mortality order by final_set, trial_id, timepoint", con).to_csv(
        out / "mortality_summary.csv", index=False)
    print(f"\nWritten: {len(changes)} field change(s), csv/ regenerated in {out}.")
    print("Not done here: cap_steroids_extraction.xlsx (build_xlsx_*.R) and analysis_handoff/ (build_handoff.py).")
else:
    print("\nDry run only. Re-run with --apply to write (a backup is made first).")
con.close()
