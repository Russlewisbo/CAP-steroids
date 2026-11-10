#!/usr/bin/env python3
"""Torres 2015 supplement (torres_suppliment.pdf, obtained 10 Nov 2026): add its combined counts to the extraction database
and record that it reports both arms for GI bleeding and super-infection.

  * four new outcomes_binary rows (rank 1, ITT): new invasive ventilation 5/61 vs 9/59 and new septic shock 2/61 vs 7/59,
    early and late treatment failure combined (0 to 120 h), from eFigure 1 (supplement PDF page 14). They equal the sums of the
    two Table 2 windows in the main report (R1113): ventilation 4+1 vs 5+4, shock 2+0 vs 3+4.
  * the `notes` of the four existing Torres GI-bleeding and super-infection rows (rowids 156, 157, 158, 159) gain a line saying
    that eTable 8 (supplement PDF page 13) reports both arms, so the zero previously inferred from the text is reported.
  Every change is logged in `changelog`. The supplement is a companion of R1113, not a new record, so the `records` table (55 rows)
  is unchanged.

DRY RUN BY DEFAULT: the database is opened read-only (immutable), copied into memory and changed there; nothing is written.
With --apply the script first copies the database to `<db>.bak-2026-11-10-torres-supplement` (never overwritten), then writes the
changes and regenerates csv/ as the earlier apply_*.py scripts do. Idempotent: rerunning after --apply reports no changes.

Usage:  python3 apply_torres_supplement_2026-11-10.py [--db PATH] [--apply]
"""
import argparse
import shutil
import sqlite3
import sys
from pathlib import Path

TODAY = "2026-11-10"
WHO = "Claude (recording the Torres supplement counts; lead decision 10 Nov 2026, plan question Q1 option a)"
REASON = "Torres 2015 supplement obtained 10 Nov 2026 (torres_suppliment.pdf)"
DEFAULT_DB = Path.home() / "Desktop/CAP-steroids-resources/cap-steroids-fulltext/_extraction/cap_steroids_extraction.sqlite"

ap = argparse.ArgumentParser()
ap.add_argument("--db", type=Path, default=DEFAULT_DB)
ap.add_argument("--apply", action="store_true")
args = ap.parse_args()
if not args.db.exists():
    sys.exit(f"Database not found: {args.db}")
if Path(str(args.db) + "-journal").exists():
    sys.exit("Hot rollback journal present; do not open the database until it is resolved.")

if args.apply:
    backup = Path(str(args.db) + ".bak-2026-11-10-torres-supplement")
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
cur = con.cursor()
cols = [r[1] for r in cur.execute("pragma table_info(outcomes_binary)")]

NEW_ROWS = [
    # outcome, arm, events, denominator, quote
    ("imv_new", "STEROID", 5, 61, "Mechanical ventilation (early and late treatment failure combined): 5/61 methylprednisolone vs 9/59 placebo (p=0.23)"),
    ("imv_new", "CONTROL", 9, 59, "Mechanical ventilation (early and late treatment failure combined): 5/61 methylprednisolone vs 9/59 placebo (p=0.23)"),
    ("septic_shock_new", "STEROID", 2, 61, "Septic shock (early and late treatment failure combined): 2/61 methylprednisolone vs 7/59 placebo (p=0.092)"),
    ("septic_shock_new", "CONTROL", 7, 59, "Septic shock (early and late treatment failure combined): 2/61 methylprednisolone vs 7/59 placebo (p=0.092)"),
]
NOTE_ADD = "Both arms reported in Supplement eTable 8 (torres_suppliment.pdf, PDF page 13), checked 10 Nov 2026; the zero is reported, not inferred."
NOTE_ROWS = [(156, "secondary_infection", "STEROID"), (157, "secondary_infection", "CONTROL"),
             (158, "gi_bleeding", "STEROID"), (159, "gi_bleeding", "CONTROL")]

log = []
def logrow(key, field, old, new):
    cur.execute("insert into changelog values(?,?,?,?,?,?,?,?)", (TODAY, WHO, "outcomes_binary", key, field, old, new, REASON))
    log.append((key, field, old, new))

