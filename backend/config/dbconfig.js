const dotenv = require("dotenv")
dotenv.config()

module.exports = {
    secret: 'yoursecret',
<<<<<<< HEAD
    database: `mongodb+srv://akshar:akshar2103@cluster0.tcm3i.mongodb.net/faces?retryWrites=true&w=majority`,
}
=======
database: `mongodb+srv://${DB_USERNAME}:${DB_PASSWORD}@cluster0.tcm3i.mongodb.net/${DB}?retryWrites=true&w=majority`,
}
>>>>>>> 045c0b77cf70054851c6150539fc182e1defd599
