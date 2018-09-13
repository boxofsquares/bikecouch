import 'package:flutter/material.dart';

import '../models/app_state.dart';
import '../app_state_container.dart';
import '../widgets/row_list_card.dart';
import '../widgets/actionable_list_card.dart';

import 'package:firebase_auth/firebase_auth.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  AppState appState;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    var container = AppStateContainer.of(context);
    appState = container.state;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        elevation: 0.0,
        title: Text('${appState.user.name}')
      ),
      body: ListView(
        children: [
          SizedBox(height: 20.0),
          Center(
            child: CircleAvatar(
              child: Text(
                appState.user.name.substring(0, 1),
                style: TextStyle(
                  fontSize: 40.0,
                )
              ),
              radius: 50.0
            )
          ),
          SizedBox(height: 20.0),
          RowListCard(
            leftText: 'Name',
            rightText: appState.user.name
          ),
          RowListCard(
            leftText: 'Email',
            rightText: appState.user.email,
          ),
          RowListCard(
            leftText: 'Points',
            rightText: appState.user.points.toString()
          ),
          RowListCard(
            leftText: 'Tokens',
            rightText: appState.user.tokens.toString()
          ),
          SizedBox(height: 20.0),
          ActionableListCard(
            text: 'Change password',
            onPress: () {
              _auth.sendPasswordResetEmail(email: appState.user.email);
            },
          ),
          ActionableListCard(
            text: 'Sign Out',
            onPress: () {
              // Navigator.pop(context);
              Navigator.popUntil(context, ModalRoute.withName(Navigator.defaultRouteName));
              // TODO: bug from popping through word list page that needs non-null user
              _auth.signOut();
              container.setUser(null);
            }
          ),

          
        ]
      )
    );
  } 
}