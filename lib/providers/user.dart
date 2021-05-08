import 'package:flutter/foundation.dart';

class User {
  final String id;
  final String name;
  final List embedding;

  User({
    @required this.id,
    @required this.name,
    this.embedding,
  });
}
