# Data pack: what changed in software hiring, June 2024 to November 2026

Source: `web/data/data-20261101.js` (186 monthly "Ask HN: Who is Hiring?" threads, April 2011 to November 2026, about 95,000 postings).
Percentages are the share of top-level postings that mention a term. Unless noted, comparisons use 3-month averages
(September to November of each year) to smooth out single-month noise.

## Headline numbers

| Measure | Sep–Nov 2024 | Sep–Nov 2025 | Sep–Nov 2026 |
|---|---|---|---|
| Postings per thread | 316 | 343 | 248 |
| AI | 27.4% | 45.8% | 50.4% |
| AI Agents | 1.5% | 10.6% | 16.1% |
| LLM | 8.3% | 11.3% | 11.0% |
| MCP | 0.0% | 0.3% | 3.9% |
| Machine Learning | 14.8% | 15.1% | 13.0% |
| Front End | 19.1% | 15.6% | 6.6% |
| Full Stack | 26.6% | 26.2% | 20.1% |
| Back End | 24.2% | 23.6% | 18.8% |
| Senior | 30.4% | 31.6% | 30.7% |
| Staff | 9.1% | 13.2% | 11.8% |
| Junior | 2.3% | 2.1% | 3.1% |
| Python | 20.9% | 22.2% | 22.7% |
| TypeScript | 20.0% | 22.5% | 17.7% |
| Rust | 6.6% | 5.9% | 8.1% |
| Go | 8.5% | 7.3% | 6.7% |
| Remote | 52.7% | 52.6% | 54.6% |
| Onsite | 25.1% | 28.1% | 28.5% |
| Hybrid | 16.0% | 16.5% | 18.1% |

Other facts:

- Posting volume: yearly averages were 326 (2024), 336 (2025) and 287 (2026 so far), the lowest since 2013 (286).
  Every thread since July 2026 has had 224 to 255 postings. August 2026 (224) was the fewest since January 2014 (222).
  The all-time peak was 971 in May 2018.
- AI crossed 50% of postings in a single month for the first time in June 2026. It was about 7.6% in early 2021.
- Front End was about 27% as recently as early 2022 (3-month average; it ran 25–28% from 2019 to 2021) and is now 6.6%: from about 1 in 4 postings to 1 in 15.
- Staff has roughly quadrupled since 2019 (about 3% to 12%). Senior has stayed near 30%. Junior has stayed at 2–3%.
- Rust has been mentioned more often than Go in six months, all since October 2025, including four of the last five.

## Charts (in `web/images/`)

Each has an SVG and a 1200×630 PNG, in the same style as the home page image.

- `202611-ask-hn-who-is-hiring-tot` – postings per month, 2011–2026
- `202611-ai-agents-llm` – "Half of all job postings now mention AI" (AI, AI Agents, LLMs, 2021–2026)
- `202611-generalist-roles` – "Front-end roles fell from 1 in 4 postings to 1 in 15" (Full Stack, Back End, Front End, 2019–2026)
- `202611-seniority` – "Staff titles quadrupled; junior roles stayed rare" (Senior, Staff, Junior, 2019–2026)

## Interactive comparison links

- AI terms: https://www.hntrends.com/2026/november.html?compare=AI&compare=AI+Agents&compare=LLM&compare=Machine+Learning&compare=MCP
- Roles: https://www.hntrends.com/2026/november.html?compare=Full+Stack&compare=Back+End&compare=Front+End
- Seniority: https://www.hntrends.com/2026/november.html?compare=Senior&compare=Staff&compare=Junior
- Languages: https://www.hntrends.com/2026/november.html?compare=Python&compare=TypeScript&compare=Rust&compare=golang
- Work arrangement: https://www.hntrends.com/2026/november.html?compare=Remote&compare=Onsite&compare=Hybrid

## Possible outline

1. The break, and why you came back to it
2. Fewer postings: back to 2013 levels
3. AI moved from a skill to the job (AI, agents, MCP)
4. Front end is disappearing as a separate role
5. What didn't change: remote share, seniority mix, Python
6. Notes on the data

## Caveats to state

- HN "Who is Hiring?" leans toward startups and small companies. It's one slice of the market.
- The data shows AI terms rising while postings fell. It does not show that one caused the other.
- Counts include some candidate résumés posted in the hiring thread by mistake.
- New terms (AI Agents, LLM, MCP and others) were applied to every month back to 2011.
  An alias fix raised Front End, Back End, Next.js, NestJS and WebAssembly in all months compared with earlier posts.
- November 2026 was captured on November 14; its final posting count may be slightly higher.
