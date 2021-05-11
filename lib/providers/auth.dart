import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class Auth with ChangeNotifier {
  Dio dio = new Dio();
  final String baseURL = 'facerecflutter.tech';

  Future<dynamic> login(email, password) async {
    try {
      return await dio.post(
        'https://$baseURL/authenticate',
        data: {
          'email': email,
          'password': password,
        },
        options: Options(contentType: Headers.formUrlEncodedContentType),
      );
    } on DioError catch (error) {
      return error;
    }
  }

  Future<dynamic> signUp(email, password) async {
    try {
      return await dio.post(
        'https://$baseURL/addnewauth',
        data: {
          'email': email,
          "password": password,
        },
        options: Options(contentType: Headers.formUrlEncodedContentType),
      );
    } on DioError catch (error) {
      return error;
    }
  }

  getInfo(token) async {
    dio.options.headers['Authorization'] = 'Bearer $token';
    return await dio.get(
      '$baseURL/getinfo',
    );
  }
}
