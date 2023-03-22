import 'dart:convert'; //dart:convertを使用
import 'package:http/http.dart'; //package:http/http.dartを使用

//郵便番号を入力すると緯度経度を取得できるAPIをたたくクラス
class ZipCode{
  //asyncで非同期仕様としている
  static Future<Object> searchAddressFromZipCode(String zipCode) async{
    //たたくAPIのURLを定義
    String url = 'https://zipcloud.ibsnet.co.jp/api/search?zipcode=$zipCode';
    try{
      //APIをたたく部分(成功した場合)
      var result = await get(Uri.parse(url));
      Map<String, dynamic> data = jsonDecode(result.body);
      Map<String, String> response = {};
      //messageがnullではない場合
      if(data['message'] != null) {
        response['message'] = '郵便番号の桁数が不正です。';
      //messageがnullの場合
      } else {
        //resultsがnullの場合
        if(data['results'] == null){
          response['message'] = '正しい郵便番号を入力してください。';
        //resultsがnullではない場合
        } else {
          response['address'] = data['results'][0]['address2'];
        }
      }
      //message、resultsがnullであるか否かに関わらずresponseを返す
      return response;
    //エラーの場合、「Failed to get data」を返す
    } catch(e) {
      print(e);
      throw Exception('Failed to get data');
    }
  }
}