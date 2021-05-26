const express = require('express')
const morgan = require('morgan')
const cors = require('cors')
const connectDB = require('./config/db.js')
const passport = require('passport')
const routes = require('./routes/index.js')

connectDB()

const app = express()

if(process.env.NODE_ENV === 'development'){
    app.use(morgan('dev'))
}

app.use(cors())
app.use(express.urlencoded({extended: true}))
app.use(express.json())
app.use(routes)
app.use(passport.initialize())
require('./config/passport')(passport)

const PORT = process.env.PORT || 3000

console.log(`Server running in ${process.env.NODE_ENV} mode on port ${PORT}`)
app.listen(PORT) 