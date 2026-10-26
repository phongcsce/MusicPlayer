import 'package:equatable/equatable.dart';

class UserProfile extends Equatable {
  const UserProfile({
    required this.displayName,
    required this.avatarUrl,
  });

  final String displayName;
  final String avatarUrl;

  @override
  List<Object?> get props => [displayName, avatarUrl];
}
