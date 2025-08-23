# Puffy — Head of Analytics Case Study

This repository contains my full submission for the **Puffy Head of Analytics** assignment.  
It is structured to separate raw data, analysis scripts, outputs, and final deliverables for clarity and reproducibility.

---

## 📊 Questions & Deliverables

### **Question 1 — E-commerce Funnel Analysis**
- **Code**: [Python Funnel Pipeline](notebooks/funnel_pipeline.ipynb) | [SQL Funnel Query](scripts/sql/funnel_closed.sql)  
- **Outputs**:  
  - [Overall Funnel (CSV)](reports/tables/overall_session_funnel.csv)  
  - [Daily Funnel (CSV)](reports/tables/daily_session_funnel.csv)  
  - [Channel Funnel (CSV)](reports/tables/channel_session_funnel.csv)  
- **Figures**: [Daily Conversion Trend](reports/figures/daily_cr_visit_to_purchase.png), [Daily Funnel Counts](reports/figures/daily_funnel_counts.png), [Channel Mediums by Sessions](reports/figures/channel_medium_top_sessions.png), [Overall Session Funnel](reports/figures/overall_session_funnel_counts.png), [Engaged vs All Conversion](reports/figures/engagedVSall.png)


- **Summary**: [Funnel Insights PDF](docs/puffy_case_study.pdf#page=1)

---

### **Question 2 — PDP Heatmap Analysis**
- **Inputs**: Heatmap screenshot (in `data/`)  
- **Outputs**: [Heatmap Analysis Table](reports/tables/HeatmapAnalysis.csv)  
- **Summary**: See **Section 2** of [Final Case Study PDF](docs/puffy_case_study.pdf#page=5)

---

### **Question 3 — Exclusive Discount Popup Test**
- **Inputs**: [Popup Results CSV](data/raw/exclusive_discount_popup_results.csv)  
- **Code**: [Popup Analysis Script](scripts/python/popup_analysis.py)  
- **Outputs**: [Popup Test Tables](reports/tables/popup_test_summary.csv)  
- **Summary**: See **Section 3** of [Final Case Study PDF](docs/puffy_case_study.pdf#page=8)

---

### **Question 4 — Process & AI Usage**
- **Narrative**: Reflections on how AI was used as a copilot, paired with business judgment.  
- **Summary**: See **Section 4** of [Final Case Study PDF](docs/puffy_case_study.pdf#page=12)

---

## ⚡ Highlights
- Session-level funnel built in **Python + SQL**, cross-validated manually.  
- Clear link between **quantitative funnel leaks** and **behavioral psychology** (heatmaps, promos, trust signals).  
- Mystery discount popup → **more signups but lower RPV & AOV** → do not roll out as-is.  
- AI used as a **copilot** (for code drafting, summarization, and visuals), but all **strategic insights & QA** done manually.  

---

## 📎 Final Deliverable
👉 [Full Case Study PDF](docs/puffy_case_study.pdf)  
