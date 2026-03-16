# Persona: Data Science Lead

## Phase 1: About You

**Job title and industry:** Senior Data Scientist / Analytics Lead at Fielder Foods, a consumer packaged goods company. We make snacks, beverages, and frozen meals — brands you'd recognize at any grocery store. ~2,000 employees.

**Expertise:** Marketing analytics, marketing mix modeling, customer segmentation, A/B testing and experimentation design, statistical modeling, ML pipeline development. Python (pandas, scikit-learn, PyTorch), SQL, dbt, Snowflake, Tableau. PhD in Statistics (focus on causal inference), 6 years in industry. I code daily — Jupyter notebooks, production ML pipelines, dbt models.

**Good day at work:** When a model I built actually changes a marketing decision and we can see the impact in the next quarter's numbers. When the VP of Marketing says "I didn't know that" in response to an analysis — not because the analysis was surprising, but because the data finally made something visible that intuition couldn't. When I have 3 uninterrupted hours to think about a modeling problem.

**Communication preferences:** Precise. I care about methodology and I want Claude to care about it too. Don't hand-wave over statistical assumptions. When I ask about a modeling approach, I want the trade-offs, not just the recommendation. Tables and code snippets over prose. But also: help me translate technical findings into business language — that's my weakness. I can explain p-values to other data scientists all day but struggle to make the CMO care.

## Phase 2: Your Organizations

**Primary context:** Fielder Foods — CPG company, ~2,000 employees. I'm on the Marketing Analytics team (4 data scientists + 2 data analysts). I'm the IC lead — I set technical direction but don't do performance reviews. Team reports to VP of Marketing Analytics, Diane Park. Dotted line to the Chief Data Officer, James Okoye, on data governance and platform decisions.

**Manager:** Diane Park, VP of Marketing Analytics. Former brand manager turned analytics leader — she understands the business side deeply but isn't technical. She trusts my judgment on methodology and translates my findings to the C-suite. She reports to the CMO, which means marketing priorities drive our roadmap.

**Dotted line:** James Okoye, Chief Data Officer. Owns the data platform (Snowflake + dbt), data governance, and the company-wide data strategy. Wants to centralize ML infrastructure. Sometimes his platform priorities conflict with our delivery timelines.

**Key dynamics:**
- Marketing stakeholders want "the number" — a single metric, a clear recommendation. They don't want to hear about confidence intervals or model limitations. I need to give them clarity without losing rigor.
- The marketing mix model is the crown jewel — it determines how $180M in marketing spend gets allocated across channels. When we update the model, the stakes are real. Getting it wrong means misallocating millions.
- Data quality is my upstream bottleneck. The data engineering team (under James) maintains the pipelines, but schema changes break our models quarterly. I've been pushing for a data quality initiative but it's not their top priority.
- Experimentation maturity is low. The company defaults to "we've always done it this way." I'm trying to build a culture of testing, but the brand teams resist A/B tests because they think it slows them down.
- ML model adoption is uneven. I build models that could automate decisions, but stakeholders still export to Excel and make manual calls. The "last mile" of analytics adoption is my biggest frustration.

**Secondary context:** None.

## Phase 3: Key People

