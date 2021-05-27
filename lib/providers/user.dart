import 'package:flutter/foundation.dart';

class User {
  final String id;
  final String name;
  final String embedding;

  User({
    @required this.id,
    @required this.name,
    this.embedding,
  });

  static User fromDB(String dbuser) {
    return new User(name: dbuser.split(':')[0], id: dbuser.split(':')[1]);
  }
}
