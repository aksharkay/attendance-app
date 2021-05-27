var mongoose = require('mongoose')
var Schema = mongoose.Schema;

const userSchema = new Schema({
    _id: {
        type: String,
        required: true
    },
    name: {
        type: String,
        required: true
    },
    embedding: {
        type: Array,
        required: true
    }
});

module.exports = mongoose.model('Users',userSchema) 