"""Build the analysis hand-off datasheets from cap_steroids_extraction.sqlite.
Run from _extraction/:  python3 analysis_handoff/build_handoff.py
Every number is pulled from the database by key; nothing is typed in by hand."""
import sqlite3, csv, math, datetime
DB = 'cap_steroids_extraction.sqlite'; OUT = 'analysis_handoff'
con = sqlite3.connect(DB); con.row_factory = sqlite3.Row
today = datetime.date.today().isoformat()

tcols = ["trial_id","acronym","final_set","final_set_reason","sensitivity_flags","design","blinding",
 "n_randomized","n_analysed_primary","countries","n_centres","setting","resource_level","severity_population",
 "severity_definition","severe_subgroup_reported","pct_septic_shock_baseline","pct_imv_baseline","pct_influenza_viral",
 "agent","agent_cluster","dose_regimen","prednisone_equiv_mg_day","route","timing_from_admission","duration_days",
 "mineralocorticoid","comparator","steroid_free_arm","enrolment_period","primary_outcome","primary_record_id"]
rec = {r['trial_id']: r for r in con.execute("select t.trial_id, r.first_author, r.year, r.journal, r.doi from trials t join records r on r.record_id=t.primary_record_id")}
arm = {}
for r in con.execute("select trial_id, arm_id, age_mean, age_median, pct_male, pct_psi_4_5 from arms where arm_id in ('STEROID','CONTROL')"):
    arm.setdefault(r['trial_id'], {})[r['arm_id']] = r
def avg(t, col):
    v = [arm[t][a][col] for a in arm.get(t, {}) if arm[t][a][col] is not None]
    return round(sum(v)/len(v), 1) if v else None
agent_cluster_analysis = {'SONIA2025': 'mixed', 'HAGMAN2026': 'other_betamethasone', 'WAFY2021': 'unspecified'}
labels = {}
with open(f'{OUT}/trials.csv', 'w', newline='') as f:
    w = csv.writer(f)
    w.writerow(['study_label','first_author','year','journal','doi'] + tcols + ['agent_cluster_analysis','age_central_trial','pct_male_trial','pct_psi_4_5_trial','rob2_overall_mortality'])
    for t in con.execute("select * from trials where final_set in ('primary','sensitivity','pending') order by case final_set when 'primary' then 1 when 'sensitivity' then 2 else 3 end, trial_id"):
        tid = t['trial_id']; rr = rec[tid]
        fa = rr['first_author'].split(',')[0].split(' ')[0].replace('.', '')
        label = f"{fa} {rr['year']}" + (f" ({t['acronym'].split(' (')[0]})" if t['acronym'] else '')
        labels[tid] = label
        w.writerow([label, rr['first_author'], rr['year'], rr['journal'], rr['doi']] + [t[c] for c in tcols] +
                   [agent_cluster_analysis.get(tid, t['agent_cluster']), avg(tid,'age_mean') or avg(tid,'age_median'), avg(tid,'pct_male'), avg(tid,'pct_psi_4_5'), 'PENDING'])

with open(f'{OUT}/mortality_long.csv', 'w', newline='') as f:
    w = csv.writer(f)
    w.writerow(['trial_id','final_set','row_type','subgroup_variable','subgroup_level','timepoint','population','r1','n1','r0','n0','source_rank','source_record_id','page','location','notes'])
    for r in con.execute("select * from v_mortality where final_set in ('primary','sensitivity','pending') order by trial_id, timepoint, source_rank"):
        w.writerow([r['trial_id'], r['final_set'], 'whole_trial', '', '', r['timepoint'], r['population'], r['steroid_events'], r['steroid_n'], r['control_events'], r['control_n'], r['source_rank'], r['source_record_id'], r['page'], r['location'], ''])
    q = """select s.trial_id, t.final_set, s.subgroup_variable, s.subgroup_level, s.timepoint,
           max(case when arm_id='STEROID' then events end) r1, max(case when arm_id='STEROID' then denominator end) n1,
           max(case when arm_id='CONTROL' then events end) r0, max(case when arm_id='CONTROL' then denominator end) n0,
           s.source_record_id, max(s.page) page, max(s.location) location, max(s.prespecified) presp, max(s.stratified_randomization) strat
           from subgroups s join trials t using(trial_id)
           where s.outcome='all_cause_mortality' and s.events is not null and t.final_set in ('primary','sensitivity')
           group by s.trial_id, s.subgroup_variable, s.subgroup_level, s.timepoint, s.source_record_id order by 1,3,4,5"""
    for r in con.execute(q):
        w.writerow([r['trial_id'], r['final_set'], 'subgroup', r['subgroup_variable'], r['subgroup_level'], r['timepoint'], 'as reported', r['r1'], r['n1'], r['r0'], r['n0'], 1, r['source_record_id'], r['page'], r['location'], f"prespecified={r['presp']}; stratified_randomization={r['strat']}"])
    for r in con.execute("select * from effect_estimates where trial_id='REMAPCAP2025' and outcome='all_cause_mortality' order by rowid"):
        w.writerow([r['trial_id'], 'primary', 'contrast', 'posterior_OR', r['population'], r['timepoint'], r['population'], '', '', '', '', 1, r['source_record_id'], r['page'], r['location'], f"OR {r['estimate']} ({r['ci_low']}-{r['ci_high']}); {r['probability_statements']}; {r['adjustment_model'][:90]}..."])

