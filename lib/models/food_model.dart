class FoodModel {
  String food;
  int pcs;
  String docid;
  FoodModel({required this.food, required this.pcs, required this.docid});

  static FoodModel fromDB(Map<dynamic, dynamic> data, docid) {
    return FoodModel(food: data['food'], pcs: data['pcs'], docid: docid);
  }
}
