var User = require('../models/user')
var Entry = require('../models/attendance')
var Auth = require('../models/authenticate')
var jwt = require('jwt-simple')
var config = require('../config/dbconfig')
const {spawn} = require('child_process');
const { json } = require('body-parser')

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

    authenticate: function(req,res){
        Auth.findOne({
            email: req.body.email
        }, function(err,auth){
            if(err) throw err
            if(!auth){
                res.status(403).send({success: false, msg: 'Authentication Failed, auth Not Found.'})
            }
            else{
                auth.comparePassword(req.body.password, function(err, isMatch){
                    if(isMatch && !err){
                        var token = jwt.encode(auth,config.secret)
                        res.json({success: true, token: token})
                    }
                    else{
                        return res.status(403).send({
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
                                    res.json({success:true, msg: 'Entry added successfully.'});
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

    addUser: async function(req,res) {
        {
            if((!req.body._id) || (!req.body.name) || (!req.body.embedding)){
            res.json({success: false, msg: 'Enter all fields.'})
            }
            else{
                var newUser = User({
                    name: req.body.name,
                    _id: req.body._id,
                    embedding: req.body.embedding,
                });
                await newUser.save(function(err,newUser){
                    if(err){
                        res.json({success: false, msg: err})
                    }
                    else{
                        res.json({success: true, msg: 'Successfully added.'})
                    }
                })
            }
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

    checkFace: (req,res) => {
        try{
            var val = '';
            const childPython = spawn('python', ['./ml/face_recognition.py', req.query.path]);
            childPython.stdout.on('data', (data) => {
                val=data;
                console.log(`User = ${data}`);
            });

            childPython.stderr.on('data', (data) => {
                res.json({success: false, msg: data}); 
                console.log(`stderr: ${data}`);
            });

            childPython.on('close', (code) => {
                reg = val.toString();
                res.json({success: true, msg: reg.replace(/(\r\n|\n|\r)/gm, "")});
                console.log(`Child process exited with code ${code}`);
            });
        }
        catch(err){
            return json({success: false, msg: err});
        }
    }
}

module.exports = functions