import 'package:flutter/material.dart';
import 'package:media_gallery_example/pages/collections.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MediaCollectionsPage(),
    );
  }
}
