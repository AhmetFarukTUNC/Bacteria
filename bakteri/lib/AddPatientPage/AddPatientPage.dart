import 'dart:convert';
import 'dart:io';
import 'package:bakteri/Chatbot/chatbotpage.dart';
import 'package:bakteri/PatientManagementPage/PatientManagementPage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;



import '../Homepage/HomeScreen.dart';
import '../ProfilePage/ProfilePage.dart';
import '../provider.dart';

class AddPatientPage extends StatefulWidget {
  final int? id;
  const AddPatientPage({super.key,this.id});

  @override
  _AddPatientPageState createState() => _AddPatientPageState();
}

class _AddPatientPageState extends State<AddPatientPage> {
  final _formKey = GlobalKey<FormState>();
  XFile? _selectedImage;
  bool _isPredicted = false;
  int _currentIndex = 0;
  String _bacteriaType = '';
  String _confidence = '';

  String _predictionResult = "";

  @override
  void initState() {
    super.initState();

  }

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

      if(_isPredicted == true){

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
          'accuracy': _confidence,
          "bacteria_type":_bacteriaType
        },
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Hasta başarıyla kaydedildi!')),
      );
      Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => PatientManagementPage()));
      }

      else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tahmin işlemini lütfen tamamlayınız!')),
        );
      }

    }
  }

  Future<void> _uploadImage() async{
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = XFile(pickedFile!.path);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Resim seçilmedi!')),
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

  /// **📌 Görüntüyü Modele Gönderme**j


  Future<void> sendImageRequest() async {
    final Uri url = Uri.parse('http://192.168.1.102:5000/predict');

    // Resim dosyasını gönderin
    var request = http.MultipartRequest('POST', url)
      ..files.add(await http.MultipartFile.fromPath('file', _selectedImage!.path));  // "image" yerine "file"

    try {
      // HTTP isteğini gönder
      final response = await request.send();

      if (response.statusCode == 200) {
        // Yanıtı işleyin
        final responseData = await response.stream.bytesToString();
        final Map<String, dynamic> jsonResponse = json.decode(responseData);

        setState(() {
          // Gelen verileri UI'ye aktarın
          _bacteriaType = jsonResponse['predicted_class'] ?? 'Unknown';  // API'de "predicted_class" kullanılıyor
          _confidence = ((jsonResponse['max_probability'] ?? 0.0) * 100).toStringAsFixed(2) + '%';

        });

        print(_bacteriaType);
        print(_confidence);
      } else {
        print('Request failed with status: ${response.statusCode}');
      }
    } catch (error) {
      print('Error: $error');
    }
    _isPredicted = true;
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
    if(_bacteriaType == "0"){
      _bacteriaType = "Acineto";
    }
    if(_bacteriaType == "1"){
      _bacteriaType = "Ecoli";
    }
    if(_bacteriaType == "2"){
      _bacteriaType = "Enterobacter";
    }
    if(_bacteriaType == "3"){
      _bacteriaType = "K.Pneumoniae";
    }
    if(_bacteriaType == "4"){
      _bacteriaType = "Proteus";
    }
    if(_bacteriaType == "5"){
      _bacteriaType = "Ps.aeruginosa";
    }
    if(_bacteriaType == "6"){
      _bacteriaType = "Staph.aureus";
    }
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


// Diğer kodlar...anaconda

            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Adı Soyadı'),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z]')), // Sadece a-z ve A-Z harflerine izin ver
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Lütfen adı soyadı girin';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _dobController,
                decoration: const InputDecoration(labelText: 'Doğum Tarihi'),
                onTap: () => _selectDate(context),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Lütfen doğum tarihi girin';
                  }
                  return null;
                },
              ),

              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Hasta Telefonu'),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Lütfen hasta telefonu girin';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _diseaseController,
                decoration: const InputDecoration(labelText: 'Hastalık Bilgisi'),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z]')), // Sadece a-z ve A-Z harflerine izin ver
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Lütfen hastalık bilgisi girin';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _emergencyContactController,
                decoration: const InputDecoration(labelText: 'Acil Durum Kişisi'),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z]')), // Sadece a-z ve A-Z harflerine izin ver
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Lütfen acil durum kişisi girin';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _emergencyPhoneController,
                decoration: const InputDecoration(labelText: 'Acil Durum Telefonu'),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Lütfen acil durum telefonu girin';
                  }
                  return null;
                },
              ),
              TextFormField(controller: _addressController, decoration: const InputDecoration(labelText: 'Adres'),validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Lütfen hasta adresini girin';
                }
                return null;
              },),

              Row(
                children: [
                  const Text("Cinsiyet: "),
                  Radio(value: "Erkek", groupValue: _gender, onChanged: (value) => setState(() => _gender = value!)),
                  const Text("Erkek"),
                  Radio(value: "Kadın", groupValue: _gender, onChanged: (value) => setState(() => _gender = value!)),
                  const Text("Kadın"),
                  Text(_predictionResult)
                ],
              ),

              if (_selectedImage != null) Image.file(File(_selectedImage!.path), height: 150),
              Text(
                "Bakteri Türü: $_bacteriaType",
                style: TextStyle(
                  fontSize: 18, // Yazı boyutu
                  fontWeight: FontWeight.bold, // Kalın yazı
                  color: Colors.green, // Yazı rengi
                  letterSpacing: 1.2, // Harf aralığı
                  shadows: [
                    Shadow(
                      color: Colors.black26, // Hafif gölge
                      offset: Offset(1, 1),
                      blurRadius: 2,
                    ),
                  ],
                ),
                textAlign: TextAlign.center, // Metni ortala
              ),

              Text(
                "Tahmin Doğruluk Değeri: ${_confidence}",
                style: TextStyle(
                  fontSize: 18, // Yazı boyutu
                  fontWeight: FontWeight.bold, // Kalın yazı
                  color: Colors.red, // Mavi tonlarında renk
                  letterSpacing: 1.2, // Harf aralığı
                  shadows: [
                    Shadow(
                      color: Colors.black26, // Hafif gölge efekti
                      offset: Offset(1, 1),
                      blurRadius: 2,
                    ),
                  ],
                ),
                textAlign: TextAlign.center, // Ortalanmış metin
              ),

              ElevatedButton.icon(onPressed: _pickImage, icon: const Icon(Icons.camera_alt), label: const Text('Fotoğraf Çek')),
              ElevatedButton.icon(onPressed: _uploadImage, icon: const Icon(Icons.upload), label: const Text('Fotoğraf Yükle')),
              ElevatedButton.icon(onPressed: sendImageRequest, icon: const Icon(Icons.save), label: const Text('Tahmin Yap')),
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
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'Chatbot',
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
          if (index == 4) {
            setState(() {
              _currentIndex = index;
            });
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ChatbotPage(userId: widget.id ?? 0)),
            );
          }
        },
      ),
    );
  }
}