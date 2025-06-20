import 'package:bakteri/Chatbot/chatbotpage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';
import '../AddPatientPage/AddPatientPage.dart';
import '../DatabaseOperations/DatabaseHelper.dart';
import 'dart:io';

import '../EditProfilePage/EditProfilePage.dart';
import '../Homepage/HomeScreen.dart';
import '../ProfilePage/ProfilePage.dart';
import '../provider.dart';

class PatientManagementPage extends StatefulWidget {
  final String? name;
  final String? surname;
  final String? specialization;
  final int? id;

  const PatientManagementPage({super.key, this.name, this.surname, this.specialization,this.id
  });

  @override
  _PatientManagementPageState createState() => _PatientManagementPageState();
}

class _PatientManagementPageState extends State<PatientManagementPage> {
  late Future<List<Map<String, dynamic>>> _patients;
  int _currentIndex = 0;
  int _userId = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      HomeScreen(name: widget.name, surname: widget.surname, specialization: widget.specialization),
      const AddPatientPage(),
      const PatientManagementPage(),
      const DoctorProfilePage(),
      ChatbotPage(userId: widget.id ?? 0),

      const EditProfilePage(),
      // Yeni Chatbot Sayfası
    ];
    _fetchUserId();

  }

  Future<void> _fetchUserId() async {

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final email = userProvider.email ?? '';
    final password = userProvider.password ?? '';

    if (email.isNotEmpty && password.isNotEmpty) {
      final userId = await DatabaseHelper.instance.getUserIdByEmailPassword(email, password);

      if (userId != null) {
        setState(() {
          _userId = userId;
          _patients = DatabaseHelper.instance.getPatientsByUserId(_userId);
        });
        print("User ID: $_userId");
      } else {
        print('User not found.');
      }
    } else {
      print('Email or Password is missing.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hasta Yönetimi'),
        backgroundColor: Colors.teal,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _patients,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Hata: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Henüz hasta bilgisi yok.'));
          }

          final patients = snapshot.data!;

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: patients.map((patient) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: ListTile(
                        title: Text(patient['name'], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        subtitle: Text('Hastalık: ${patient['disease']}'),
                        trailing: IconButton(
                          icon: const Icon(Icons.arrow_forward_ios),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PatientDetailPage(patient: patient)
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          );
        },
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
            icon: Icon(Icons.report, color: Colors.blueAccent),
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
        currentIndex: 2,
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.blueGrey,
        onTap: (index) {
          if (index == 0) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => HomeScreen(name: widget.name, surname: widget.surname, specialization: widget.specialization)),
            );
          }
          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AddPatientPage()),
            );
          }
          if (index == 3) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const DoctorProfilePage()),
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



class PatientDetailPage extends StatelessWidget {
  final Map<String, dynamic> patient;

  const PatientDetailPage({super.key, required this.patient});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(patient['name']),
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0), // Increased padding for better spacing
          child: Column(
            children: [
              const SizedBox(height: 40),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15), // Added some corner radius
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.shade300,
                      spreadRadius: 3,
                      blurRadius: 6,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Table(
                  columnWidths: {
                    0: FixedColumnWidth(150), // Adjusted width of labels
                  },
                  border: TableBorder.all(
                    color: Colors.white, // Set border color to teal
                    width: 2,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  children: [

                    _buildTableRow('Adı:', patient['name']),
                    _buildTableRow('Doğum Tarihi:', patient['dob']),
                    _buildTableRow('Hastalık:', patient['disease']),
                    _buildTableRow('Acil Durum Kişisi:', patient['emergency_contact']),
                    _buildTableRow('Telefon:', patient['emergency_phone']),
                    _buildTableRow('Adres:', patient['address']),
                    _buildTableRow('Cinsiyet:', patient['gender']),
                    _buildImageRow('BAKTERİ FOTOĞRAFI:', patient['image_path']),
                    _buildTableRow('Tahmin Sonucu:', patient['accuracy']),
                    _buildTableRow( 'Bakteri Türü:', patient['bacteria_type']),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Adjusted the padding and alignment for better spacing
  TableRow _buildTableRow(String label, String value) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0), // Increased padding for better spacing
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.indigo,
            ),
            textAlign: TextAlign.start, // Align label to the left
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.indigo,
            ),
            textAlign: TextAlign.start, // Align value to the left
          ),
        ),
      ],
    );
  }

  // Adjusted the image row with padding and alignment
  TableRow _buildImageRow(String label, String imagePath) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0), // Increased padding for better spacing
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.indigo,
            ),
            textAlign: TextAlign.start, // Align label to the left
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15.0),
            child: Image.file(
              File(imagePath),
              width: 250,
              height: 250,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(Icons.error, size: 100, color: Colors.grey);
              },
            ),
          ),
        ),
      ],
    );
  }
}

