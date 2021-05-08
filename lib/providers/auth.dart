import 'package:dio/dio.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/material.dart';

class Auth with ChangeNotifier {
  Dio dio = new Dio();
  final String baseURL = '192.168.0.112:3000';

  login(email, password) async {
    try {
      var log = await dio.post(
        '$baseURL/authenticate',
        data: {
          'email': email,
          'password': password,
        },
        options: Options(contentType: Headers.formUrlEncodedContentType),
      );
      print(log);
    } on DioError catch (error) {
      Fluttertoast.showToast(
        msg: error.response.data['msg'],
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16,
      );
    }
  }

  signUp(email, password) async {
    try {
      return await dio.post(
        '$baseURL/addnewauth',
        data: {
          'email': email,
          "password": password,
        },
        options: Options(contentType: Headers.formUrlEncodedContentType),
      );
    } on DioError catch (error) {
      Fluttertoast.showToast(
        msg: error.response.data['msg'],
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16,
      );
    }
  }

  getInfo(token) async {
    dio.options.headers['Authorization'] = 'Bearer $token';
    return await dio.get(
      '$baseURL/getinfo',
    );
  }
}
