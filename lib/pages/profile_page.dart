import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import '../models/app_state.dart';
import '../app_state_container.dart';
import '../widgets/row_list_card.dart';
import '../widgets/actionable_list_card.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import 'dart:io';

import 'package:image_picker/image_picker.dart';


class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  AppState appState;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  File _image;
  Future getImage() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);
    setState(() => _image = image);
  }

  Future getImageCamera() async {
    var image = await ImagePicker.pickImage(source: ImageSource.camera);
    setState(() => _image = image);
  }

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
            child: GestureDetector(
                child: CircleAvatar(
                  child: Text(
                    appState.user.name.substring(0, 1),
                    style: TextStyle(
                      fontSize: 40.0,
                    )
                  ),
                  radius: 50.0
                ),
                onTap: () {
                  if (Platform.isAndroid) {
                    showModalBottomSheet(
                      context: context,
                      builder: (BuildContext context) {
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ListTile(
                              title: Text('Take photo'),
                              onTap: (){getImageCamera();},
                            ),
                            ListTile(
                              title: Text('Choose form Library'),
                              onTap: (){getImage();}
                            )
                          ]
                        );
                      }

                    );
                  } else if (Platform.isIOS) {
                    showCupertinoModalPopup(
                      context: context,
                      builder: (BuildContext context) {
                        return CupertinoActionSheet(
                          actions: [
                            // Text('Open from camera role'),
                            // Text('Take picture')
                            CupertinoActionSheetAction(
                              child: Text('Take photo'),
                              onPressed: () {getImageCamera();}
                            ),
                            CupertinoActionSheetAction(
                              child: Text('Choose from Library'),
                              onPressed: () {getImage();}
                            ),
                          ],
                          cancelButton: CupertinoActionSheetAction(
                            child: Text('Cancel'),
                            onPressed: Navigator.of(context).pop
                          ),
                        );
                      }
                    );
                  }
                  
                }
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
          ActionableListCard(
            text: 'Delete account',
            onPress: () { // TODO: use factory https://medium.com/flutter-io/do-flutter-apps-dream-of-platform-aware-widgets-7d7ed7b4624d
              if (Platform.isAndroid) {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('Confirm'),
                      content: Text('Are you sure you want to completely delete your account and all its data?'),
                      actions: [
                        FlatButton(
                          child: Text('Cancel'),
                          onPressed: () {
                            Navigator.of(context).pop();
                          }
                        ),
                        FlatButton(
                          child: Text(
                            'Delete',
                            style: TextStyle(color: Colors.red)
                          ), // TODO: ask Janik if android alert is also red
                          onPressed: () {
                            // var _user = await _auth.currentUser();
                            // await _user.delete();
                            // Navigator.popUntil(context, ModalRoute.withName(Navigator.defaultRouteName));
                            // container.setUser(null);
                            print('delete');
                          }
                        )
                      ]

                    );
                  }
                );
              } else if (Platform.isIOS) {
                showCupertinoDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return CupertinoAlertDialog(
                      title: Text('Confirm'),
                      content: Text('Are you sure you want to completely delete your account and all its data?'),
                      actions: [
                        CupertinoDialogAction(
                          child: Text('Cancel'),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                        CupertinoDialogAction(
                          child: Text(
                              'Delete',
                              style: TextStyle(color: Colors.red)
                            ),
                          onPressed: () => print('delete')
                        )
                      ] 
                    );
                  }
                );
              }

              
            },
            textColor: Colors.red,
          ),
        ]
      )
    );
  } 
}