import 'dart:io';
import 'package:bakteri/Homepage/HomeScreen.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../DatabaseOperations/DatabaseHelper.dart';
import '../EditProfilePage/EditProfilePage.dart';
import '../PatientManagementPage/PatientManagementPage.dart';
import '../ProfilePage/ProfilePage.dart';

class AddPatientPage extends StatefulWidget {
  final String? name;
  final String? surname;
  final String? specialization;

  const AddPatientPage({super.key, this.name, this.surname, this.specialization});


  @override
  _AddPatientPageState createState() => _AddPatientPageState();
}

class _AddPatientPageState extends State<AddPatientPage> {
  final _formKey = GlobalKey<FormState>();
  XFile? _selectedImage;
  bool _isPredicted = false;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _diseaseController = TextEditingController();
  final TextEditingController _emergencyContactController = TextEditingController();
  final TextEditingController _emergencyPhoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  String _gender = "Erkek";

  int _selectedIndex = 0; // BottomNavigationBar seçilen index
  late final List<Widget> _pages;

  @override
  void initState() {

    super.initState();
    _pages = [
      const HomeScreen(),
      AddPatientPage(name: widget.name,surname: widget.surname,specialization: widget.specialization,),
      const PatientManagementPage(),
      const DoctorProfilePage(),
      const EditProfilePage(),
    ];
  } // Sayfa controller'ı

  /// 📷 **Fotoğraf Çekme Fonksiyonu**
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedImage = await picker.pickImage(source: ImageSource.camera);

    if (pickedImage != null) {
      setState(() {
        _selectedImage = pickedImage;
        _isPredicted = false; // Yeni resim çekildiğinde tahmin sıfırlanmalı
      });
    }
  }

  /// 🧠 **Tahmin İşlemi Fonksiyonu**
  void _predictImage() {
    if (_selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen önce bir fotoğraf çekin!')),
      );
      return;
    }

    setState(() {
      _isPredicted = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Tahmin işlemi tamamlandı!')),
    );
  }

  /// 💾 **Hasta Kaydetme Fonksiyonu**
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
      await DatabaseHelper.instance.insertPatient({
        'name': _nameController.text,
        'dob': _dobController.text,
        'phone': _phoneController.text,
        'disease': _diseaseController.text,
        'emergency_contact': _emergencyContactController.text,
        'emergency_phone': _emergencyPhoneController.text,
        'address': _addressController.text,
        'gender': _gender,
        'image_path': _selectedImage!.path,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Hasta başarıyla kaydedildi!')),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => PatientManagementPage(),),
      );
    }
  }

  /// 🛠 **Girdi Kontrolü**
  String? _validateInput(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName boş bırakılamaz!';
    }
    return null;
  }

  /// 🎨 **Ekran Arayüzü**
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
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Adı Soyadı'),
                validator: (value) => _validateInput(value, 'Adı Soyadı'),
              ),
              TextFormField(
                controller: _dobController,
                decoration: const InputDecoration(labelText: 'Doğum Tarihi'),
                readOnly: true,
                onTap: () async {
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
                },
                validator: (value) => _validateInput(value, 'Doğum Tarihi'),
              ),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Telefon Numarası'),
                validator: (value) => _validateInput(value, 'Telefon Numarası'),
              ),
              TextFormField(
                controller: _diseaseController,
                decoration: const InputDecoration(labelText: 'Hastalık Bilgisi'),
                validator: (value) => _validateInput(value, 'Hastalık Bilgisi'),
              ),
              TextFormField(
                controller: _emergencyContactController,
                decoration: const InputDecoration(labelText: 'Acil Durum Kişisi'),
                validator: (value) => _validateInput(value, 'Acil Durum Kişisi'),
              ),
              TextFormField(
                controller: _emergencyPhoneController,
                decoration: const InputDecoration(labelText: 'Acil Durum Telefonu'),
                validator: (value) => _validateInput(value, 'Acil Durum Telefonu'),
              ),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(labelText: 'Adres'),
                validator: (value) => _validateInput(value, 'Adres'),
              ),
              Row(
                children: [
                  const Text("Cinsiyet: "),
                  Radio(value: "Erkek", groupValue: _gender, onChanged: (value) => setState(() => _gender = value!)),
                  const Text("Erkek"),
                  Radio(value: "Kadın", groupValue: _gender, onChanged: (value) => setState(() => _gender = value!)),
                  const Text("Kadın"),
                ],
              ),
              if (_selectedImage != null)
                Image.file(File(_selectedImage!.path), height: 150),
              ElevatedButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.camera_alt),
                label: const Text('Fotoğraf Çek'),
              ),
              ElevatedButton.icon(
                onPressed: _predictImage,
                icon: const Icon(Icons.image_search),
                label: const Text('Tahmin Et'),
              ),
              ElevatedButton.icon(
                onPressed: _savePatient,
                icon: const Icon(Icons.save),
                label: const Text('Kaydet'),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,  // Always keep "Hasta Ekle" selected
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          // Disable navigation to the "Hasta Ekle" page
          if (index != 1) {
            setState(() {
              _selectedIndex = index; // Update selected index
            });
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => _pages[index]),
            );
          }
        },
        selectedItemColor: Colors.blue, // Selected tab color
        unselectedItemColor: Colors.blueGrey, // Unselected tab color
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Anasayfa',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_box_rounded),
            label: 'Hasta Ekle',
            backgroundColor: Colors.blue, // Keep "Hasta Ekle" always highlighted
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.report),
            label: 'Hasta Yönetimi',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.supervised_user_circle),
            label: 'Profil',
          ),
        ],
      ),


    );
  }
}
