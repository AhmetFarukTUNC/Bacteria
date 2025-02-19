import 'package:flutter/material.dart';

class UserProvider extends ChangeNotifier {
  String? name;
  String? surname;
  String? specialization;
  String? email;
  String? phone;

  void setUser(String newName, String newSurname, String newSpecialization, String newEmail, String newPhone) {
    name = newName;
    surname = newSurname;
    specialization = newSpecialization;
    email = newEmail;
    phone = newPhone;
    notifyListeners(); // Değişiklikleri bildirmek için
  }
}
