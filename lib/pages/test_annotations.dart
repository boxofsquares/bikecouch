import 'package:flutter/material.dart';
import '../utils/vision.dart';
import '../components/list_card.dart';

class TestAnnotations extends StatelessWidget {
  TestAnnotations({this.vs});
  final VisionResponse vs;

  List<Widget> _pullAnnos() {
    return vs.annotations.map((annotation) {
      return ListCard(
        text: annotation.description
      );
    }).toList();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('debug annos')),
      body: ListView(
        children: _pullAnnos()
      )
    );
  }
}