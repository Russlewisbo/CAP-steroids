#!/usr/bin/env python3
"""Add El-Ghamrawy 2006 (R0437) and Li (Gang) 2016 (R1251) to the extraction database as full-text records that were obtained,
reviewed and excluded for insufficient data (10 Nov 2026; Li (Gang) assessed by Annamaria). Nothing is extracted from them.

Per study, one row in each of: records, record_roles, trials (final_set = excluded), as for the other excluded studies
(Sabry 2011, Muhammad 2025, Wafy 2021). Every row is logged in `changelog`. The PDFs are not in the full-text folder yet, so
pdf_filename and text_filename stay empty and file_status says so; fill them in when the files are saved.

DRY RUN BY DEFAULT: the database is opened read-only (immutable), copied into memory and changed there; nothing is written.
With --apply: backup `<db>.bak-2026-11-10-excluded-records` first (never overwritten), then write, then regenerate csv/ as the
earlier apply_*.py scripts do. Idempotent: rows already present are left alone.
Usage:  python3 apply_excluded_records_2026-11-10.py [--db PATH] [--apply]
"""
import argparse, shutil, sqlite3, sys
from pathlib import Path

TODAY = "2026-11-10"
WHO = "Claude (recording the full-text decisions reported by R. Lewis, 2026-11-10)"
REASON = "Candidate report obtained, reviewed and excluded at full text for insufficient data (10 Nov 2026)"
DEFAULT_DB = Path.home() / "Desktop/CAP-steroids-resources/cap-steroids-fulltext/_extraction/cap_steroids_extraction.sqlite"
FILESTATUS = "reviewed 10 Nov 2026; file not yet saved in the full-text folder"
BATCH = "fulltext_decisions_2026-11-10"

STUDIES = [
    dict(rid="R0437", trial="ELGHAMRAWY2006", author="El-Ghamraway AH", year=2006,
         title="Effects of low dose hydrocortisone in ICU patients with severe community acquired pneumonia",
         journal="Egyptian Journal of Chest Diseases and Tuberculosis", doi=None, pmid=None, code="I1",
         notes="CENTRAL CN-02053989 (grey literature, n=34 per the screening note). Obtained and reviewed; excluded at full text: insufficient data. Nothing extracted.",
         prov="primary (severe) - verify"),
    dict(rid="R1251", trial="LIGANG2016", author="Li G.", year=2016,
         title="Value of glucocorticoid steroids in the treatment of patients with severe community-acquired pneumonia complicated with septic shock",
         journal="Chinese Critical Care Medicine", doi="10.3760/cma.j.issn.2095-4352.2016.09.003", pmid=None, code="I1",
         notes="Embase 622486791; Chinese language; 'Gang 2016' in Pitre 2025, 'Li 2016' in Wang 2024. Full text assessed by Annamaria; excluded at full text: insufficient data. Nothing extracted.",
         prov="primary (severe) - verify"),
]

ap = argparse.ArgumentParser(); ap.add_argument("--db", type=Path, default=DEFAULT_DB); ap.add_argument("--apply", action="store_true")
args = ap.parse_args()
if not args.db.exists(): sys.exit(f"Database not found: {args.db}")
if Path(str(args.db) + "-journal").exists(): sys.exit("Hot rollback journal present; stopping.")
if args.apply:
    backup = Path(str(args.db) + ".bak-2026-11-10-excluded-records")
    if backup.exists(): print(f"Backup already exists, not overwritten: {backup}")
    else: shutil.copy2(args.db, backup); print(f"Backup written: {backup}")
    con = sqlite3.connect(args.db)
else:
    src = sqlite3.connect(f"file:{args.db}?immutable=1", uri=True); con = sqlite3.connect(":memory:"); src.backup(con); src.close()
cur = con.cursor()
def cols(t): return [r[1] for r in cur.execute(f"pragma table_info({t})")]
log = []
def insert(table, row, key, summary):
    c = cols(table); full = dict.fromkeys(c); full.update(row)
    cur.execute(f"insert into {table} ({','.join(c)}) values ({','.join('?' * len(c))})", [full[k] for k in c])
    cur.execute("insert into changelog values(?,?,?,?,?,?,?,?)", (TODAY, WHO, table, key, "(new row)", "", summary, REASON))
    log.append((table, key, summary))

for s in STUDIES:
    if not cur.execute("select count(*) from records where record_id=?", (s["rid"],)).fetchone()[0]:
        insert("records", dict(record_id=s["rid"], screen_code=s["code"], first_author=s["author"], year=s["year"], title=s["title"],
                               journal=s["journal"], doi=s["doi"], pmid=s["pmid"], file_status=FILESTATUS, trial_id=s["trial"],
                               record_role="primary_report", data_contributed="None: excluded at full text (insufficient data)",
                               role_notes=s["notes"]), s["rid"], f"{s['author']} {s['year']}: full-text record, excluded (insufficient data)")
    if not cur.execute("select count(*) from record_roles where record_id=? and trial_id=?", (s["rid"], s["trial"])).fetchone()[0]:
        insert("record_roles", dict(record_id=s["rid"], trial_id=s["trial"], role="primary_report",
                                    data_contributed="None: excluded at full text (insufficient data)",
                                    file_status="reviewed (file not yet in folder)", notes=s["notes"], batch=BATCH),
               f"{s['rid']}|{s['trial']}", "primary_report; no data contributed")
    if not cur.execute("select count(*) from trials where trial_id=?", (s["trial"],)).fetchone()[0]:
        insert("trials", dict(trial_id=s["trial"], primary_record_id=s["rid"], provisional_set=s["prov"], final_set="excluded",
                              final_set_reason="Obtained and reviewed 10 Nov 2026; excluded at full text: insufficient data.",
                              decision_date=TODAY, batch=BATCH), s["trial"], "final_set = excluded (insufficient data)")

print(f"Mode: {'APPLY' if args.apply else 'DRY RUN (nothing is written)'}   database: {args.db}")
if not log: print("No changes: both studies are already in the database.")
for t, k, sm in log: print(f"  {t:12s} {k:24s} {sm}")
ok = cur.execute("pragma integrity_check").fetchone()[0] == "ok"
n = {t: cur.execute(f"select count(*) from {t}").fetchone()[0] for t in ("records", "record_roles", "trials", "changelog")}
ex = cur.execute("select count(*) from trials where final_set='excluded'").fetchone()[0]
print(f"\nIntegrity check: {'ok' if ok else 'FAILED'}; rows now: {n}; trials excluded: {ex}; changelog rows to add: {len(log)}")
print("v_mortality rows for the two new trials:", cur.execute("select count(*) from v_mortality where trial_id in ('ELGHAMRAWY2006','LIGANG2016')").fetchone()[0], "(expected 0)")
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
