import 'package:face_recognition_app/providers/entries.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:intl/intl.dart';

import './dashboard_screen.dart';

class ScannerScreen extends StatefulWidget {
  static const routeName = 'scanner-screen';

  @override
  _ScannerScreenState createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  @override
  Widget build(BuildContext context) {
    String imagePath = ModalRoute.of(context).settings.arguments;
    final deviceSize = MediaQuery.of(context).size;

    _showDialogBox(String name, String id) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text('Entry Added!'),
          content: Column(children: [
            Icon(
              Icons.check_circle_rounded,
              color: Theme.of(context).primaryColor,
            ),
            Text('Face Identified.'),
            Text(name),
            Text(id),
            Text(
              DateFormat.jm()
                  .format(DateTime.parse(DateTime.now().toString()).toLocal()),
            ),
          ]),
          backgroundColor: Theme.of(context).cardColor,
          actions: [
            ElevatedButton(
                style: ElevatedButton.styleFrom(
                    primary: Theme.of(context).primaryColor),
                child: Text('Next'),
                onPressed: () => Navigator.of(context)
                    .pushReplacementNamed(DashboardScreen.routeName))
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(children: [
        Center(
          child: Container(
            height: deviceSize.height * 0.75,
            width: deviceSize.width * 0.75,
            child: Image.file(File(imagePath)),
          ),
        ),
        SizedBox(
          width: deviceSize.width * 0.75,
          child: ElevatedButton(
            child: Text('Check In'),
            onPressed: () async {
              var val = await Provider.of<Entries>(context, listen: false)
                  .addPhotoEntry(imagePath);
              var name = val.substring(9);
              var id = val.substring(0, 9);
              print("Name: " + name + " ID: " + id);

              _showDialogBox(name, id);
            },
            style: ElevatedButton.styleFrom(
                primary: Theme.of(context).primaryColor),
          ),
        ),
        SizedBox(
          width: deviceSize.width * 0.75,
          child: ElevatedButton(
            child: Text('Cancel'),
            onPressed: () {
              Navigator.pop(context);
            },
            style:
                ElevatedButton.styleFrom(primary: Theme.of(context).errorColor),
          ),
        ),
      ]),
    );
  }
}
