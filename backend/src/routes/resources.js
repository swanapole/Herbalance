import express from 'express'
import fs from 'fs'
import path from 'path'
import { fileURLToPath } from 'url'

export const router = express.Router()

const __filename = fileURLToPath(import.meta.url)
const __dirname = path.dirname(__filename)
const dataPath = path.resolve(__dirname, '../../assets/resources_ke.json')

router.get('/', async (req, res, next) => {
  try {
    const raw = await fs.promises.readFile(dataPath, 'utf-8')
    const json = JSON.parse(raw)
    res.json(json)
  } catch (err) {
    next(err)
  }
})
