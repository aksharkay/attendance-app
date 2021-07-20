import '../screens/dashboard_screen.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../providers/auth.dart';
import 'package:provider/provider.dart';

class AuthScreen extends StatelessWidget {
  toast(String msg, bool error) {
    Fluttertoast.showToast(
      msg: msg,
      toastLength: Toast.LENGTH_SHORT,
      timeInSecForIosWeb: 1,
      backgroundColor: error ? Colors.red : Colors.green,
      textColor: Colors.white,
      fontSize: 16,
    );
  }

  @override
  Widget build(BuildContext context) {
    var email, password, token;
    final deviceSize = MediaQuery.of(context).size;
    Image logo = Image.asset(
      'assets/images/logo.png',
      height: deviceSize.height * 0.1,
      width: deviceSize.width * 0.2,
    );

    return Scaffold(
      body: Stack(
        children: <Widget>[
          Container(
            color: Theme.of(context).primaryColor,
          ),
          SingleChildScrollView(
            child: Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(height: deviceSize.height * 0.15),
                      Container(
                        child: logo,
                      ),
                      SizedBox(height: deviceSize.height * 0.05),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Container(
                            child: Text(
                              'FaceRec!',
                              style: Theme.of(context).textTheme.headline6,
                            ),
                          ),
                          // Container(
                          //   child: Text(
                          //     'Making attendance systems more efficient!',
                          //     style: Theme.of(context).textTheme.headline1,
                          //   ),
                          // ),
                          SizedBox(
                            height: deviceSize.height * 0.15,
                          )
                        ],
                      ),
                      Card(
                        margin: EdgeInsets.all(0),
                        color: Theme.of(context).cardColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(30),
                            topRight: Radius.circular(30),
                          ),
                        ),
                        elevation: 8.0,
                        child: Container(
                          height: deviceSize.height * 0.50,
                          width: deviceSize.width,
                          padding: EdgeInsets.all(16.0),
                          child: Form(
                            child: SingleChildScrollView(
                              child: Column(
                                children: <Widget>[
                                  SizedBox(height: 20),
                                  TextFormField(
                                    decoration: InputDecoration(
                                      filled: true,
                                      fillColor: Colors.white,
                                      labelText: 'E-Mail',
                                      border: new OutlineInputBorder(
                                        borderRadius:
                                            new BorderRadius.circular(10),
                                      ),
                                      prefixIcon: Icon(
                                        Icons.email_outlined,
                                        color: Theme.of(context).buttonColor,
                                      ),
                                    ),
                                    keyboardType: TextInputType.emailAddress,
                                    onChanged: (val) {
                                      email = val;
                                    },
                                    // validator: (value) {
                                    //   if (value.isEmpty ||
                                    //       !value.contains('@')) {
                                    //     return 'Invalid email!';
                                    //   }
                                    //   return null;
                                    // },
                                  ),
                                  SizedBox(height: 10),
                                  TextFormField(
                                    decoration: InputDecoration(
                                      labelText: 'Password',
                                      filled: true,
                                      fillColor: Colors.white,
                                      border: new OutlineInputBorder(
                                        borderRadius:
                                            new BorderRadius.circular(10),
                                        borderSide: new BorderSide(),
                                      ),
                                      prefixIcon: Icon(
                                        Icons.lock_outline_rounded,
                                        color: Theme.of(context).buttonColor,
                                      ),
                                    ),
                                    obscureText: true,
                                    controller: TextEditingController(),
                                    // validator: (value) {
                                    //   if (value.isEmpty || value.length < 5) {
                                    //     return 'Password is too short!';
                                    //   }
                                    //   return null;
                                    // },
                                    onChanged: (val) {
                                      password = val;
                                    },
                                  ),
                                  SizedBox(height: 20),
                                  SizedBox(
                                    height: 50,
                                    width: deviceSize.width,
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        primary: Theme.of(context).accentColor,
                                        textStyle: TextStyle(
                                          color: Theme.of(context).buttonColor,
                                        ),
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 30.0, vertical: 8.0),
                                      ),
                                      child: Text(
                                        'Sign In',
                                        style: TextStyle(
                                            color:
                                                Theme.of(context).buttonColor),
                                      ),
                                      onPressed: () async {
                                        final val = await Provider.of<Auth>(
                                                context,
                                                listen: false)
                                            .login(email, password);

                                        if (val.data['success']) {
                                          token = val.data['token'];
                                          toast('Sign In Successful', false);
                                          Navigator.of(context)
                                              .pushReplacementNamed(
                                                  DashboardScreen.routeName);
                                        } else {
                                          toast(val.data['msg'], true);
                                        }
                                      },
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  SizedBox(
                                    height: 50,
                                    width: deviceSize.width,
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        primary: Theme.of(context).buttonColor,
                                        textStyle: TextStyle(
                                          color: Theme.of(context).accentColor,
                                        ),
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 30.0, vertical: 8.0),
                                      ),
                                      child: Text('Sign Up'),
                                      onPressed: () =>
                                          Auth().signUp(email, password).then(
                                        (val) {
                                          if (val.data['success']) {
                                            token = val.data['token'];
                                            toast('Sign Up Successful', false);
                                            Navigator.of(context)
                                                .pushReplacementNamed(
                                                    DashboardScreen.routeName);
                                          } else {
                                            toast(val.data['msg'], true);
                                          }
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
