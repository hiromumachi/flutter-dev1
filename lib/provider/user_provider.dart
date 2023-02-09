import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class UserProvider {
  Future<UserCredential> register(email, password) async {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final credential = await auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    return credential;
  }

  Future<UserCredential> signIn(email, password) async {
    final _auth = FirebaseAuth.instance;

    final credential = await _auth.signInWithEmailAndPassword(
        email: email, password: password);

    return credential;
  }

  Future<UserCredential> signInWithGoogle() async {
    // 認証フローのトリガー
    final googleUser = await GoogleSignIn().signIn();
    // リクエストから、認証情報を取得
    final googleAuth = await googleUser!.authentication;
    // クレデンシャルを新しく作成

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    // サインインしたら、UserCredentialを返す
    return FirebaseAuth.instance.signInWithCredential(credential);
  }
}
