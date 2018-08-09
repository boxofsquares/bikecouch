import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'models/app_state.dart';
import 'models/user.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'utils/storage.dart';

class AppStateContainer extends StatefulWidget {
  // Your apps state is managed by the container
  final AppState state;
  // This widget is simply the root of the tree,
  // so it has to have a child!
  final Widget child;

  AppStateContainer({
    @required this.child,
    this.state,
  });

  // This creates a method on the AppState that's just like 'of'
  // On MediaQueries, Theme, etc
  // This is the secret to accessing your AppState all over your app
  static _AppStateContainerState of(BuildContext context) {
    return (context.inheritFromWidgetOfExactType(_InheritedStateContainer)
            as _InheritedStateContainer)
        .data;
  }

  @override
  _AppStateContainerState createState() => new _AppStateContainerState();
}

class _AppStateContainerState extends State<AppStateContainer> {

  // Just padding the state through so we don't have to 
  // manipulate it with widget.state.
  AppState state;
  FirebaseAuth _auth = FirebaseAuth.instance;
  @override
  void initState() {
    // You'll almost certainly want to do some logic 
    // in InitState of your AppStateContainer. In this example, we'll eventually
    // write the methods to check the local state
    // for existing users and all that.
    super.initState();
    if (widget.state != null) {
      state = widget.state;
    } else {
      state = AppState.loading();
      _initSignInState();
    }
  }


  

  _initSignInState() async {

    var user = await _auth.currentUser();
    if (user == null) {
      // setState(() {
      //         state.isSignedIn = false;
      //       });
      setState(() => state.isLoading = false);
    } else {
      Storage.getUserDetails(user)
        .then((user) {
          setState(() {
              // state.isSignedIn = true;
              state.isLoading = false;
              state.user = user;
            });
        })
        .catchError((e) => print(e));
      
    }


  }




  setUser(User user) {
    setState(() => state.user = user);
    print(user.name);
  }

  // isLoading(bool isLoading) {
  //   setState(() => state.isLoading = isLoading);
  //   print('setting state to isLoading: $isLoading');
  // }

  // isSignedIn(bool isSignedIn) {
  //   setState(() => state.isSignedIn = isSignedIn);
  // }





  // So the WidgetTree is actually
  // AppStateContainer --> InheritedStateContainer --> The rest of your app. 
  @override
  Widget build(BuildContext context) {
    return new _InheritedStateContainer(
      data: this,
      child: widget.child,
    );
  }
}

// This is likely all your InheritedWidget will ever need.
class _InheritedStateContainer extends InheritedWidget {
  // The data is whatever this widget is passing down.
  final _AppStateContainerState data;

  // InheritedWidgets are always just wrappers.
  // So there has to be a child, 
  // Although Flutter just knows to build the Widget thats passed to it
  // So you don't have have a build method or anything.
  _InheritedStateContainer({
    Key key,
    @required this.data,
    @required Widget child,
  }) : super(key: key, child: child);
  
  // This is a better way to do this, which you'll see later.
  // But basically, Flutter automatically calls this method when any data
  // in this widget is changed. 
  // You can use this method to make sure that flutter actually should
  // repaint the tree, or do nothing.
  // It helps with performance.
  @override
  bool updateShouldNotify(_InheritedStateContainer old) => true;
}
