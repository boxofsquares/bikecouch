import 'user.dart';

class AppState {
  // Your app will use this to know when to display loading spinners.
  bool isLoading;
  bool isSignedIn;
  User user;

  // Constructor
  AppState({
    this.isLoading = false,
    this.isSignedIn,
    this.user,
  });

  factory AppState.loading() => new AppState(isLoading: true);
}