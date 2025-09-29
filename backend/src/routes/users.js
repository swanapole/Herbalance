import express from 'express'
import { z } from 'zod'
import { query } from '../db.js'

export const router = express.Router()

const userSchema = z.object({
  email: z.string().email(),
  region: z.string().default('KE'),
  language: z.string().default('en'),
  consents: z.object({
    sensitiveData: z.boolean().default(false),
    analytics: z.boolean().default(false)
  }).partial().default({})
})

router.post('/', async (req, res, next) => {
  try {
    const data = userSchema.parse(req.body)
    const { email, region, language, consents } = data
    const result = await query(
      `insert into users (email, region, language, consents)
       values ($1, $2, $3, $4)
       on conflict (email) do update set region = excluded.region, language = excluded.language, consents = excluded.consents
       returning id, email, region, language, consents, created_at`,
      [email, region, language, consents]
    )
    res.status(201).json(result.rows[0])
  } catch (err) {
    next(err)
  }
})

router.get('/:id', async (req, res, next) => {
  try {
    const r = await query('select id, email, region, language, consents, created_at from users where id = $1', [req.params.id])
    if (r.rowCount === 0) return res.status(404).json({ error: 'User not found' })
    res.json(r.rows[0])
  } catch (err) {
    next(err)
  }
})

// Delete user (cascades to assessments and alerts)
router.delete('/:id', async (req, res, next) => {
  try {
    const r = await query('delete from users where id = $1 returning id', [req.params.id])
    if (r.rowCount === 0) return res.status(404).json({ error: 'User not found' })
    res.status(204).send()
  } catch (err) {
    next(err)
  }
})

// Export user data (profile + assessments + alerts)
router.get('/:id/export', async (req, res, next) => {
  try {
    const userRes = await query('select id, email, region, language, consents, created_at from users where id = $1', [req.params.id])
    if (userRes.rowCount === 0) return res.status(404).json({ error: 'User not found' })
    const assessmentsRes = await query('select id, type, answers, risk_score, explanation, created_at from assessments where user_id = $1 order by created_at desc', [req.params.id])
    const alertsRes = await query('select id, type, schedule_at, delivered_at, created_at from alerts where user_id = $1 order by created_at desc', [req.params.id])
    const payload = {
      user: userRes.rows[0],
      assessments: assessmentsRes.rows,
      alerts: alertsRes.rows,
      exported_at: new Date().toISOString(),
      note: 'For privacy, share or store this export carefully.'
    }
    res.setHeader('Content-Disposition', `attachment; filename="user_${req.params.id}_export.json"`)
    res.json(payload)
  } catch (err) {
    next(err)
  }
})
