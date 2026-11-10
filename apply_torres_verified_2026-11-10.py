#!/usr/bin/env python3
"""Record in the extraction database that the second extractor checked the four Torres 2015 supplement rows
(outcomes_binary, TORRES2015, timepoint 0-120h, batch supp_torres_2026-11-10; new ventilation and new septic shock, eFigure 1).

Only the `verified` text of those four rows changes; each change is logged in `changelog`. First run: "second extractor" without
initials (R. Lewis reported the check on 10 Nov 2026). Second run (this version of NEW): initials MCA added; the earlier assistant
cross-check stays in the text. Rows already carrying the current text are left alone.

DRY RUN BY DEFAULT (database opened read-only, changed in memory). With --apply: backup `<db>.bak-2026-11-10-torres-verified-initials` first
(never overwritten), then write, then regenerate csv/ as the earlier apply_*.py scripts do. Idempotent.
Usage:  python3 apply_torres_verified_2026-11-10.py [--db PATH] [--apply]
"""
import argparse, shutil, sqlite3, sys
from pathlib import Path

TODAY = "2026-11-10"
WHO = "Claude (recording the second-extractor check by MCA, reported by R. Lewis, 2026-11-10)"
REASON = "Second extractor (MCA) checked the Torres 2015 supplement rows (eFigure 1); reported 10 Nov 2026; initials added"
NEW = ("Y - MCA (second extractor) 2026-11-10 (check reported by R. Lewis). "
       "Earlier: assistant cross-check 2026-11-10, equals the sum of the two Table 2 windows")
DEFAULT_DB = Path.home() / "Desktop/CAP-steroids-resources/cap-steroids-fulltext/_extraction/cap_steroids_extraction.sqlite"

ap = argparse.ArgumentParser(); ap.add_argument("--db", type=Path, default=DEFAULT_DB); ap.add_argument("--apply", action="store_true")
args = ap.parse_args()
if not args.db.exists(): sys.exit(f"Database not found: {args.db}")
if Path(str(args.db) + "-journal").exists(): sys.exit("Hot rollback journal present; stopping.")
if args.apply:
    backup = Path(str(args.db) + ".bak-2026-11-10-torres-verified-initials")
    if backup.exists(): print(f"Backup already exists, not overwritten: {backup}")
    else: shutil.copy2(args.db, backup); print(f"Backup written: {backup}")
    con = sqlite3.connect(args.db)
else:
    src = sqlite3.connect(f"file:{args.db}?immutable=1", uri=True); con = sqlite3.connect(":memory:"); src.backup(con); src.close()
cur = con.cursor()
rows = cur.execute("select rowid, arm_id, outcome, verified from outcomes_binary where trial_id='TORRES2015' and timepoint='0-120h' "
                   "and batch='supp_torres_2026-11-10' order by outcome, arm_id").fetchall()
if len(rows) != 4: sys.exit(f"Expected 4 Torres supplement rows, found {len(rows)}; stopping")
log = []
for rid, arm, outcome, old in rows:
    old = old or ""
    if old == NEW: continue
    cur.execute("update outcomes_binary set verified=? where rowid=?", (NEW, rid))
    cur.execute("insert into changelog values(?,?,?,?,?,?,?,?)", (TODAY, WHO, "outcomes_binary", f"TORRES2015|{arm}|{outcome}|0-120h", "verified", old, NEW, REASON))
    log.append((rid, arm, outcome, old, NEW))
print(f"Mode: {'APPLY' if args.apply else 'DRY RUN (nothing is written)'}   database: {args.db}")
if not log: print("No changes: the four rows already carry the second-extractor text.")
for rid, arm, outcome, old, new in log: print(f"\nrowid {rid} TORRES2015 {outcome} {arm}\n  old: {old!r}\n  new: {new!r}")
ok = cur.execute("pragma integrity_check").fetchone()[0] == "ok"
print(f"\nIntegrity check: {'ok' if ok else 'FAILED'}; rows changed: {len(log)}; changelog rows to add: {len(log)}")
if args.apply:
    if not ok: con.rollback(); sys.exit("Integrity check failed; rolled back.")
    con.commit()
    import pandas as pd
    out = args.db.parent / "csv"; out.mkdir(exist_ok=True)
    for t in ["records","trials","arms","outcomes_binary","outcomes_continuous","effect_estimates","subgroups","rob2_signals","rob2_judgements","record_roles","issues","changelog"]:
        pd.read_sql(f"select * from {t}", con).to_csv(out / f"{t}.csv", index=False)
    pd.read_sql("select * from v_mortality order by final_set, trial_id, timepoint", con).to_csv(out / "mortality_summary.csv", index=False)
    print(f"Written; csv/ regenerated in {out}. Next: rebuild the workbook and check it.")
else:
    print("\nDry run only. Re-run with --apply to write (a backup is made first).")
con.close()