for outcome, arm, ev, den, quote in NEW_ROWS:
    exists = cur.execute("select count(*) from outcomes_binary where trial_id='TORRES2015' and arm_id=? and outcome=? and timepoint='0-120h'",
                         (arm, outcome)).fetchone()[0]
    if exists:
        continue
    row = dict.fromkeys(cols)
    row.update(trial_id="TORRES2015", arm_id=arm, outcome=outcome, timepoint="0-120h", events=ev, denominator=den, population="ITT",
               source_record_id="R1113", source_rank=1, page=14, printed_page=None,
               location="Supplement eFigure 1 (torres_suppliment.pdf, PDF page 14)", quote=quote,
               extractor="claude-supp-2026-11-10",
               verified="Y - assistant cross-check 2026-11-10: equals the sum of the two Table 2 windows; second extractor not yet",
               notes="Supplement of Torres 2015, a companion of R1113 (separate file). Early (0-72 h) and late (72-120 h) treatment failure combined, ITT; patients counted once.",
               batch="supp_torres_2026-11-10")
    cur.execute(f"insert into outcomes_binary ({','.join(cols)}) values ({','.join('?' * len(cols))})", [row[c] for c in cols])
    logrow(f"TORRES2015|{arm}|{outcome}|0-120h", "(new row)", "", f"{ev}/{den}")

for rid, outcome, arm in NOTE_ROWS:
    r = cur.execute("select notes, trial_id, outcome, arm_id from outcomes_binary where rowid=?", (rid,)).fetchone()
    if r is None or (r[1], r[2], r[3]) != ("TORRES2015", outcome, arm):
        sys.exit(f"rowid {rid} is not the expected Torres {outcome} {arm} row; stopping")
    old = r[0] or ""
    if NOTE_ADD in old:
        continue
    new = (old + " | " if old else "") + NOTE_ADD
    cur.execute("update outcomes_binary set notes=? where rowid=?", (new, rid))
    logrow(f"TORRES2015|{arm}|{outcome}|in_hospital", "notes", old, new)

print(f"Mode: {'APPLY' if args.apply else 'DRY RUN (nothing is written)'}   database: {args.db}")
if not log:
    print("No changes: the database already holds the Torres supplement rows and notes.")
for key, field, old, new in log:
    print(f"\n{key}  [{field}]\n  old: {old!r}\n  new: {new!r}")
ok = cur.execute("pragma integrity_check").fetchone()[0] == "ok"
n_t = cur.execute("select count(*) from outcomes_binary where trial_id='TORRES2015' and timepoint='0-120h'").fetchone()[0]
print(f"\nIntegrity check: {'ok' if ok else 'FAILED'}; Torres 0-120h rows now: {n_t} (expected 4); records rows: "
      f"{cur.execute('select count(*) from records').fetchone()[0]} (unchanged); changelog rows to add: {len(log)}")
print("v_mortality rows for Torres:", cur.execute("select count(*) from v_mortality where trial_id='TORRES2015'").fetchone()[0], "(unchanged by this script)")

if args.apply:
    if not ok:
        con.rollback()
        sys.exit("Integrity check failed; rolled back.")
    con.commit()
    import pandas as pd
    out = args.db.parent / "csv"
    out.mkdir(exist_ok=True)
    for t in ["records", "trials", "arms", "outcomes_binary", "outcomes_continuous", "effect_estimates", "subgroups",
              "rob2_signals", "rob2_judgements", "record_roles", "issues", "changelog"]:
        pd.read_sql(f"select * from {t}", con).to_csv(out / f"{t}.csv", index=False)
    pd.read_sql("select * from v_mortality order by final_set, trial_id, timepoint", con).to_csv(out / "mortality_summary.csv", index=False)
    print(f"\nWritten: {len(log)} change(s); csv/ regenerated in {out}. Next: rebuild the workbook (build_xlsx_2026-11-04.R) and check it.")
else:
    print("\nDry run only. Re-run with --apply to write (a backup is made first).")
con.close()
