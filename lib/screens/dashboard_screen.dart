import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import '../providers/entries.dart';
import '../widgets/app_drawer.dart';
import './scanner_screen.dart';
import './all_users_screen.dart';

class DashboardScreen extends StatefulWidget {
  static const routeName = '/dashboard-screen';

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  DateTime _dateTime = DateTime.now();
  String _storedImagePath;

  @override
  void initState() {
    super.initState();
  }

  Future<void> takePicture() async {
    final picker = ImagePicker();
    final imageFile = await picker.getImage(
      source: ImageSource.camera,
      maxWidth: 600,
    );

    setState(() {
      _storedImagePath = imageFile.path;
    });
    Navigator.of(context)
        .pushNamed(ScannerScreen.routeName, arguments: _storedImagePath);
  }

  Future<void> selectDate() async {
    return await showDatePicker(
        context: context,
        initialDate: _dateTime == null ? DateTime.now() : _dateTime,
        firstDate: DateTime(2020),
        lastDate: DateTime.now(),
        builder: (context, child) {
          return Theme(
            data: ThemeData.light().copyWith(
                colorScheme: ColorScheme.light().copyWith(
              primary: Theme.of(context).primaryColor,
            )),
            child: child,
          );
        }).then((date) async {
      setState(() {
        if (date != null) _dateTime = date;
      });
    });
  }

  Future<List> _getAttList(BuildContext context) async {
    return await Provider.of<Entries>(context, listen: false)
        .getAttList(DateFormat('dd-MM-yyyy').format(_dateTime).toString());
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      appBar: AppBar(
        title: Text(
          'Dashboard',
          style: TextStyle(fontSize: 25),
        ),
        actions: [
          IconButton(icon: Icon(Icons.search), onPressed: () {}),
          IconButton(
              icon: Icon(Icons.calendar_today),
              onPressed: () {
                selectDate();
              }),
        ],
        elevation: 0,
      ),
      drawer: Drawer(
        child: AppDrawer(),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          SizedBox(height: deviceSize.height * 0.05),
          Expanded(
            child: Container(
              height: deviceSize.height * 0.84,
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: Column(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      selectDate();
                    },
                    child: Text(
                      DateFormat('dd-MM-yyyy').format(_dateTime).toString(),
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.black,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      primary: Theme.of(context).accentColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                    ),
                  ),
                  Expanded(
                    child: FutureBuilder(
                      future: _getAttList(context),
                      builder: (ctx, snapshot) {
                        switch (snapshot.connectionState) {
                          case ConnectionState.done:
                            return !snapshot.hasData
                                ? _buildNoEntries()
                                : RefreshIndicator(
                                    onRefresh: () => _getAttList(context),
                                    child: Consumer<Entries>(
                                      builder: (context, entries, child) {
                                        return entries.list.length == 0
                                            ? _buildNoEntries()
                                            : _buildListView(entries);
                                      },
                                    ),
                                  );
                          default:
                            return Center(
                              child: LinearProgressIndicator(),
                            );
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: SpeedDial(
        backgroundColor: Theme.of(context).accentColor,
        icon: Icons.add,
        children: [
          SpeedDialChild(
            child: Icon(
              Icons.add,
              color: Colors.white,
            ),
            backgroundColor: Theme.of(context).primaryColor,
            labelWidget: Text(
              'Manual',
              style: TextStyle(color: Colors.white),
            ),
            onTap: () {
              Navigator.of(context).pushNamed(AllUsersScreen.routeName);
            },
          ),
          SpeedDialChild(
            child: Icon(
              Icons.add_a_photo,
              color: Colors.white,
            ),
            backgroundColor: Theme.of(context).primaryColor,
            labelWidget: Text(
              'Photo',
              style: TextStyle(color: Colors.white),
            ),
            onTap: takePicture,
          ),
        ],
      ),
    );
  }

  Widget _buildListView(Entries entries) {
    return ListView.builder(
      itemCount: entries.list.length,
      itemBuilder: (ctx, i) {
        return Card(
          child: ListTile(
            tileColor: Colors.white,
            title: Text(
              entries.list[i].name,
              style: TextStyle(fontSize: 20),
            ),
            subtitle: Text(
              entries.list[i].id,
              style: TextStyle(fontSize: 15),
            ),
            trailing: Text(
              entries.list[i].time,
              style: TextStyle(fontSize: 20, color: Colors.green),
            ),
          ),
          elevation: 5,
        );
      },
    );
  }

  Widget _buildNoEntries() {
    return Center(
      child: Text(
        'There were no entries on this date.',
        style: TextStyle(fontSize: 18),
      ),
    );
  }
}
