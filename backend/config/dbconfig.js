const dotenv = require("dotenv")
dotenv.config()

module.exports = {
    secret: 'yoursecret',
    database: `mongodb+srv://${process.env.DB_USERNAME}:${process.env.DB_PASSWORD}@cluster0.tcm3i.mongodb.net/faces?retryWrites=true&w=majority`,
}