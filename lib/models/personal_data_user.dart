
class PersonalDataUser{
  final int id;
  final int userId;
  final String name;
  final String gender;
  final DateTime birthDate;

  PersonalDataUser({
    required this.id,
    required this.userId,
    required this.name,
    required this.gender,
    required this.birthDate
});

  factory PersonalDataUser.fromMap(Map<String, dynamic> map) {
    return PersonalDataUser(
      id: map['id'],
      name: map['name'],
      gender: map['gender'],
      birthDate: DateTime.parse(map['birthDate']),
      userId: map['userId'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'gender': gender,
      'birthDate': birthDate.toIso8601String(),
      'userId': userId,
    };
  }
}