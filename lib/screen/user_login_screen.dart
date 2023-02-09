import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:refmanage/main.dart';
import 'package:refmanage/models/food_model.dart';
import 'package:refmanage/provider/user_provider.dart';
import 'package:refmanage/screen/top_screen.dart';

class UserLoginScreen extends StatefulWidget {
  @override
  _UserLogin createState() => _UserLogin();
}

class _UserLogin extends State<UserLoginScreen> {
  //ステップ１

  final UserProvider _userProvider = UserProvider();

  String email = '';
  String password = '';
  String infoText = '';

  void errorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void checkError(code) {
    if (code == 'invalid-email') {
      errorMessage('メールアドレスのフォーマットが正しくありません');
    } else if (code == 'user-disabled') {
      errorMessage('現在指定したメールアドレスは使用できません');
    } else if (code == 'user-not-found') {
      errorMessage('指定したメールアドレスは登録されていません');
    } else if (code == 'wrong-password') {
      errorMessage('パスワードが間違っています');
    } //登録
    else if (code == 'email-already-in-use') {
      errorMessage('すでに使用されているメールアドレスです');
    } else if (code == 'weak-password') {
      errorMessage('パスワードが弱いです');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ログイン'),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: TextField(
              onChanged: (value) {
                email = value;
              },
              decoration: const InputDecoration(
                hintText: 'メールアドレスを入力',
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: TextField(
              onChanged: (value) {
                password = value;
              },
              obscureText: true,
              decoration: const InputDecoration(
                hintText: 'パスワードを入力',
              ),
            ),
          ),
          ElevatedButton(
            child: const Text('ログイン'),
            //ステップ２
            onPressed: () async {
              try {
                await _userProvider.signIn(email, password);

                if (mounted) {
                  Navigator.pushNamed(context, '/topPage');
                }
              } on FirebaseAuthException catch (e) {
                checkError(e.code);
              }
            },
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                // メール/パスワードでユーザー登録
                await _userProvider.register(email, password);
                if (mounted) {
                  Navigator.pushNamed(context, '/topPage');
                }
              } on FirebaseAuthException catch (e) {
                checkError(e.code);
              } catch (e) {
                errorMessage(e.toString());
              }
            },
            child: const Text('新規登録'),
          ),
          SizedBox(
              width: 90, //横幅
              height: 40, //高さ
              child: ElevatedButton(
                onPressed: () async {
                  try {
                    await _userProvider.signInWithGoogle();
                    if (mounted) {
                      Navigator.pushNamed(context, '/topPage');
                    }
                  } on FirebaseAuthException catch (e) {
                    errorMessage('登録に失敗しました');
                  } on Exception catch (e) {
                    errorMessage('登録に失敗しました${e.toString()}');
                  }
                },
                style: ElevatedButton.styleFrom(
                    primary: Colors.white, //ボタンの背景色
                    onPrimary: Colors.red),
                child: const Text('Google'),
              ))
        ],
      ),
    );
  }
}
