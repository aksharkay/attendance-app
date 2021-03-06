import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:flutter_downloader/flutter_downloader.dart';

import './screens/auth_screen.dart';
import './providers/entries.dart';
import './providers/auth.dart';
import './screens/dashboard_screen.dart';
import './screens/all_users_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FlutterDownloader.initialize(
      debug: true // optional: set false to disable printing logs to console
      );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(
          value: Entries(),
        ),
        ChangeNotifierProvider.value(
          value: Auth(),
        ),
      ],
      child: MaterialApp(
        title: 'Attendance App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primaryColor: HexColor('#006B1B'),
          accentColor: HexColor('#FFD600'),
          buttonColor: HexColor('#000000'),
          cardColor: HexColor('#EEF9E9'),
          errorColor: Colors.red,
          fontFamily: 'Hind',
          textTheme: TextTheme(
            headline6: TextStyle(
              fontSize: 40,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
            headline1: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w300,
            ),
          ),
        ),
        home: AuthScreen(),
        routes: {
          DashboardScreen.routeName: (ctx) => DashboardScreen(),
          AllUsersScreen.routeName: (ctx) => AllUsersScreen(),
        },
      ),
    );
  }
}
