import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:open_file/open_file.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' as excel;
import '../services/facenet_service.dart';
import '../services/ml_vision_service.dart';
import '../db/database.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:camera/camera.dart';
import 'dart:async';
import 'dart:io';

import '../providers/entries.dart';
import '../widgets/app_drawer.dart';
import 'add_entry_screen.dart';
import './all_users_screen.dart';
import './add_user_screen.dart';

class DashboardScreen extends StatefulWidget {
  static const routeName = '/dashboard-screen';

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  DateTime _dateTime = DateTime.now();
  FaceNetService _faceNetService = FaceNetService();
  MLVisionService _mlVisionService = MLVisionService();
  DataBaseService _dataBaseService = DataBaseService();

  CameraDescription cameraDescription;
  bool loading = false;

  @override
  void initState() {
    super.initState();
    _startUp();
  }

  _startUp() async {
    _setLoading(true);

    List<CameraDescription> cameras = await availableCameras();

    /// takes the front camera
    cameraDescription = cameras.firstWhere(
      (CameraDescription camera) =>
          camera.lensDirection == CameraLensDirection.front,
    );

    // start the services
    await _faceNetService.loadModel();
    await _dataBaseService.loadDB();
    _mlVisionService.initialize();

    _setLoading(false);
  }

  _setLoading(bool value) {
    setState(() {
      loading = value;
    });
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

  Future<void> createExcel() async {
    final String date = DateFormat('dd-MM-yyyy').format(_dateTime).toString();
    final list =
        await Provider.of<Entries>(context, listen: false).getAttList(date);

    final excel.Workbook workbook = excel.Workbook();
    final excel.Worksheet sheet = workbook.worksheets[0];

    sheet.getRangeByName('A1').setText('UID');
    sheet.getRangeByName('B1').setText('Name');
    sheet.getRangeByName('C1').setText('Time');

    int i = 2, j = 2, k = 2;
    list.forEach((element) {
      // print(element.id);
      // print(element.name);
      // print(element.time);
      sheet.getRangeByName('A$i').setText(element.id);
      sheet.getRangeByName('B$j').setText(element.name);
      sheet.getRangeByName('C$k').setText(element.time);
      i++;
      j++;
      k++;
    });

    final List<int> bytes = workbook.saveAsStream();
    workbook.dispose();

    final String path = (await getApplicationSupportDirectory()).path;
    final String fileName = '$path/attendance_$date.xlsx';
    final File file = File(fileName);
    await file.writeAsBytes(bytes, flush: true);
    OpenFile.open(fileName);
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: Text(
          'Dashboard',
          style: TextStyle(fontSize: 25),
        ),
        actions: [
          // IconButton(icon: Icon(Icons.search), onPressed: () {}),
          IconButton(
            icon: Icon(Icons.file_download_outlined),
            onPressed: createExcel,
          ),
          PopupMenuButton<String>(
            child: Icon(
              Icons.more_vert,
              color: Colors.white,
            ),
            onSelected: (value) {
              switch (value) {
                case 'Clear DB':
                  _dataBaseService.cleanDB();
                  break;
              }
            },
            itemBuilder: (BuildContext context) {
              return {'Clear DB'}.map((String choice) {
                return PopupMenuItem<String>(
                  value: choice,
                  child: Text(choice),
                );
              }).toList();
            },
          ),
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
              Icons.list_rounded,
              color: Colors.white,
            ),
            backgroundColor: Theme.of(context).primaryColor,
            labelWidget: Text(
              'All Users',
              style: TextStyle(color: Colors.white),
            ),
            onTap: () =>
                Navigator.of(context).pushNamed(AllUsersScreen.routeName),
          ),
          SpeedDialChild(
            child: Icon(
              Icons.person_add,
              color: Colors.white,
            ),
            backgroundColor: Theme.of(context).primaryColor,
            labelWidget: Text(
              'New User',
              style: TextStyle(color: Colors.white),
            ),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (BuildContext context) => AddUserScreen(
                    cameraDescription: cameraDescription,
                    lensDirection: CameraLensDirection.front),
              ),
            ),
          ),
          SpeedDialChild(
            child: Icon(
              Icons.add_a_photo,
              color: Colors.white,
            ),
            backgroundColor: Theme.of(context).primaryColor,
            labelWidget: Text(
              'Attendance',
              style: TextStyle(color: Colors.white),
            ),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (BuildContext context) => AddEntryScreen(
                    cameraDescription: cameraDescription,
                    lensDirection: CameraLensDirection.front),
              ),
            ),
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
