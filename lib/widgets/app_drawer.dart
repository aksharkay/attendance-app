import 'package:flutter/material.dart';

class AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          AppBar(
            backgroundColor: Theme.of(context).primaryColor,
            title: Text(
              'Hey Admin!',
              style: TextStyle(
                fontSize: Theme.of(context).textTheme.headline1.fontSize,
              ),
            ),
            automaticallyImplyLeading: false,
            actions: [
              // IconButton(
              //   icon: Icon(Icons.arrow_back_rounded),
              //   onPressed: () {
              //     Navigator.of(context).pushReplacementNamed('/');
              //   },
              // ),
            ],
            elevation: 10,
          ),
          //Divider(),
          ListTile(
            leading: Icon(
              Icons.logout,
              size: 20,
            ),
            title: Text(
              'Logout',
              style: TextStyle(fontSize: 20),
            ),
            onTap: () {
              Navigator.of(context).pushReplacementNamed('/');
            },
          ),
          Divider(),
        ],
      ),
    );
  }
}
