import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:refmanage/models/food_model.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:refmanage/screen/dialog_screen.dart';
import '../provider/firebase_provider.dart';

class topscreen extends StatefulWidget {
  const topscreen({Key? key}) : super(key: key);

  @override
  topState createState() => topState();
}

class topState extends State<topscreen> {
  List<int> foodNums = [1, 2, 3, 4, 5, 6, 7, 8, 9];
  FirebaseProvider firebaseprovider = FirebaseProvider();
  ValueNotifier<bool> isDialOpen = ValueNotifier(false);

  Widget buildFood(FoodModel foodInfo) {
    int selectNum = foodInfo.pcs;
    return ListTile(
      title: Text(foodInfo.food),
      trailing: Row(mainAxisSize: MainAxisSize.min, children: [
        DropdownButton(
          value: foodInfo.pcs,
          items: foodNums
              .map<DropdownMenuItem<int>>((list) =>
                  DropdownMenuItem(value: list, child: Text(list.toString())))
              .toList(),
          onChanged: (value) {
            firebaseprovider.updata(foodInfo, value);
            setState(() {
              selectNum = value as int;
            });
          },
        ),
        IconButton(
            onPressed: () {
              firebaseprovider.delete(foodInfo);
            },
            icon: const Icon(Icons.delete))
      ]),
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // Future(() async {
    //   await getUserUid();
    // });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('冷蔵庫にある食材'),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: StreamBuilder<List<FoodModel>>(
              stream: firebaseprovider.readFoodList(),
              builder: ((context, snapshot) {
                if (snapshot.hasData) {
                  final foodList = snapshot.data;
                  return foodList!.isEmpty
                      ? const SizedBox(
                          height: 40, child: Center(child: Text("no food")))
                      : ListView(
                          scrollDirection: Axis.vertical,
                          shrinkWrap: true,
                          children: foodList.map(buildFood).toList(),
                        );
                } else {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
              }),
            ),
          ),
          SpeedDial(
            icon: Icons.add,
            backgroundColor: Colors.pink,
            closeManually: true,
            activeIcon: Icons.close,
            openCloseDial: isDialOpen,
            children: [
              SpeedDialChild(
                child: Icon(Icons.camera_alt_sharp),
                label: '画像から追加',
                backgroundColor: Colors.blue,
                onTap: () async {
                  isDialOpen.value = false;
                  await Navigator.pushNamed(context, '/ocrPage');
                },
              ),
              SpeedDialChild(
                child: Icon(Icons.text_decrease),
                label: 'テキストから追加',
                backgroundColor: Colors.blue,
                onTap: () {
                  isDialOpen.value = false;
                  showDialog(
                      context: context,
                      builder: (context) {
                        return AddDialog(uid: firebaseprovider.uid);
                      });
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
