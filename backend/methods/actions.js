var User = require('../models/user')
var Entry = require('../models/attendance')
var Auth = require('../models/authenticate')
var jwt = require('jwt-simple')
var config = require('../config/dbconfig')

var functions = {
    addNewAuth: function(req,res){
        if((!req.body.email) || (!req.body.password)){
            res.json({success: false, msg: 'Enter all fields.'})
        }
        else{
            var newAuth = Auth({
                email: req.body.email,
                password: req.body.password
            });
            newAuth.save(function(err,newAuth){
                if(err){
                    res.json({success: false, msg: err})
                }
                else{
                    res.json({success: true, msg: 'Successfully saved.'})
                }
            })
        }
    },

    authenticate: async function(req,res) {
        await Auth.findOne({
            email: req.body.email
        }, async function(err,auth){
            if(err) throw err
            if(!auth){
                res.json({success: false, msg: 'Authentication Failed, E-mail Not Found.'})
            }
            else{
                await auth.comparePassword(req.body.password, function(err, isMatch){
                    if(isMatch && !err){
                        var token = jwt.encode(auth,config.secret)
                        res.json({success: true, token: token})
                    }
                    else{
                        return res.json({
                            success: false, msg: 'Authentication Failed, Wrong Password.'
                        })
                    }
                })
            }
        })
    },

    getInfo: function(req,res){
        if(req.headers.authorization && req.headers.authorization.split(' ')[0] === 'Bearer'){
            var token = req.headers.authorization.split(' ')[1]
            var decodedtoken = jwt.decode(token,config.secret)
            return res.json({success: true, msg: 'Hello '+decodedtoken.email})
        }
        else{
            return res.json({success: false, msg: 'No Headers'})
        }
    },

    addEntry: async function(req,res) {
        try{
            await Entry.find({'date': req.body.date,'entries.userId': req.body.userId}, (err, result) => {
                if (!result.length){
                        Entry.findOneAndUpdate({date: req.body.date},
                            {$push:{entries: {userId: req.body.userId, userName: req.body.userName},},},
                            {upsert: true},
                            (function(err,record){
                                if(err){
                                    res.json({success: false, msg: err});
                                }
                                else{
                                    res.json({success:true, msg: 'Entry added successfully'});
                                }
                        }));
                }
                else{
                    res.json({success:false, msg: 'Entry already exists.'});
                }
        });
            
            }
        catch(err){
            res.json({success: false, msg: err});
        }
    },

    addUser: function(req,res) {
        try{
            console.log(`Embedding from body: ${req.body.embedding}`);
            if((!req.body.id) || (!req.body.name) || (!req.body.embedding)){
            res.json({success: false, msg: 'Enter all fields.'})
            }
            else{
                var newUser = User({
                    name: req.body.name,
                    _id: req.body.id,
                    embedding: req.body.embedding,
                });
                newUser.save(function(err,newUser){
                    if(err){
                        res.json({success: false, msg: err})
                    }
                    else{
                        res.json({success: true, msg: 'Successfully added.'})
                    }
                })
            }
        }
        catch(err){
            res.json({success: false, msg: err})
        }
    },

    getAttList: async function(req,res) {
        try{
            console.log(req.params);
            var result = await Entry.findOne({date:req.query.date});
            if(req.query.date==null)
            {
                return res.json({success: false, msg: 'Enter a date.'});
            }
            
            else if(result == null)
            {
                return res.json({success: true, msg: 'No entries on this date.'});
            }
            else
            {
                return res.json({success:true, msg: result.entries});
            }
        }
        catch(err){
            return res.json({success: false, msg: err});
        }
    },

    getAllUsers: async function(req,res){
        try{
            var result = await User.find({}).select('name');

            if(result == null){
                return res.json({success: true, msg: 'No users registered.'});
            }
            else{
                return res.json({success:true, msg: result});
            }
        }
        catch(err){
            return res.json({success: false, msg: err});
        }
    },
}

module.exports = functions