1. **Diane Park** — VP Marketing Analytics (my manager). Weekly 1:1. Translates my work to the C-suite. Not technical but asks sharp business questions. Protects the team from ad-hoc requests (mostly).
2. **James Okoye** — Chief Data Officer (dotted line). Monthly check-in. Platform vision is sound but his priorities don't always align with ours. Data quality conversations happen through him.
3. **Rachel Kim** — Marketing Director, Snacks division. My primary stakeholder. Pragmatic, results-oriented, trusts data but wants it fast. She's the best test case for new analytical products — if Rachel adopts it, others will follow.
4. **Sam Torres** — Data Scientist on my team. Strong on ML modeling, weaker on data engineering. I pair with him on the marketing mix model.
5. **Elena Vasquez** — Data Scientist on my team. Specializes in customer segmentation and NLP. Running the segmentation v3 project semi-independently.
6. **Kevin Liu** — Data Engineer (James's team). My main interface for pipeline issues. Responsive but overloaded. Schema changes without notice are a recurring friction point.
7. **Dr. Priya Nair** — Data Scientist on my team. Junior, 1 year in. Strong stats background (PhD), learning the CPG domain. I'm mentoring her on experimentation design.

## Phase 4: Your Work

1. **Marketing Mix Model Rebuild** — Complete rebuild of the MMM that allocates $180M across channels. Current model is 3 years old, uses outdated methodology (frequentist regression). Rebuilding with Bayesian approach (PyMC). Sam and I co-lead. Phase 1 (data audit) complete. Phase 2 (model development) in progress — first results expected in 3 weeks. High visibility — CMO presentation in 6 weeks.
2. **Customer Segmentation v3** — Elena's project. Upgrading from RFM-based segments to behavioral clustering (purchase patterns + digital engagement). Affects targeting for 4 brand teams. In model validation phase — need to prove new segments outperform old ones in a holdout test.
3. **Experimentation Platform** — Building the infrastructure and playbook for company-wide A/B testing. Currently: Jupyter-based analysis, manual assignment. Target: self-service platform with automated statistical analysis. Phase 1 (pilot with Rachel's Snacks team) launching next month.
4. **Data Quality Initiative** — Cross-functional push to improve upstream data reliability. Working with Kevin on schema change notification system and data contracts. James is supportive in principle but it competes with his platform migration priorities.
5. **Tableau Dashboard Consolidation** — 47 marketing dashboards, many redundant or broken. Auditing and consolidating to ~15. Low-glamour but high-impact — right now nobody trusts any single dashboard.

## Phase 5: Thinking Partner

**Hardest part of decisions:** Balancing methodological rigor against business urgency. The marketing mix model should really take 6 months to do right — proper Bayesian calibration, sensitivity analysis, out-of-sample validation. I have 6 weeks for the CMO presentation. I need to deliver something defensible without cutting corners that'll haunt me later.

**Useful pushback:** Challenge me when I'm over-engineering a solution. I'm an academic at heart — I'll spend a week on model architecture when a simpler approach would answer the business question just as well. Also push me on communication — I default to showing the methodology when I should lead with the insight. Help me frame technical work in terms that make Diane's life easier when she presents to the CMO.

**Keeps me up at night:** The marketing mix model. If the new model recommends a meaningfully different channel allocation than the old one, I need to explain why $30M should move from TV to digital (or wherever the data points). The CMO will push back hard. I need the methodology to be bulletproof because the politics will be intense. Also: experimentation platform adoption. If Rachel's pilot doesn't go well, the whole testing culture initiative dies.

## Phase 6: Workflow

**Typical week:** Monday is planning — review PRs on the model repo, check dbt runs, prioritize the week's analysis work. Tuesday-Wednesday is deep work — modeling, coding, analysis. Thursday is stakeholder day — present findings to Rachel or other brand teams, team sync, 1:1 with Diane. Friday is infrastructure and learning — experimentation platform work, reading papers, mentoring Priya.

**Tools:** Python (primary — Jupyter, VS Code), Snowflake (data warehouse), dbt (transformations), Tableau (dashboards), Slack, Confluence (documentation), GitHub (code), Jira (sprint tracking).

**Meetings:** 6-8 per week. 1:1 with Diane, team standup (3x/week), stakeholder readouts (1-2), James CDO sync (monthly), analytics office hours (weekly, open to anyone with questions).

**Code repos:** `fielder/marketing-mix-model` (main model repo, Python), `fielder/analytics-pipelines` (dbt models + shared Python utilities), `fielder/experimentation-toolkit` (new, building the testing framework).

**Vault name:** Analytics Notes
