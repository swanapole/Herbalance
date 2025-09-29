import express from 'express'
import dotenv from 'dotenv'
import helmet from 'helmet'
import cors from 'cors'
import rateLimit from 'express-rate-limit'
import pino from 'pino'

import { router as usersRouter } from './routes/users.js'
import { router as assessmentsRouter } from './routes/assessments.js'
import { router as alertsRouter } from './routes/alerts.js'
import { router as resourcesRouter } from './routes/resources.js'

dotenv.config()

const app = express()
const logger = pino({ level: process.env.NODE_ENV === 'production' ? 'info' : 'debug' })

// Security headers
app.use(helmet())

// CORS
const allowedOrigins = (process.env.ALLOWED_ORIGINS || '').split(',').filter(Boolean)
app.use(cors({
  origin: function (origin, callback) {
    if (!origin) return callback(null, true)
    if (allowedOrigins.length === 0 || allowedOrigins.includes(origin)) {
      return callback(null, true)
    }
    return callback(new Error('Not allowed by CORS'))
  },
  credentials: true
}))

// Body parsing
app.use(express.json({ limit: '1mb' }))

// Rate limit
const limiter = rateLimit({ windowMs: 60 * 1000, max: 120 })
app.use(limiter)

// Healthcheck
app.get('/health', (req, res) => {
  res.json({ status: 'ok', time: new Date().toISOString() })
})

// API routes
app.use('/api/users', usersRouter)
app.use('/api/assessments', assessmentsRouter)
app.use('/api/alerts', alertsRouter)
app.use('/api/resources', resourcesRouter)

// 404 handler
app.use((req, res) => {
  res.status(404).json({ error: 'Not Found' })
})

// Error handler
// eslint-disable-next-line no-unused-vars
app.use((err, req, res, next) => {
  logger.error(err)
  res.status(500).json({ error: 'Internal Server Error' })
})

const port = process.env.PORT || 4000
app.listen(port, () => {
  logger.info(`Server running on http://localhost:${port}`)
})
