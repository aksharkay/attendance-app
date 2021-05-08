const express = require('express')
const actions = require('../methods/actions')
const router = express.Router()

router.post('/addnewauth',actions.addNewAuth)
router.post('/authenticate', actions.authenticate)
router.get('/getinfo',actions.getInfo)
router.post('/addenry', actions.addEntry)
router.post('/adduser', actions.addUser)
router.get('/attlist',actions.getAttList)
router.get('/allusers',actions.getAllUsers)
router.get('/photoentry',actions.checkFace)

module.exports = router