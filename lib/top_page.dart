import 'package:flutter/foundation.dart'; //foundation.dartを使用
import 'package:flutter/material.dart'; //material.dartを使用
import 'package:intl/intl.dart'; //intl.dartを使用
import 'package:tenki_app/weather.dart'; //weather.dartをimport
import 'package:tenki_app/zip_code.dart'; //zip_code.dartをimport

//TopPageの構成を記述するクラス
class TopPage extends StatefulWidget {
  const TopPage({Key? key}) : super(key: key);

  @override
  State<TopPage> createState() => _TopPageState();
}

//_TopPageStateの構成を記述するクラス
class _TopPageState extends State<TopPage> {

  //各変数を定義
  Weather currentWeather = Weather(description: '', temp: 0, tempMax: 0, tempMin: 0);
  String address = '―';
  String? errorMessage;
  List<Weather> hourlyWeather = [];
  List<Weather> dailyWeather = [];
  List<String> weekDay = ['月','火','水','木','金','土','日'];

  //UIを記載する箇所
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea( //SafeAreaは時刻などの表示部分に文字を表示しないようにする為使う
          child: Column(
            children: [
              Container(
                  width: 200,
                  child: TextField(
                    onSubmitted: (value) async{
                      Map<String, String> response = {};
                      response = await ZipCode.searchAddressFromZipCode(value) as Map<String, String>;
                      errorMessage = response['message'];
                      if(response.containsKey('address')) {
                        address = response['address']!;
                        currentWeather = await Weather.getCurrentWeather(value);
                        Map<String, List<Weather>> weatherForecast = await Weather.getForecast(lon: currentWeather.lon!, lat: currentWeather.lat!);
                        //print('hourly ${weatherForecast['hourly']![1].time}');
                        hourlyWeather = weatherForecast['hourly']!;
                        dailyWeather = weatherForecast['daily']!;
                      }
                      setState(() {});
                    },
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: '郵便番号を入力'
                    ),
                  ),
              ),
              Text(errorMessage ?? '', style: TextStyle(color: Colors.red)),
              SizedBox(height: 50),
              Text(address, style: TextStyle(fontSize: 25),),
              Text(currentWeather?.description ?? ''),
              Text('${currentWeather?.temp!}°', style: TextStyle(fontSize: 80),),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Text('最高:${currentWeather?.tempMax!}°' ?? '最高:―'),
                  ),
                  Text('最低:${currentWeather?.tempMin!}°' ?? '最低:―')
                ],
              ),
              SizedBox(height: 50),
              Divider(height: 0),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: hourlyWeather.map((weather) {
                    return  Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
                      child: Column(
                        children: [
                          Text('${DateFormat('H').format(weather.time!)}時'),
                          Image.network('http://openweathermap.org/img/wn/${weather.icon}@2x.png',width: 30),
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text('${weather.temp!}°', style: TextStyle(fontSize: 18)),
                          )
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
              Divider(height: 0),
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Column(
                      children: dailyWeather.map((weather) {
                        return  Container(
                          height: 50,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                 width: 50,
                                  child: Text('${weekDay[weather.time!.weekday - 1]}曜日')),
                                Row(
                                  children: [
                                    Container(
                                      width: 35,
                                    ),
                                    Image.network('http://openweathermap.org/img/wn/${weather.icon}@2x.png',width: 30),
                                    Container(
                                      width: 35,
                                        child: Text('${weather.rainyPercent}%', style: TextStyle(color: Colors.lightBlueAccent))
                                    ),
                                  ],
                                ),
                                Container(
                                  width: 50,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text('${weather.tempMax}°', style: TextStyle(fontSize: 16)),
                                        Text('${weather.tempMin}°', style: TextStyle(fontSize: 16, color: Colors.black.withOpacity(0.4))),
                                      ],
                                  ),
                                ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
            ],
          ),
      ),
    );
  }
}