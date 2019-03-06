import 'dart:typed_data';

import 'package:flutter/material.dart';

import 'package:flutter_native_camera/flutter_native_camera.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Uint8List photoData;
  NativeCameraController _cameraController;

  int test = 0;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.photo_camera),
          onPressed: () async {
            photoData = await _cameraController.takePhoto();
            setState(() {});
          },
        ),
        body: Center(
          child: Container(
            width: 200,
            child: Column(
              children: <Widget>[
                Builder(
                  builder: (context) {
                    debugPrint(MediaQuery.of(context).size.toString());
                    return AspectRatio(
                      aspectRatio: MediaQuery.of(context).size.aspectRatio > 1
                          ? 16 / 9
                          : 9 / 16,
                      child: NativeCameraView(
                        onNativeCameraViewCreated: (controller) =>
                            _cameraController = controller,
                      ),
                    );
                  },
                ),
                Padding(
                  padding: EdgeInsets.all(16),
                  child: photoData != null
                      ? Image.memory(photoData)
                      : FlutterLogo(),
                ),
                Text(
                  test.toString(),
                  style: TextStyle(color: Colors.transparent),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
