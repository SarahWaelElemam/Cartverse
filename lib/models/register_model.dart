class RegisterModel {
  String? email;
  String? firstName;
  String? lastName;
  String? message; // Add message field for error responses

  RegisterModel({this.email, this.firstName, this.lastName, this.message});

  RegisterModel.fromJson(Map<String, dynamic> json) {
    email = json['email']?.toString();
    firstName = json['firstName']?.toString();
    lastName = json['lastName']?.toString();
    message = json['message']?.toString(); // Parse error messages
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['email'] = email;
    data['firstName'] = firstName;
    data['lastName'] = lastName;
    data['message'] = message;
    return data;
  }
}