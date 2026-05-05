
### File 3 — Skill demand analysis
 
**Queries in this file:**

| Query | What it answers |
|---|---|
| Q3.1 | Top 20 skills by total posting volume |
| Q3.2 | Skill demand breakdown by quarter with market share |
| Q3.3 | Full skill shift table Q1 → Q2 (rising/falling/stable) |
| Q3.4 | Top 15 fastest rising skills |
| Q3.5 | Top 15 fastest falling skills |
| Q3.6 | Skills most co-listed with Python |
| Q3.7 | Top 5 defining skills per role family |

---

### File 4 — Salary analysis

**Queries in this file:**

| Query | What it answers |
|---|---|
| Q4.1 | P25/median/P75/avg salary per role family |
| Q4.2 | Salary by role — Q1 vs Q2 comparison |
| Q4.3 | Salary premium per skill vs overall baseline |
| Q4.4 | Remote vs on-site salary by role family |
| Q4.5 | Overall remote premium (single summary number) |
| Q4.6 | Salary by experience level from benchmark dataset |
| Q4.7 | Top 10 highest paying companies |

---

### File 5 — Location trends

**Queries in this file:**

| Query | What it answers |
|---|---|
| Q5.1 | Top 20 hiring cities with salary and company count |
| Q5.2 | Top 10 states by posting volume |
| Q5.3 | City market share shift Q1 → Q2 |
| Q5.4 | City salary vs volume scatter data |
| Q5.5 | Top 3 role families per major city |

---

### File 6 — Role family shifts


**Queries in this file:**

| Query | What it answers |
|---|---|
| Q6.1 | Overall role distribution with salary |
| Q6.2 | Role volume Q1 vs Q2 with % change |
| Q6.3 | AI/LLM Engineer postings by quarter and share |
| Q6.4 | Top 10 most active hiring companies |
| Q6.5 | Companies that laid off but continued hiring |
| Q6.6 | Remote ratio trend Q1 vs Q2 |
| Q6.7 | Experience level demand within each role |

---

### File 7 — Create Power BI views

Creates 7 pre-aggregated views. Run once. Views persist in the database.

**Views created:**

| View | Powers |
|---|---|
| `vw_skill_demand_quarterly` | Skill Demand page — treemap, shift bar |
| `vw_role_salary_summary` | Salary Intelligence — box plots, trend |
| `vw_skill_salary_premium` | Salary Intelligence — premium bar |
| `vw_city_summary` | Location Map — map, scatter |
| `vw_role_quarter_summary` | Overview + Role Deep Dive pages |
| `vw_work_mode_summary` | Overview KPI cards + remote trend |
| `vw_layoff_hiring_impact` | Role Deep Dive — layoff impact table |

---
