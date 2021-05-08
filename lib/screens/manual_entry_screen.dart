import 'package:flutter/material.dart';

class ManualEntryScreen extends StatefulWidget {
  @override
  _ManualEntryScreenState createState() => _ManualEntryScreenState();
}

class _ManualEntryScreenState extends State<ManualEntryScreen> {
  String _name;
  String _regNo;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Manually'),
      ),
      backgroundColor: Theme.of(context).cardColor,
      body: Container(
        margin: EdgeInsets.all(24),
      ),
    );
  }
}
