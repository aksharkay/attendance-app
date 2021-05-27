import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import '../screens/dashboard_screen.dart';
import '../db/database.dart';
import '../providers/user.dart';
import '../widgets/app_button.dart';
import '../services/facenet_service.dart';
import '../providers/entries.dart';
import './app_text_field.dart';

class AuthActionButton extends StatefulWidget {
  AuthActionButton(this._initializeControllerFuture,
      {Key key, @required this.onPressed, @required this.isLogin, this.reload});
  final Future _initializeControllerFuture;
  final Function onPressed;
  final bool isLogin;
  final Function reload;
  @override
  _AuthActionButtonState createState() => _AuthActionButtonState();
}

class _AuthActionButtonState extends State<AuthActionButton> {
  /// service injection
  final FaceNetService _faceNetService = FaceNetService();
  final DataBaseService _dataBaseService = DataBaseService();

  final TextEditingController _nameTextEditingController =
      TextEditingController(text: '');
  final TextEditingController _regTextEditingController =
      TextEditingController(text: '');

  User predictedUser;

  Future _signUp(context) async {
    /// gets predicted data from facenet service (user face detected)
    List predictedData = _faceNetService.predictedData;
    String name = _nameTextEditingController.text;
    String id = _regTextEditingController.text;
    print("Predicted Emb: $predictedData");

    /// creates a new user in the 'database'
    await _dataBaseService.saveData(name, id, predictedData);
    await Provider.of<Entries>(context, listen: false).addNewUser(
      User(
        id: id,
        name: name,
        embedding: predictedData,
      ),
    );

    // print(name);
    // print(id);

    /// resets the face stored in the face net sevice
    this._faceNetService.setPredictedData(null);
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (BuildContext context) => DashboardScreen()));
  }

  Future _signIn(context) async {
    String id = _regTextEditingController.text;
    print(predictedUser);
    print("User: " + predictedUser.id + predictedUser.name);
    if (this.predictedUser.id == id) {
      await Provider.of<Entries>(context, listen: false).addEntry(
        User(
          id: predictedUser.id,
          name: predictedUser.name,
        ),
      );
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) => DashboardScreen(),
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: Text('Wrong reg. no!'),
          );
        },
      );
    }
  }

  String _predictUser() {
    String nameAndID = _faceNetService.predict();
    print('Predicted User: ');
    print(nameAndID);
    return nameAndID ?? null;
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        try {
          // Ensure that the camera is initialized.
          await widget._initializeControllerFuture;
          // onShot event (takes the image and predict output)
          bool faceDetected = await widget.onPressed();

          if (faceDetected) {
            if (widget.isLogin) {
              var nameAndID = _predictUser();
              print(nameAndID);
              if (nameAndID != null) {
                this.predictedUser = User.fromDB(nameAndID);
              }
            }
            PersistentBottomSheetController bottomSheetController =
                Scaffold.of(context)
                    .showBottomSheet((context) => signSheet(context));

            bottomSheetController.closed.whenComplete(() => widget.reload());
          }
        } catch (e) {
          // If an error occurs, log the error to the console.
          print(e);
        }
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Color(0xFF0F0BDB),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.blue.withOpacity(0.1),
              blurRadius: 1,
              offset: Offset(0, 2),
            ),
          ],
        ),
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        width: MediaQuery.of(context).size.width * 0.8,
        height: 60,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'ADD',
              style: TextStyle(color: Colors.white),
            ),
            SizedBox(
              width: 10,
            ),
            Icon(Icons.camera_alt, color: Colors.black)
          ],
        ),
      ),
    );
  }

  signSheet(context) {
    return Container(
      padding: EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          widget.isLogin && predictedUser != null
              ? Container(
                  child: Text(
                    'Welcome Back, ' + predictedUser.name + '.',
                    style: TextStyle(fontSize: 20),
                  ),
                )
              : widget.isLogin
                  ? Container(
                      child: Text(
                      'User Not Found! Please Sign Up First.',
                      style: TextStyle(fontSize: 20),
                    ))
                  : Container(),
          Container(
            child: Column(
              children: [
                !widget.isLogin
                    ? AppTextField(
                        controller: _nameTextEditingController,
                        labelText: "Name",
                      )
                    : Container(),
                SizedBox(height: 10),
                widget.isLogin && predictedUser == null
                    ? Container()
                    : AppTextField(
                        controller: _regTextEditingController,
                        labelText: "Registration Number",
                        isSignUp: true,
                      ),
                SizedBox(height: 10),
                Divider(),
                SizedBox(height: 10),
                widget.isLogin && predictedUser != null
                    ? AppButton(
                        text: 'DONE',
                        onPressed: () async {
                          _signIn(context);
                        },
                        icon: Icon(
                          Icons.login,
                          color: Colors.white,
                        ),
                      )
                    : !widget.isLogin
                        ? AppButton(
                            text: 'ADD',
                            onPressed: () => _signUp(context),
                            icon: Icon(
                              Icons.person_add,
                              color: Colors.white,
                            ),
                          )
                        : Container(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
