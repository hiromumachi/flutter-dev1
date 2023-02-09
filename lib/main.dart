import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:refmanage/ocr.dart';
export 'package:provider/provider.dart';
import 'package:refmanage/screen/top_screen.dart';

import 'screen/user_login_screen.dart';

void main() async {
  // main関数内での非同期処理（下のFirebase.initializeApp）を可能にする処理
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(AppState());
}

// アプリ画面を描画する前に、Firebaseの初期化処理を実行
class AppState extends StatelessWidget{
  const AppState({Key? key}) : super(key: key);

  Future<FirebaseApp> _initialize() async {
    return Firebase.initializeApp();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initialize(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(
              child: Text(
            '読み込みエラー',
            textDirection: TextDirection.ltr,
          ));
        }

        if (snapshot.connectionState == ConnectionState.done) {
          return MyApp();
        }

        return const Center(
            child: Text(
          '読み込み中...',
          textDirection: TextDirection.ltr,
        ));
      },
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: '仮想冷蔵庫',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        // home: MyHomePage(title: '読み取りページ'),
        initialRoute: '/userLogin', // default is '/'
        routes: {
          '/userLogin': (context) => UserLoginScreen(),
          '/topPage': (context) => topscreen(),
          '/ocrPage': (context) => const ocrPage(),
        });
  }
}
