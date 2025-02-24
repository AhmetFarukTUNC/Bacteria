import 'dart:io';
import 'package:bakteri/PatientManagementPage/PatientManagementPage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;

import '../Homepage/HomeScreen.dart';
import '../ProfilePage/ProfilePage.dart';
import '../provider.dart';

class AddPatientPage extends StatefulWidget {
  const AddPatientPage({super.key});

  @override
  _AddPatientPageState createState() => _AddPatientPageState();
}

class _AddPatientPageState extends State<AddPatientPage> {
  final _formKey = GlobalKey<FormState>();
  XFile? _selectedImage;
  bool _isPredicted = false;
  int _currentIndex = 0;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _diseaseController = TextEditingController();
  final TextEditingController _emergencyContactController = TextEditingController();
  final TextEditingController _emergencyPhoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  String _gender = "Erkek";

  Future<Database> _initializeDatabase() async {
    String path = p.join(await getDatabasesPath(), 'user_db.db');
    return openDatabase(
      path,
      onCreate: (db, version) {
        return db.execute(
          "CREATE TABLE IF NOT EXISTS patients (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, dob TEXT, phone TEXT, disease TEXT, emergency_contact TEXT, emergency_phone TEXT, address TEXT, gender TEXT, image_path TEXT)",
        );
      },
      version: 1,
    );
  }

  Future<void> _savePatient() async {
    if (_selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen fotoğraf çekin!')),
      );
      return;
    }

    if (!_isPredicted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Fotoğraf tahmin edilmeden kaydedemezsiniz!')),
      );
      return;
    }

    if (_formKey.currentState!.validate()) {
      final db = await _initializeDatabase();

      // Kullanıcı sağlayıcısından email ve password al
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final String? email = userProvider.email;
      final String? password = userProvider.password;

      // Kullanıcının ID'sini users tablosundan bul
      List<Map<String, dynamic>> userResult = await db.query(
        'users',
        columns: ['id'],
        where: 'email = ? AND password = ?',
        whereArgs: [email, password],
      );

      if (userResult.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Kullanıcı bulunamadı!')),
        );
        return;
      }

      int userId = userResult.first['id'];

      // Veritabanında aynı isim ve telefon numarası olan bir hasta var mı kontrol et
      List<Map<String, dynamic>> existingPatients = await db.query(
        'patients',
        where: 'name = ? OR phone = ? OR emergency_phone = ?',
        whereArgs: [_nameController.text, _phoneController.text, _emergencyPhoneController.text],
      );

      if (existingPatients.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bu hasta zaten kayıtlı!')),
        );
        return;
      }

      // Hastayı veritabanına kaydet
      await db.insert(
        'patients',
        {
          'user_id': userId, // Bulunan user_id'yi kaydet
          'name': _nameController.text,
          'dob': _dobController.text,
          'phone': _phoneController.text,
          'disease': _diseaseController.text,
          'emergency_contact': _emergencyContactController.text,
          'emergency_phone': _emergencyPhoneController.text,
          'address': _addressController.text,
          'gender': _gender,
          'image_path': _selectedImage!.path,
        },
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Hasta başarıyla kaydedildi!')),
      );
    }
  }



  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      setState(() {
        _selectedImage = image;
        _isPredicted = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Fotoğraf başarıyla çekildi!')),
      );
    }
  }

  void _predictImage() {
    if (_selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bakteri tanımlama işlemi için bir fotoğraf çekmelisiniz')),
      );
      return;
    }
    setState(() {
      _isPredicted = true;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Fotoğraf tahmin edildi!')),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      setState(() {
        _dobController.text = DateFormat('dd.MM.yyyy').format(pickedDate);
      });
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hasta Ekleme Paneli'),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: ListView(


// Diğer kodlar...

            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Adı Soyadı'),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z]')), // Sadece a-z ve A-Z harflerine izin ver
                ],
              ),
              TextFormField(
                controller: _dobController,
                decoration: const InputDecoration(labelText: 'Doğum Tarihi'),
                onTap: () => _selectDate(context),
              ),

              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Hasta Telefonu'),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
              TextFormField(
                controller: _diseaseController,
                decoration: const InputDecoration(labelText: 'Hastalık Bilgisi'),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z]')), // Sadece a-z ve A-Z harflerine izin ver
                ],
              ),
              TextFormField(
                controller: _emergencyContactController,
                decoration: const InputDecoration(labelText: 'Acil Durum Kişisi'),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z]')), // Sadece a-z ve A-Z harflerine izin ver
                ],
              ),
              TextFormField(
                controller: _emergencyPhoneController,
                decoration: const InputDecoration(labelText: 'Acil Durum Telefonu'),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
              TextFormField(controller: _addressController, decoration: const InputDecoration(labelText: 'Adres')),
              Row(
                children: [
                  const Text("Cinsiyet: "),
                  Radio(value: "Erkek", groupValue: _gender, onChanged: (value) => setState(() => _gender = value!)),
                  const Text("Erkek"),
                  Radio(value: "Kadın", groupValue: _gender, onChanged: (value) => setState(() => _gender = value!)),
                  const Text("Kadın"),
                ],
              ),
              if (_selectedImage != null) Image.file(File(_selectedImage!.path), height: 150),
              ElevatedButton.icon(onPressed: _pickImage, icon: const Icon(Icons.camera_alt), label: const Text('Fotoğraf Çek')),
              ElevatedButton.icon(onPressed: _savePatient, icon: const Icon(Icons.save), label: const Text('Kaydet')),
            ],

          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Anasayfa',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_box_rounded),
            label: 'Hasta Ekle',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.report), // Hasta Yönetimi her zaman mavi
            label: 'Hasta Yönetimi',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.supervised_user_circle),
            label: 'Profil',
          ),
        ],
        currentIndex: 1,
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.blueGrey,
        onTap: (index) {
          if (index == 0) {
            setState(() {
              _currentIndex = index;
            });
            Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => HomeScreen()));
            _currentIndex =1;
          }
          if (index == 2) {
            setState(() {
              _currentIndex = index;
            });
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => PatientManagementPage()),
            );
            _currentIndex =1;
          }

          if (index == 3) {
            setState(() {
              _currentIndex = index;
            });
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => DoctorProfilePage()),
            );
          }
        },
      ),
    );
  }
}