def whole(tid, tp, pop, rec_id):
    r = con.execute("select * from v_mortality where trial_id=? and timepoint=? and population=? and source_record_id=?", (tid, tp, pop, rec_id)).fetchone()
    assert r, (tid, tp, pop, rec_id)
    return dict(r1=r['steroid_events'], n1=r['steroid_n'], r0=r['control_events'], n0=r['control_n'], rank=r['source_rank'], rec=rec_id, page=r['page'], loc=r['location'])
def sub(tid, var, lvl, tp):
    r = con.execute("""select max(case when arm_id='STEROID' then events end) r1, max(case when arm_id='STEROID' then denominator end) n1,
        max(case when arm_id='CONTROL' then events end) r0, max(case when arm_id='CONTROL' then denominator end) n0, max(source_record_id) rec, max(page) page, max(location) loc
        from subgroups where trial_id=? and subgroup_variable=? and subgroup_level=? and timepoint=? and outcome='all_cause_mortality'""", (tid, var, lvl, tp)).fetchone()
    assert r['n1'], (tid, var, lvl, tp)
    return dict(r1=r['r1'], n1=r['n1'], r0=r['r0'], n0=r['n0'], rank=1, rec=r['rec'], page=r['page'], loc=r['loc'])
def contrast(est, lo, hi, tp):
    r = con.execute("select * from effect_estimates where trial_id='REMAPCAP2025' and estimate=? and ci_low=? and ci_high=? and timepoint=?", (est, lo, hi, tp)).fetchone()
    assert r, (est, lo, hi)
    yi = math.log(est); sei = (math.log(hi) - math.log(lo)) / (2*1.959964)
    return dict(yi=round(yi, 4), sei=round(sei, 4), rank=1, rec=r['source_record_id'], page=r['page'], loc=r['location'], or_=est, lo=lo, hi=hi)

T = {t['trial_id']: t for t in con.execute("select * from trials")}
rows = []
def add(tid, tp, tpclass, pop, d, F1=0, F2=0, F3=0, F4=0, IPD=0, dtype='counts', subgroup='', note='', cluster=None):
    t = T[tid]
    rows.append(dict(trial_id=tid, study_label=labels[tid], final_set=t['final_set'], data_type=dtype,
        agent_cluster=cluster or agent_cluster_analysis.get(tid, t['agent_cluster']), timepoint=tp, timepoint_class=tpclass, population=pop, subgroup=subgroup,
        r1=d.get('r1',''), n1=d.get('n1',''), r0=d.get('r0',''), n0=d.get('n0',''), yi=d.get('yi',''), sei=d.get('sei',''),
        reported_OR=d.get('or_',''), reported_CrI_low=d.get('lo',''), reported_CrI_high=d.get('hi',''),
        fit_primary_short=F1, fit_primary_d90=F2, fit_broad_severe=F3, fit_all_hospitalised=F4, fit_ipd_crosscheck=IPD,
        source_rank=d['rank'], source_record_id=d['rec'], pdf_page=d['page'], location=d['loc'], sensitivity_flags=t['sensitivity_flags'] or '', notes=note))

