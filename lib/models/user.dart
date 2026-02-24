import 'package:uuid/uuid.dart';
import 'package:hive/hive.dart';

part 'user.g.dart';

@HiveType(typeId: 1)
class User extends HiveObject {
  User({
    required this.id,
    required this.email,
    required this.password,
    required this.fullName,
    required this.createdAt,
  });

  /// ID
  @HiveField(0)
  final String id;

  /// EMAIL
  @HiveField(1)
  String email;

  /// PASSWORD
  @HiveField(2)
  String password;

  /// FULL NAME
  @HiveField(3)
  String fullName;

  /// CREATED AT
  @HiveField(4)
  DateTime createdAt;

  /// Create new User
  factory User.create({
    required String email,
    required String password,
    required String fullName,
  }) => User(
    id: const Uuid().v1(),
    email: email,
    password: password,
    fullName: fullName,
    createdAt: DateTime.now(),
  );
}
