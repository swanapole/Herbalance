# Women's Preventive Backend (Node.js + Postgres)

MVP backend for preventive health + mental health (Kenya). Uses Express, Postgres, and Zod for validation.

## Quick Start

1) Create a Postgres database (local or cloud) and apply schema:

```sql
-- connect to your DB then run
\i sql/schema.sql
```

2) Copy env and set values:

```bash
cp .env.example .env
```

3) Install and run:

```bash
npm install
npm run dev
```

Server: http://localhost:4000

- Healthcheck: `GET /health`
- Users: `POST /api/users`, `GET /api/users/:id`
- Assessments: `POST /api/assessments`, `GET /api/assessments/user/:userId`
- Alerts: `POST /api/alerts`, `GET /api/alerts/user/:userId`

## Notes
- Region default: `KE`. Language default: `en`.
- Consents are stored in `users.consents` JSONB. Always request explicit consent for sensitive data.
- Client (Flutter) should perform on-device ML inference and send `riskScore` (0..1) and `explanation` when available.
- To add AI cloud inference later, create a new route like `POST /api/inference` and ensure no PHI is sent; use pseudonymized IDs.
