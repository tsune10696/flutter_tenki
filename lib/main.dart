import 'package:flutter/material.dart'; //material.dartを使用
import 'package:tenki_app/top_page.dart'; //top_page.dartをimport

//アプリのメインコード
void main() {
  runApp(const MyApp());
}

//MyAppの構成を記述するクラス
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, //デバックモードでバナーを表示しないよう設定
      title: 'Weather', //アプリのタイトル
      theme: ThemeData(
        //アプリケーションの色のスキームを深紫に設定
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true, //Material Design 3.0の機能を有効にする
      ),
      home: TopPage(), //アプリ起動時に表示される画面を設定
    );
  }
}

