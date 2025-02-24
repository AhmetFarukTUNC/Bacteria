import 'package:flutter/material.dart';

class UserProvider extends ChangeNotifier {
  String? name;
  String? surname;
  String? specialization;
  String? email;
  String? phone;
  String? password;

  void setUser(String newName, String newSurname, String newSpecialization, String newEmail, String newPhone,String newPassword) {
    name = newName;
    surname = newSurname;
    specialization = newSpecialization;
    email = newEmail;
    phone = newPhone;
    password = newPassword;
    notifyListeners(); // Değişiklikleri bildirmek için
  }
}
