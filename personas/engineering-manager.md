# Persona: Engineering Manager

## Phase 1: About You

**Job title and industry:** Engineering Manager at a fintech company called PayFlow. We build payment processing infrastructure.

**Expertise:** Distributed systems, microservices architecture, team management (8 direct reports), incident response, SRE practices, Go and Python, AWS infrastructure. Former senior backend engineer — moved to management 3 years ago.

**Good day at work:** Unblocking my team. When I spend the day pairing on architecture decisions, doing 1:1s that actually help people grow, and clearing organizational obstacles instead of sitting in status meetings.

**Communication preferences:** Direct. I want the bottom line first, then supporting detail if I ask. Bullets over paragraphs. Don't sugarcoat problems — I'd rather hear "this is broken and here's why" than a diplomatic walkthrough.

## Phase 2: Your Organizations

**Primary context:** PayFlow — Series C fintech startup, ~200 employees. I run the Platform Engineering team (8 engineers). We own the payment processing pipeline, API gateway, and observability stack.

**Manager:** VP of Engineering, Sarah Chen. Very supportive, gives me autonomy but expects clear metrics on team delivery. She reports to the CTO, Marcus Webb, who's more hands-off but cares deeply about system reliability — our uptime SLA is 99.99%.

**Key dynamics:**
- Constant tension between product speed and platform reliability. Product teams want to ship fast, my team maintains the rails they ship on.
- We're mid-migration from a monolith to microservices. About 60% done. The remaining 40% is the hard parts — payment reconciliation and ledger.
- Hiring is slow. Two open reqs have been posted for 3 months. Team is stretched.

**Secondary context:** None. Some open source maintenance on the side (a Go observability library, "gometrics") but it's minimal.

## Phase 3: Key People

1. **Sarah Chen** — VP Engineering (my manager). Weekly 1:1s. Ally. Wants metrics and clear communication about risks.
2. **Marcus Webb** — CTO. Monthly skip-level. Cares about uptime and architecture direction. Skeptical of "move fast and break things."
3. **Priya Patel** — Staff Engineer on my team. Technical lead for the monolith migration. Brilliant but overcommitted. I need to protect her time.
4. **James Liu** — Senior Engineer. Owns the API gateway. Reliable, doesn't escalate enough — problems get big before I hear about them.
5. **Rachel Torres** — Product Director. Counterpart on the product side. Good relationship but we clash on timelines. She pushes for features, I push for stability.
6. **Dev Sharma** — SRE Lead (different team, but we collaborate daily). Owns alerting and on-call rotation. Wants us to adopt their new observability platform.
7. **Alex Kim** — Junior Engineer, 6 months in. High potential, needs mentorship. Assigned to the API gateway with James.

## Phase 4: Your Work

1. **Monolith Migration** — The big one. Decomposing payment processing monolith into services. Priya leads technically, I handle cross-team coordination and stakeholder management. ~18 month timeline, 10 months in.
2. **API Gateway v2** — Rewriting the API gateway to support multi-tenant routing. James owns it. Blocked on a design decision about authentication architecture.
3. **Team Health & Hiring** — Two open reqs (senior and mid-level). Retention risk on one engineer who's been on-call too much. 1:1s, career development, performance reviews coming up in April.
4. **Observability Migration** — Dev's team wants us to adopt their new platform. Good idea long-term but the migration cost is real and my team is already stretched.
5. **gometrics (OSS)** — Go library for structured metrics. Low priority, community contributions mostly. ~2 hours/week.

## Phase 5: Thinking Partner

**Hardest part of decisions:** Sequencing. I always have more important work than capacity. The hard part isn't knowing what to do — it's knowing what to say no to or delay without creating bigger problems downstream.

**Useful pushback:** Challenge my sequencing logic. I tend to say yes to too much and then manage the overload rather than pushing back earlier. Also help me see when I'm shielding my team too much — sometimes they need to feel the pressure to understand the priority.

**Keeps me up at night:** The monolith migration stalling. If we lose Priya or if the remaining 40% takes 2x longer than planned, we're stuck maintaining two systems indefinitely. That's a death spiral for team morale and reliability.

## Phase 6: Workflow

**Typical week:** Monday is planning — check dashboards, review PRs, set priorities for the week. Tuesday-Thursday is meetings (1:1s, architecture reviews, cross-team syncs). Friday is focus time — I try to do deep work on architecture docs and roadmap planning.

**Tools:** Slack (primary), GitHub, Linear for project tracking, PagerDuty for incidents, Google Meet for video.

**Meetings:** 12-15 per week. Mix of recurring 1:1s (7), team standup (daily), architecture review (weekly), cross-team sync with Product (weekly), skip-level (monthly).

**Code repos:** All under `~/Projects/payflow/` — `api-gateway`, `payment-service`, `platform-infra`. Personal: `~/Projects/gometrics`.

**Vault name:** Engineering Notes
