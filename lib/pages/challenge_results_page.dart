import 'package:flutter/material.dart';

import '../components/pill_button.dart';

class ChallengeResults extends StatelessWidget {
  ChallengeResults({this.success});
  final bool success;

  // List<Widget> _pullAnnos() {
  //   return vs.annotations.map((annotation) {
  //     return ListCard(
  //       text: annotation.description
  //     );
  //   }).toList();
  // }

  @override
  Widget build(BuildContext context) {
    Widget successWidget = new Container(
      child: new Center(
        child: Text(
          'Success :)',
          style: TextStyle(
              fontSize: 64.00,
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.bold),
        ),
      ),
    );

    Widget failureWidget = new Container(
      child: new Center(
        child: Text(
          'Failure :(',
          style: TextStyle(
              fontSize: 64.00,
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.bold),
        ),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('Challenge Results'),
        leading: new Icon(Icons.stars),
        elevation: 0.0,
      ),
      body: success ? successWidget : failureWidget,
      floatingActionButton: success
          ? PillButton(
              text: 'Collect Your Points',
              onTap: () {
                //NOTE: popUntilNamed(context, '/home') gave a illegible error
                // assertion failed: "!_debugLocked is not true"
                Navigator.pop(context); // results page
                Navigator.pop(context); // camera
              },
            )
          : PillButton(
              text: 'Return',
              onTap: () {
                //NOTE: popUntilNamed(context, '/home') gave a illegible error
                // assertion failed: "!_debugLocked is not true"
                Navigator.pop(context); // results page
                Navigator.pop(context); // camera
              },
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
