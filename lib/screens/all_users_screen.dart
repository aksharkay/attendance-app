import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/entries.dart';

class AllUsersScreen extends StatefulWidget {
  static const routeName = 'all-users-screen';
  @override
  _AllUsersScreenState createState() => _AllUsersScreenState();
}

class _AllUsersScreenState extends State<AllUsersScreen> {
  Future<List> _getAllUsers(BuildContext context) async {
    return Provider.of<Entries>(context).getAllUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).cardColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: Text(
          'All Users',
          style: TextStyle(
            fontSize: Theme.of(context).textTheme.headline1.fontSize,
          ),
        ),
      ),
      body: Column(
        children: [
          // Text('Double Tap On User To Mark As Present'),
          Expanded(
            child: FutureBuilder(
              future: _getAllUsers(context),
              builder: (ctx, snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.done:
                    return Consumer<Entries>(
                      builder: (context, users, child) {
                        // print(users.allUsers);
                        return users.allUsers.length == 0
                            ? _buildNoUsers()
                            : _buildListView(users);
                      },
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
    );
  }

  Widget _buildNoUsers() {
    return Center(
      child: Text(
        'No users registered.',
        style: TextStyle(fontSize: 18),
      ),
    );
  }

  Widget _buildListView(Entries users) {
    return ListView.builder(
      itemCount: users.allUsers.length,
      itemBuilder: (ctx, i) {
        return Card(
          child: InkWell(
            onDoubleTap: () {
              Provider.of<Entries>(context, listen: false)
                  .addEntry(users.allUsers[i]);
            },
            child: ListTile(
              tileColor: Colors.white,
              title: Text(
                users.allUsers[i].name,
                style: TextStyle(fontSize: 20),
              ),
              subtitle: Text(
                users.allUsers[i].id,
                style: TextStyle(fontSize: 15),
              ),
            ),
          ),
          elevation: 5,
        );
      },
    );
  }
}
