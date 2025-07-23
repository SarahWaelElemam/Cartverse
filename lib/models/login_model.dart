class LoginModel {
  String? accessToken;
  User? user;

  LoginModel({this.accessToken, this.user});

  LoginModel.fromJson(Map<String, dynamic> json) {
    try {
      accessToken = json['accessToken']?.toString();
      user = json['user'] != null ? User.fromJson(json['user']) : null;
    } catch (e) {
      print('Error parsing LoginModel: $e');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['accessToken'] = accessToken;
    if (user != null) {
      data['user'] = user!.toJson();
    }
    return data;
  }
}

class User {
  String? email;
  String? firstName;
  String? lastName;
  int? id;

  User({this.email, this.firstName, this.lastName, this.id});

  User.fromJson(Map<String, dynamic> json) {
    try {
      email = json['email']?.toString();
      firstName = json['firstName']?.toString();
      lastName = json['lastName']?.toString();

      // Handle id field safely - could be int or string
      if (json['id'] != null) {
        if (json['id'] is int) {
          id = json['id'];
        } else if (json['id'] is String) {
          id = int.tryParse(json['id']);
        }
      }
    } catch (e) {
      print('Error parsing User: $e');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['email'] = email;
    data['firstName'] = firstName;
    data['lastName'] = lastName;
    data['id'] = id;
    return data;
  }
}
