import 'dart:convert'; //dart:convertを使用
import 'package:http/http.dart'; //package:http/http.dartを使用
import 'package:tenki_app/zip_code.dart'; //zip_code.dartをimport

//天気関係の情報をまとめているクラス
class Weather {
  //変数の定義(Null Safety対応で?を付けている)
  int? temp; //気温
  int? tempMax; //最高気温
  int? tempMin; //最低気温
  String? description; //天気状態
  double? lon; //経度
  double? lat; //緯度
  String? icon; //天気情報のアイコン画像
  DateTime? time; //日時
  int? rainyPercent; //降水確率

  Weather({
    this.temp, this.tempMax, this.tempMin,
    this.description, this.lon, this.lat,
    this.icon, this.time, this.rainyPercent
  });

  //APIの類似部分を変数でまとめている
  static String publicParameter = '&lang=ja&appid=354200d3dc058d823ca2075ebbe67aba&units=metric';

  //緯度経度を入力すると天気などを取得できるAPIをたたく部分【current】
  //asyncで非同期仕様としている
  static Future<Weather> getCurrentWeather(String zipCode) async{
    String _zipCode;
    //ハイフンが含まれているかチェック
    if(zipCode.contains(('-'))) {
      _zipCode = zipCode;
    //含まれていなかった場合、自動でハイフンを付けるようにする
    } else {
      _zipCode = zipCode.substring(0, 3) + '-' + zipCode.substring(3);
    }
    //たたくAPIのURLを定義
    String url = 'https://api.openweathermap.org/data/2.5/weather?zip=$_zipCode,JP$publicParameter';
    try {
      //APIをたたく部分(成功した場合)
      var result = await get(Uri.parse(url));
      Map<String, dynamic> data = jsonDecode(result.body);
      Weather currentWeather = Weather(
        description: data['weather'][0]['description'],
        temp: data['main']['temp'].toInt(),
        tempMax: data['main']['temp_max'].toInt(),
        tempMin: data['main']['temp_min'].toInt(),
        lon: data['coord']['lon'],
        lat: data['coord']['lat'],
      );
      return currentWeather; //成功した場合「currentWeather」を返す
    //エラーの場合、「Failed to get data」を返す
    } catch(e) {
      print(e);
      throw Exception('Failed to get data');
    }
  }

  //緯度経度を入力すると天気などを取得できるAPIをたたく部分【hourly、daily】
  //asyncで非同期仕様としている
  static Future<Map<String, List<Weather>>> getForecast({required double lat, required double lon}) async {
    Map<String, List<Weather>> response = {};
    //たたくAPIのURLを定義
    String url = 'https://api.openweathermap.org/data/3.0/onecall?lat=$lat&lon=$lon&exclude=minutely$publicParameter';
    try {
      //APIをたたく部分(成功した場合)
      var result = await get(Uri.parse(url));
      Map<String, dynamic> data = jsonDecode(result.body);
      List<dynamic> hourlyWeatherData = data['hourly'];
      List<dynamic> dailyWeatherData = data['daily'];
      List<Weather> hourlyWeather = hourlyWeatherData.map((weather) {
        return Weather(
          time: DateTime.fromMicrosecondsSinceEpoch(weather['dt'] * 1000000),
          temp: weather['temp'].toInt(),
          icon: weather['weather'][0]['icon'],
        );
      }).toList();
      List<Weather> dailyWeather = dailyWeatherData.map((weather) {
        return Weather(
          time: DateTime.fromMicrosecondsSinceEpoch(weather['dt'] * 1000000),
          icon: weather['weather'][0]['icon'],
          tempMax: weather['temp']['max'].toInt(),
          tempMin: weather['temp']['min'].toInt(),
          rainyPercent: weather.containsKey('rain') ? weather['rain'].toInt() : 0,
        );
      }).toList();
      response['hourly'] = hourlyWeather;
      response['daily']  = dailyWeather;
      return response; //responseを返す
    //エラーの場合、「Failed to get data」を返す
    } catch(e) {
      print(e);
      throw Exception('Failed to get data');
    }
  }
}