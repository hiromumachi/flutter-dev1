import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../provider/firebase_provider.dart';

class AddDialog extends StatefulWidget {
  const AddDialog({Key? key, required this.uid}) : super(key: key);
  final String uid;

  @override
  State<AddDialog> createState() => _TextEditingDialogState();
}

class _TextEditingDialogState extends State<AddDialog> {
  FirebaseProvider fp = FirebaseProvider();
  List<int> Nums = [1, 2, 3, 4, 5, 6, 7, 8, 9];
  final textController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  var selectNum;
  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // TextFormFieldに初期値を代入する
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Form(
        key: formKey,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Flexible(
              child: TextFormField(
                validator: ((value) {
                  if (value!.isEmpty || value == null) {
                    return '空白です';
                  }
                }),
                autofocus: true, // ダイアログが開いたときに自動でフォーカスを当てる
                controller: textController,
                decoration: const InputDecoration(
                  labelText: '食材 *',
                ),
                onFieldSubmitted: (_) {
                  // DBにPUSH
                },
              ),
            ),
            const SizedBox(
              width: 10,
            ),
            Flexible(
              child: DropdownButton(
                hint: Text("個数"),
                value: selectNum,
                items: Nums.map<DropdownMenuItem<int>>((list) =>
                    DropdownMenuItem(
                        value: list, child: Text(list.toString()))).toList(),
                onChanged: (value) {
                  setState(() {
                    selectNum = value as int;
                  });
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('キャンセル'),
        ),
        TextButton(
          onPressed: () {
            if (selectNum == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("個数が未入力です。")),
              );
            } else {
              if (formKey.currentState!.validate()) {
                fp.dbAdd(selectNum, textController.text, widget.uid);
                Navigator.of(context).pop();
                print("2");
              } else {
                formKey.currentState!.save();
                // print("1");
              }
            }
          },
          child: const Text('登録'),
        )
      ],
    );
  }
}
