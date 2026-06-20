import 'package:dio/dio.dart';

class Apicontroller {
  Future<List<dynamic>> getdatas() async {
    final response = await Dio().get('https://ghibliapi.vercel.app/films');
    return response.data;
  }
}