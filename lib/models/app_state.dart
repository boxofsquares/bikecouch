// Models
import 'package:bikecouch/models/user.dart';

class AppState {
  // Your app will use this to know when to display loading spinners.
  // bool isSignedIn;
  User user;
  bool isLoading;

  // Constructor
  AppState({
    // this.isSignedIn,
    this.isLoading = false,
    this.user,
  });

  factory AppState.loading() => AppState(isLoading: true);
}