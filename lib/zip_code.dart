import 'dart:convert';
import 'package:http/http.dart';

class ZipCode{
  static Future<Object> searchAddressFromZipCode(String zipCode) async{
    String url = 'https://zipcloud.ibsnet.co.jp/api/search?zipcode=$zipCode';
    try{
      var result = await get(Uri.parse(url));
      Map<String, dynamic> data = jsonDecode(result.body);
      Map<String, String> response = {};
      if(data['message'] != null) {
        response['message'] = '郵便番号の桁数が不正です。';
      } else {
        if(data['results'] == null){
          response['message'] = '正しい郵便番号を入力してください。';
        } else {
          response['address'] = data['results'][0]['address2'];
        }
      }
      return response;
    } catch(e) {
      print(e);
      throw Exception('Failed to get weather data');
    }
  }
}