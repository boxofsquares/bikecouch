// Models
import 'package:bikecouch/models/user.dart';

class Invitation {
  Invitation({this.user, this.invitationUID});
  
  final User user;
  final String invitationUID;
}