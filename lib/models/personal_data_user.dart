
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
      id: map['Id'],
      name: map['Name'],
      gender: map['Gender'],
      birthDate: DateTime.parse(map['BirthDate']),
      userId: map['UserId'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'Id': id,
      'Name': name,
      'Gender': gender,
      'BirthDate': birthDate.toIso8601String(),
      'UserId': userId,
    };
  }
}