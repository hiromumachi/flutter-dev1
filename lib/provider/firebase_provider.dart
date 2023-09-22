import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:refmanage/models/food_model.dart';

class FirebaseProvider {
  var db = FirebaseFirestore.instance;
  List<int> foodNums = [1, 2, 3, 4, 5, 6, 7, 8, 9];
  String foodlistCollection = 'foodlist';
  String? _uid;

  Stream<List<FoodModel>> readFoodList() {
    final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
    final User? currentUser = firebaseAuth.currentUser;
    _uid = currentUser!.uid.toString();
    return db
        .collection(foodlistCollection)
        .where('uid', isEqualTo: _uid)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => FoodModel.fromDB(doc.data(), doc.reference.id))
            .toList());
  }

  void updata(foodInfo, value) {
    db
        .collection(foodlistCollection)
        .doc(foodInfo.docid)
        .update({'food': foodInfo.food, 'pcs': value});
  }

  void delete(foodInfo) {
    db.collection(foodlistCollection).doc(foodInfo.docid).delete();
  }

  // getUserUid() async {
  //   final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  //   final User? _currentUser = await firebaseAuth.currentUser;
  //   uid = _currentUser!.uid.toString();
  // }

  String get uid => _uid!;

  void dbAdd(selectnum, text, uid) {
    FirebaseFirestore.instance
        .collection('foodlist')
        .add({'food': text, 'pcs': selectnum, 'uid': uid});
  }
}
