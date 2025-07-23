class RegisterModel {
  String? email;
  String? firstName;
  String? lastName;

  RegisterModel({this.email, this.firstName, this.lastName});

  RegisterModel.fromJson(Map<String, dynamic> json) {
    email = json['email'];
    firstName = json['firstName'];
    lastName = json['lastName'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['email'] = this.email;
    data['firstName'] = this.firstName;
    data['lastName'] = this.lastName;
    return data;
  }
}
