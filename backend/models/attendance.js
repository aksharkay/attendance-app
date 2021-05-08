var mongoose = require('mongoose')
var Schema = mongoose.Schema;
ObjectId = Schema.ObjectId;

const entrySchema = Schema( 
    {
        userId:
        {
            type: String,
            required: true,
        },
        userName:
        {
            type: String,
            required:true,
        }
    },
    {
        timestamps: true,
    },
)

const attSchema = new Schema({
    date: String,
    entries: [entrySchema]
});

module.exports = mongoose.model('Attendance',attSchema) 