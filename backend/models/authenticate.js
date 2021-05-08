var mongoose = require('mongoose')
var Schema = mongoose.Schema;
var bcrypt = require('bcrypt')
var authSchema = new Schema({
    email: {
        type: String,
        required: true
    },
    password: {
        type: String,
        required: true
    }
})

authSchema.pre('save', function(next){
    var user = this;
    if(this.isModified('password')||(this.isNew)){
        bcrypt.genSalt(10,function(err,salt){
            if(err){
                return next(err)
            }
            bcrypt.hash(user.password,salt,function(err,hash){
                if(err){
                    return next(err)
                }
                user.password = hash;
                next()
            })
        })
    }
    else{
        return next()
    }
})

authSchema.methods.comparePassword = function(pass, cb){
    bcrypt.compare(pass,this.password,function(err,isMatch){
        if(err){
            return cb(err)
        }
        cb(null,isMatch)
    })
}

module.exports = mongoose.model('Auth',authSchema)
