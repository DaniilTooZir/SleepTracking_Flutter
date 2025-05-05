import 'dart:typed_data';

class UserPhoto {
  final int? id;
  final int userId;
  final Uint8List photo;

  UserPhoto({
    this.id,
    required this.userId,
    required this.photo,
  });

  factory UserPhoto.fromMap(Map<String, dynamic> map) {
    return UserPhoto(
      id: map['Id'],
      userId: map['UserId'],
      photo: map['Photo'] != null ? Uint8List.fromList(map['Photo']) : Uint8List(0),
    );
  }

  Map<String, dynamic> toMap({bool includeId = false}) {
    final map = <String, dynamic>{
      'UserId': userId,
      'Photo': photo,
    };
    if(includeId && id != null){
      map['Id'] = id;
    }
    return map;
  }
}