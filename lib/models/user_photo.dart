import 'dart:typed_data';
import 'dart:convert';

class UserPhoto {
  final int? id;
  final int userId;
  final String photo;

  UserPhoto({
    this.id,
    required this.userId,
    required this.photo,
  });

  factory UserPhoto.fromMap(Map<String, dynamic> map) {
    final photoField = map['Photo'];
    String photoBase64;
    if (photoField is String) {
      photoBase64 = photoField;
    } else {
      throw Exception('Неизвестный формат данных фото: $photoField');
    }
    return UserPhoto(
      id: map['Id'],
      userId: map['UserId'],
      photo: photoBase64,
    );
  }

  Map<String, dynamic> toMap({bool includeId = false}) {
    final map = <String, dynamic>{
      'UserId': userId,
      'Photo':  photo,
    };
    if(includeId && id != null){
      map['Id'] = id;
    }
    return map;
  }
  Uint8List get photoBytes => base64Decode(photo);
  static String base64Encode(Uint8List bytes) {
    return base64Encode(bytes);
  }
}