const dotenv = require("dotenv")
dotenv.config()

module.exports = {
    secret: 'yoursecret',
    database: `mongodb+srv://akshar:akshar2103@cluster0.tcm3i.mongodb.net/faces?retryWrites=true&w=majority`,
}
