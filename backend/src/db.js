import dotenv from 'dotenv'
import pkg from 'pg'
const { Pool } = pkg

dotenv.config()

let connectionString = process.env.DATABASE_URL

const pool = new Pool(connectionString ? { connectionString, ssl: false } : {
  host: process.env.PGHOST || 'localhost',
  port: Number(process.env.PGPORT || 5432),
  database: process.env.PGDATABASE || 'womens_preventive',
  user: process.env.PGUSER || 'postgres',
  password: process.env.PGPASSWORD || 'postgres'
})

export async function query (text, params) {
  const start = Date.now()
  const res = await pool.query(text, params)
  const duration = Date.now() - start
  if (process.env.NODE_ENV !== 'production') {
    console.debug('executed query', { text, duration, rows: res.rowCount })
  }
  return res
}

export async function getClient () {
  return await pool.connect()
}