# ---- PRIMARY SET (7) ----
add('MARIK1993','ICU','short_term','as reported', whole('MARIK1993','ICU','as reported','R0150'), F1=1,F3=1,F4=1, note='ICU mortality is the only timepoint reported; single-bolus trial (sensitivity fit ix drops it)')
add('CONFALONIERI2005','in_hospital','short_term','mITT', whole('CONFALONIERI2005','in_hospital','mITT','R0385'), F1=1,F3=1,F4=1, note='in_hospital = d28 in this trial (0/23 vs 7/23); zero-event steroid arm -> exact binomial likelihood only; continuity correction needed in any log-OR fit')
add('CONFALONIERI2005','d60','d60_other','mITT', whole('CONFALONIERI2005','d60','mITT','R0385'), note='Secondary timepoint; never pooled with d90 rows')
add('CONFALONIERI2005','d30','short_term','ITT', whole('CONFALONIERI2005','d30','ITT','R2626'), IPD=1, note='Smit 2025 IPD (rank 2): 0/23 vs 8/23 ITT; differs from primary-report mITT 7/23')
add('TORRES2015','in_hospital','short_term','ITT', whole('TORRES2015','in_hospital','ITT','R1113'), F1=1,F3=1,F4=1, note='ITT in-hospital; PP 3/55 vs 7/57 not used')
add('TORRES2015','d30','short_term','ITT', whole('TORRES2015','d30','ITT','R2626'), IPD=1, note='Smit 2025 IPD (rank 2); identical to primary report')
add('MEDURI2022','in_hospital','short_term','ITT', whole('MEDURI2022','in_hospital','ITT','R2113'), F1=1,F3=1,F4=1, note='DECISION D1 - DEFAULT per protocol field 24 (earliest of in-hospital/d28/d30; rank 1). Trial primary endpoint is d60 (row below). Direction differs: in-hospital 34 vs 28, d60 47 vs 50. Run both; lead confirms before the final run')
add('MEDURI2022','d60','d60_other','ITT', whole('MEDURI2022','d60','ITT','R2113'), note='Trial primary endpoint (d60). Alternative F1 row under decision D1. Not pooled with d90 rows')
add('MEDURI2022','d30','short_term','ITT', whole('MEDURI2022','d30','ITT','R2626'), IPD=1, note='Smit 2025 IPD (rank 2) 30-day reconstruction 40/297 vs 40/287 (denominators = randomized); second alternative F1 row under decision D1')
add('DEQUIN2023','d28','short_term','mITT', whole('DEQUIN2023','d28','mITT','R2257'), F1=1,F3=1,F4=1, note='Trial primary endpoint')
add('DEQUIN2023','d90','d90','mITT', whole('DEQUIN2023','d90','mITT','R2257'), F2=1, note='Denominators 388/389 flagged in issues (vs 400/395 at d28)')
add('DEQUIN2023','d30','short_term','ITT', whole('DEQUIN2023','d30','ITT','R2626'), IPD=1, note='Smit 2025 IPD (rank 2) 27/400 vs 49/395 vs primary d28 25/400 vs 47/395')
add('APROCCHSS_CAP2024','d28','short_term','ITT', whole('APROCCHSS_CAP2024','d28','ITT','R2419'), F1=1,F3=1,F4=1, note='CAP-septic-shock subgroup (a priori exploratory, NOT stratified); HC + fludrocortisone; 100% shock, 96% IMV -> sensitivity fits vi and viii drop this trial')
add('APROCCHSS_CAP2024','d90','d90','ITT', whole('APROCCHSS_CAP2024','d90','ITT','R2419'), F2=1, note='Trial primary endpoint (d90)')
c = contrast(1.56, 0.8, 3.31, 'd90')
add('REMAPCAP2025','d90','d90','adjusted', c, F1=1,F2=1,F3=1,F4=1, dtype='contrast', note='CONTRAST-BASED ONLY. Pooled full-borrowing posterior OR 1.56 (95% CrI 0.80-3.31), P(harm) 90%, P(>20% RRR) 3.4%. sei is an INTERIM approximation from the CrI ((ln hi - ln lo)/3.92); replace with the investigator-supplied log-OR SE when received (Status item 6). Used in F1 because no valid short-term contrast exists - DECISION D2. Crude counts (78/521 vs 12/122) must never enter a binomial likelihood')
c2 = contrast(1.49, 0.62, 4.18, 'ICU')
add('REMAPCAP2025','ICU','short_term','adjusted', c2, dtype='contrast', note='Alternative F1 contrast (ICU-discharge mortality, adjusted posterior OR) - DECISION D2 sensitivity only')
c3 = contrast(1.55, 0.75, 3.63, 'd90')
add('REMAPCAP2025','d90','d90','adjusted', c3, dtype='contrast', note='Alternative d90 contrast: 70 sites offering both arms (n=455, "2-arm RCT mimic") - sensitivity only')
# ---- SEVERE SUBGROUPS of all-hospitalised trials (broad-severe fit F3) ----
add('SNIJDERS2010','d30','short_term','ITT', sub('SNIJDERS2010','PSI class','IV-V','d30'), F3=1, subgroup='PSI IV-V', note='Prespecified severe subgroup; randomisation not stratified')
add('SNIJDERS2010','d30','short_term','ITT', sub('SNIJDERS2010','CURB-65','3-5','d30'), subgroup='CURB-65 3-5', note='Alternative severity definition for an F3 sensitivity; denominators corrected 28/26 (table misprint) - verify')
add('WITTERMANS2021','d30','short_term','ITT', sub('WITTERMANS2021','PSI class','IV–V (severe CAP)','d30'), F3=1, subgroup='PSI IV-V', note='Prespecified AND stratified (highest-credibility severe subgroup)')
add('SONIA2025','d30','short_term','ITT', sub('SONIA2025','oxygen saturation at admission','<90% (hypoxaemic)','d30'), F3=1, subgroup='SpO2 <90% at admission', cluster='mixed', note='Prespecified hypoxaemic subgroup; steroid arm mixes 4 agents -> cluster "mixed" vs whole control (27 Oct agent-mix rule)')
# ---- ALL-HOSPITALISED / SENSITIVITY SET whole-trial rows (F4) ----
add('MCHARDY1972','end_of_study','short_term','as reported', whole('MCHARDY1972','end_of_study','as reported','R0012'), F4=1, note='Quasi-randomised factorial, open; ages >=12; sensitivity fit ii drops it')
add('SNIJDERS2010','d30','short_term','ITT', whole('SNIJDERS2010','d30','ITT','R0721'), F4=1)
add('MEIJVIS2011','d30','short_term','ITT', whole('MEIJVIS2011','d30','ITT','R0786'), F4=1, note='OPEN ISSUE: placebo deaths 11 (Lancet Table 2) vs 9 (Wittermans 2022, Smit 2025 IPD); primary report used until Briel 2018 IPD is checked')
add('MEIJVIS2011','d30','short_term','ITT', whole('MEIJVIS2011','d30','ITT','R2626'), IPD=1, note='Smit 2025 IPD (rank 2): 9/151 vs 9/153')
add('STEP2015','d30','short_term','ITT', whole('STEP2015','d30','ITT','R1093'), F4=1, note='ITT; PP 15 vs 16 steroid deaths discrepancy across reports (issues)')
add('STEP2015','d30','short_term','ITT', whole('STEP2015','d30','ITT','R2626'), IPD=1, note='Smit 2025 IPD (rank 2): 15/392 vs 13/393')
add('WITTERMANS2021','d30','short_term','ITT', whole('WITTERMANS2021','d30','ITT','R1765'), F4=1)
add('SONIA2025','d30','short_term','ITT', whole('SONIA2025','d30','ITT','R2501'), F4=1, cluster='mixed', note='Trial primary endpoint; open-label pragmatic; cluster "mixed"')
add('HAGMAN2026','d56','short_term','ITT', whole('HAGMAN2026','d56','ITT','R2679'), F4=1, cluster='other_betamethasone', note='Double-zero trial: contributes nothing to the treatment effect under an exact binomial likelihood but is listed for completeness; must be dropped from any contrast-based (log-OR) fit')
add('FERNANDEZSERRANO2011','end_of_study','short_term','mITT', whole('FERNANDEZSERRANO2011','end_of_study','mITT','R0789'), F4=1, note='Severity not met (shock/MV excluded); 56 randomised, 45 analysed')
add('NAFAE2013','in_hospital','short_term','as reported', whole('NAFAE2013','in_hospital','as reported','R0943'), F4=1, note='Mixed severity; 3:1 allocation; placebo denominator 19 vs 20 (discrepancy)')
add('TONGYOO2016','d28','short_term','ITT', sub('TONGYOO2016','source_of_infection','pneumonia','d28'), F4=1, subgroup='pneumonia source (CAP unconfirmed)', note='Sepsis-ARDS RCT, prespecified pneumonia-source subgroup; CAP not confirmed; subgroup_derived -> dropped in fit vi')
add('TONGYOO2016','d60','d60_other','ITT', sub('TONGYOO2016','source_of_infection','pneumonia','d60'), subgroup='pneumonia source (CAP unconfirmed)')

cols = list(rows[0].keys())
with open(f'{OUT}/analysis_mortality.csv', 'w', newline='') as f:
    w = csv.DictWriter(f, fieldnames=cols); w.writeheader(); w.writerows(rows)
for flag, n in [('fit_primary_short',7),('fit_primary_d90',3),('fit_broad_severe',10),('fit_all_hospitalised',17)]:
    ids = {r['trial_id'] for r in rows if r[flag]}
    assert len(ids)==n and len([r for r in rows if r[flag]])==n, (flag, sorted(ids))
print('OK', today, 'rows:', len(rows))
