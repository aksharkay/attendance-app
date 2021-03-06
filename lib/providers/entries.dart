import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';

import './entry.dart';
import './user.dart';

class Entries extends ChangeNotifier {
  final String baseURL = 'facerecflutter.tech';
  List<Entry> _list = [];
  List<User> _allUsers = [];

  List<Entry> get list {
    return [..._list];
  }

  List<User> get allUsers {
    return [..._allUsers];
  }

  void toast(String msg) {
    Fluttertoast.showToast(
      msg: msg,
      toastLength: Toast.LENGTH_SHORT,
      // gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.green,
      textColor: Colors.white,
      fontSize: 16,
    );
  }

  Future<List> getAttList(String date) async {
    try {
      var params = {'date': date};
      print(date);
      String endPoint = '$baseURL';
      String api = '/attlist';
      var uri = Uri.https(endPoint, api, params);
      final headers = {HttpHeaders.contentTypeHeader: 'application/json'};
      var response = await http.get(uri, headers: headers);

      final jsonData = json.decode(response.body);
      final extractedData = jsonData['msg'] as dynamic;

      print(extractedData);

      _list = [];
      final List<Entry> loadedEntries = [];
      if (extractedData is List) {
        extractedData.forEach((entryData) {
          loadedEntries.add(
            Entry(
              id: entryData['userId'],
              name: entryData['userName'],
              time: DateFormat.jm()
                  .format(DateTime.parse(entryData['updatedAt']).toLocal()),
            ),
          );
        });

        _list = loadedEntries;
      }
    } catch (err) {
      throw err;
    }
    notifyListeners();
    return Future.value(_list);
  }

  Future<List> getAllUsers() async {
    try {
      String endPoint = '$baseURL';
      String api = '/allusers';
      var uri = Uri.https(endPoint, api);
      final headers = {HttpHeaders.contentTypeHeader: 'application/json'};
      var response = await http.get(uri, headers: headers);

      final jsonData = json.decode(response.body);
      final extractedData = jsonData['msg'] as dynamic;

      _allUsers = [];
      final List<User> loadedUsers = [];

      if (extractedData is List) {
        extractedData.forEach((userData) {
          loadedUsers.add(
            User(
              id: userData['_id'],
              name: userData['name'],
            ),
          );
        });

        _allUsers = loadedUsers;
      }
    } catch (err) {
      throw err;
    }

    return Future.value(_allUsers);
  }

  Future<void> addEntry(User user) async {
    try {
      final url = Uri.parse('https://$baseURL/addentry');
      final date = DateFormat('dd-MM-yyyy').format(DateTime.now()).toString();
      final response = await http.post(url, body: {
        'date': date,
        'userId': user.id,
        'userName': user.name,
      });

      final jsonResp = json.decode(response.body);
      print(jsonResp);

      return toast(jsonResp['msg']);
    } catch (err) {
      throw err;
    }
  }

  Future<void> addNewUser(User user) async {
    try {
      final url = Uri.parse('https://$baseURL/addnewuser');
      final response = await http.post(
        url,
        headers: {HttpHeaders.contentTypeHeader: 'application/json'},
        body: json.encode(
          {
            'id': user.id,
            'name': user.name,
            'embedding': user.embedding.toString(),
          },
        ),
      );

      final jsonResp = json.decode(response.body);
      print(jsonResp);

      return toast(jsonResp['msg']);
    } catch (err) {
      return toast('User Already Exists');
    }
  }
}
