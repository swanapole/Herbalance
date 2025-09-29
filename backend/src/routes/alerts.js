import express from 'express'
import { z } from 'zod'
import { query } from '../db.js'

export const router = express.Router()

const createAlertSchema = z.object({
  userId: z.string().uuid(),
  type: z.enum(['screening', 'vaccination', 'checkin', 'followup']),
  scheduleAt: z.string().datetime()
})

router.post('/', async (req, res, next) => {
  try {
    const data = createAlertSchema.parse(req.body)
    const r = await query(
      `insert into alerts (user_id, type, schedule_at)
       values ($1, $2, $3)
       returning id, user_id, type, schedule_at, delivered_at, created_at`,
      [data.userId, data.type, data.scheduleAt]
    )
    res.status(201).json(r.rows[0])
  } catch (err) {
    next(err)
  }
})

router.get('/user/:userId', async (req, res, next) => {
  try {
    const r = await query('select id, user_id, type, schedule_at, delivered_at, created_at from alerts where user_id = $1 order by schedule_at desc', [req.params.userId])
    res.json(r.rows)
  } catch (err) {
    next(err)
  }
})
