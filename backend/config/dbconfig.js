const dotenv = require("dotenv")
dotenv.config()

module.exports = {
    secret: 'yoursecret',
database: `mongodb+srv://${DB_USERNAME}:${DB_PASSWORD}@cluster0.tcm3i.mongodb.net/${DB}?retryWrites=true&w=majority`,
}