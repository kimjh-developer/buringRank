import 'package:equatable/equatable.dart';

enum UserState { normal, logout, terminate }

class UserModel extends Equatable {
  final String? userIdentifier;
  final String? userFullName;
  final String? userEmail;
  final int? userAge;
  final double? maxHeartRate;
  final UserState userState;
  final String? userNickname;

  const UserModel({
    this.userIdentifier,
    this.userFullName,
    this.userEmail,
    this.userAge,
    this.maxHeartRate,
    this.userState = UserState.normal,
    this.userNickname,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userIdentifier: json['userIdentifier'],
      userFullName: json['userFullName'],
      userEmail: json['userEmail'],
      userAge: json['userAge'],
      maxHeartRate: (json['maxHeartRate'] as num?)?.toDouble(),
      userState: UserState.values.firstWhere(
        (e) => e.toString().split('.').last == json['userState'],
        orElse: () => UserState.normal,
      ),
      userNickname: json['userNickname'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userIdentifier': userIdentifier,
      'userFullName': userFullName,
      'userEmail': userEmail,
      'userAge': userAge,
      'maxHeartRate': maxHeartRate,
      'userState': userState.toString().split('.').last,
      'userNickname': userNickname,
    };
  }

  @override
  List<Object?> get props => [
    userIdentifier,
    userFullName,
    userEmail,
    userAge,
    maxHeartRate,
    userState,
    userNickname,
  ];
}
