class UserModel {
  String name;
  String uid;
  
  UserModel({required this.uid, required this.name});

  static UserModel fromDB(Map<dynamic, dynamic> data) => UserModel(
        name: data["name"],
        uid: data['foodlist'],
      );
}
