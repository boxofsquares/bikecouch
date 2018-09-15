// Flutter
import 'package:flutter/material.dart';

// Utils
import 'package:bikecouch/utils/storage.dart';

// Models
import 'package:bikecouch/models/app_state.dart';
import 'package:bikecouch/models/challenge.dart';
import 'package:bikecouch/app_state_container.dart';

// UI Components
import 'package:bikecouch/components/pill_button.dart';

class ChallengeResults extends StatelessWidget {
  ChallengeResults({this.success, this.challenge});
  final bool success;
  final Challenge challenge;

  AppState appState;

  @override
  Widget build(BuildContext context) {
    var container = AppStateContainer.of(context);
    appState = container.state;

    Storage.deleteChallenge(challenge);
    Storage.updateScoreWithFriend(
                      appState.user.uuid,
                      this.challenge.challenger.uuid,
                      challenge.challenger.score + 100);

    Widget successWidget = new Column(
      children: [
        Text(
          'Success :)',
          style: TextStyle(
              fontSize: 64.00,
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.bold),
        ),
        Text('Points earned: 100'),
      ],
      mainAxisAlignment: MainAxisAlignment.center,
    );

    Widget failureWidget = new Column(
      children: [
        Text(
          'Failure :(',
          style: TextStyle(
              fontSize: 64.00,
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.bold),
        ),
        Text('No points earned...'),
      ],
      mainAxisAlignment: MainAxisAlignment.center,
    );

    return WillPopScope(
      child: Scaffold(
        appBar: AppBar(
          title: Text('Challenge Results'),
          leading: new Icon(Icons.stars),
          elevation: 0.0,
        ),
        body: Center(
          child: success ? successWidget : failureWidget,
        ),
        floatingActionButton: success
            ? PillButton(
                text: 'Return the challenge!',
                onTap: () {
                  returnToHome(context, 0);
                },
              )
            : PillButton(
                text: 'Return',
                onTap: () {
                  returnToHome(context, 1);
                },
              ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      ),
      onWillPop: () {
        returnToHome(context, 1);
      },
    );
  }

  void returnToHome(BuildContext context, int targetHome) {
    //NOTE: popUntilNamed(context, '/home') gave a illegible error
    // assertion failed: "!_debugLocked is not true"
    Navigator.pop(context); // results page
    Navigator.pop(context, targetHome); // camera
  }
}
