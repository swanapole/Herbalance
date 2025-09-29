import express from 'express'
import { z } from 'zod'
import { query } from '../db.js'

export const router = express.Router()

const assessmentSchema = z.object({
  userId: z.string().uuid(),
  type: z.enum(['breast_cancer_risk', 'cervical_cancer_risk', 'osteoporosis_risk', 'mental_health_stress']),
  answers: z.record(z.any()),
  riskScore: z.number().min(0).max(1).optional(),
  explanation: z.string().optional()
})

router.post('/', async (req, res, next) => {
  try {
    const data = assessmentSchema.parse(req.body)
    // riskScore could be provided by on-device model on client; if not, set null for now
    const result = await query(
      `insert into assessments (user_id, type, answers, risk_score, explanation)
       values ($1, $2, $3, $4, $5)
       returning id, user_id, type, answers, risk_score, explanation, created_at`,
      [data.userId, data.type, data.answers, data.riskScore ?? null, data.explanation ?? null]
    )
    res.status(201).json(result.rows[0])
  } catch (err) {
    next(err)
  }
})

router.get('/user/:userId', async (req, res, next) => {
  try {
    const r = await query('select id, user_id, type, answers, risk_score, explanation, created_at from assessments where user_id = $1 order by created_at desc', [req.params.userId])
    res.json(r.rows)
  } catch (err) {
    next(err)
  }
})
