import 'package:objectbox/objectbox.dart';

@Entity()
class User {
  int id;
  String email;
  String password;

  User({this.id = 0, required this.email, required this.password});
}