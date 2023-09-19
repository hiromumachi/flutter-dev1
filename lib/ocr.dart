import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ocrPage extends StatefulWidget {
  // null safety対応のため、Keyに?をつけ、titleは初期値""を設定
  const ocrPage({Key? key, this.title = ""}) : super(key: key);

  final String title;

  @override
  _ocrPageState createState() => _ocrPageState();
}

class _ocrPageState extends State<ocrPage> {
  // null safety対応のため、?でnull許容
  File? _image;

  final _picker = ImagePicker();

  // null safety対応のため、?でnull許容
  String? _result;

  @override
  void initState() {
    super.initState();
    _signIn();
  }

  // 匿名でのFirebaseログイン処理
  void _signIn() async {
    await FirebaseAuth.instance.signInAnonymously();
  }

  Future _getImage(FileMode fileMode) async {
    // null safety対応のため、lateで宣言
    late final _pickedFile;

    // image_pickerの機能で、カメラからとギャラリーからの2通りの画像取得（パスの取得）を設定
    if (fileMode == FileMode.CAMERA) {
      _pickedFile = await _picker.pickImage(source: ImageSource.camera);
    } else {
      _pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    }

    setState(() {
      if (_pickedFile != null) {
        _image = File(_pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('仮想冷蔵庫'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),

          // 写真のサイズによって画面はみ出しエラーが生じるのを防ぐため、
          // Columnの上にもSingleChildScrollViewをつける
          child: SingleChildScrollView(
            child: Column(children: [
              // 画像を取得できたら表示
              // null safety対応のため_image!とする（_imageはnullにならない）
              if (_image != null) Image.file(_image!, height: 400),

              // 画像を取得できたら解析ボタンを表示
              if (_image != null) _analysisButton(),
              SizedBox(
                  height: 240,

                  // OCR（テキスト検索）の結果をスクロール表示できるようにするため
                  // 結果表示部分をSingleChildScrollViewでラップ
                  child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: Text((() {
                        // OCR（テキスト認識）の結果（_result）を取得したら表示
                        if (_result != null) {
                          // null safety対応のため_result!とする（_resultはnullにならない）
                          return _result!;
                        } else if (_image != null) {
                          return 'ボタンを押すと解析が始まります';
                        } else {
                          return 'テキスト認識したい画像を撮影または読込んでください';
                        }
                      }())))),
            ]),
          ),
        ),
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // カメラ起動ボタン
          FloatingActionButton(
            onPressed: () => _getImage(FileMode.CAMERA),
            tooltip: 'カメラから選択',
            heroTag: null,
            child: const Icon(Icons.camera_alt),
          ),

          // ギャラリー（ファイル）検索起動ボタン
          FloatingActionButton(
            onPressed: () => _getImage(FileMode.GALLERY),
            tooltip: 'ファイルから選択',
            heroTag: null,
            child: const Icon(Icons.folder_open),
          ),
        ],
      ),
    );
  }

  // OCR（テキスト認識）開始処理
  Widget _analysisButton() {
    return ElevatedButton(
      child: const Text('解析'),
      onPressed: () async {
        // null safety対応のため_image!とする（_imageはnullにならない）
        // List<int> _imageBytes = _image!.readAsBytesSync();
        // String _base64Image = base64Encode(_imageBytes);

        // // Firebase上にデプロイしたFunctionを呼び出す処理
        // HttpsCallable _callable =
        //     FirebaseFunctions.instance.httpsCallable('annotateImage');
        // final params = '''{
        //   "image": {"content": "$_base64Image"},
        //   "features": [{"type": "TEXT_DETECTION"}],
        //   "imageContext": {
        //     "languageHints": ["ja"]
        //   }
        // }''';

        final InputImage imageFile = InputImage.fromFilePath(_image!.path);

        final textRecognizer =
            TextRecognizer(script: TextRecognitionScript.japanese);

        final RecognizedText recognizedText =
            await textRecognizer.processImage(imageFile);
        String text = recognizedText.text;
        for (TextBlock block in recognizedText.blocks) {
          // final Rect rect = block.rect;
          // final List<Offset> cornerPoints = block.cornerPoints;
          // final String text = block.text;
          // final List<String> languages = block.recognizedLanguages;

          for (TextLine line in block.lines) {
            // Same getters as TextBlock
            print(line.text);
          }
        }
        // print(text);

        // final _text = await _callable(params).then((v) {
        //   print(v.data);
        //   return v.data[0]["fullTextAnnotation"]["text"];
        // }).catchError((e) {
        //   print('ERROR: $e');
        //   return '読み取りエラーです';
        // });

        // OCR（テキスト認識）の結果を更新
        setState(() {
          _result = text;
        });
      },
    );
  }
}

// カメラ経由かギャラリー（ファイル）経由かを示すフラグ
enum FileMode {
  CAMERA,
  GALLERY,
}
