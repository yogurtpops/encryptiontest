import 'dart:async';
import 'dart:io';
import 'package:aes_crypt/aes_crypt.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_file_manager/flutter_file_manager.dart';
import 'package:flutter_full_pdf_viewer/full_pdf_viewer_scaffold.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(MaterialApp(
    title: 'Plugin example app',
    home: MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Plugin example app')),
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            RaisedButton(
              child: Text("Open PDF"),
              onPressed: () async {
                await tryEncryption();
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PDFScreen(encrypted_filepath)),
                );
              }
            ),
            Padding(
              padding: const EdgeInsets.only(left:16.0),
              child: RaisedButton(
                  child: Text("Open File Manager"),
                  onPressed: () async {

                  }
              ),
            ),
          ],
        ),
      ),
    );
  }

}



String encrypted_filepath = "/data/user/0/com.example.encrypt_pdf_project/app_flutter/dummy_enc.txt.aes";
String key = "my cool password";

Future<void> tryEncryption() async {
  String pathPDF = "/storage/emulated/0/my_file/dummy.pdf";
  var crypt = AesCrypt(key);
  crypt.setOverwriteMode(AesCryptOwMode.on);
  crypt.encryptFileSync(pathPDF, encrypted_filepath);
}

class PDFScreenState extends State<PDFScreen> {
  String pathPDF = "";

  @override
  void initState() {
    tryDecryption();
  }



  @override
  void dispose() {
    print("disposed!");
    tryDelete();
    print("deleted!");
    super.dispose();
  }

  tryDelete() async {
    final dir = Directory(pathPDF);
    dir.deleteSync(recursive: true);
  }

  tryDecryption() async {
    try{
      var crypt = AesCrypt(key);
      crypt.setOverwriteMode(AesCryptOwMode.on);
      var systemTempDir = Directory.systemTemp.createTempSync();
      var savePath = "${systemTempDir.path}/dummy_dec.pdf";
      File(savePath).createSync();
      await crypt.decryptFileSync(encrypted_filepath, savePath);
      setState(() {
        pathPDF = savePath;
      });
      print('success decrypt file in $savePath');
    } catch(_){
      print('error decrypt file $_');
    }
  }

  @override
  Widget build(BuildContext context) {
    return pathPDF==""
        ? Container()
        : PDFViewerScaffold(
        appBar: AppBar(
          title: Text("Document"),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.share),
              onPressed: () {},
            ),
          ],
        ),
        path: pathPDF);
  }
}

class PDFScreen extends StatefulWidget {
  final String pathPDF;
  PDFScreen(this.pathPDF);

  @override
  State<StatefulWidget> createState() {
    return PDFScreenState();
  }
}