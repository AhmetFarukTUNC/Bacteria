import 'package:bakteri/AddPatientPage/AddPatientPage.dart';
import 'package:bakteri/Homepage/HomeScreen.dart';
import 'package:bakteri/PatientManagementPage/PatientManagementPage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider.dart';

class DoctorProfilePage extends StatefulWidget {
  const DoctorProfilePage({super.key});

  @override
  _DoctorProfilePageState createState() => _DoctorProfilePageState();
}

class _DoctorProfilePageState extends State<DoctorProfilePage> {
  int _selectedIndex = 3;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );


        break;
      case 1:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => AddPatientPage()),
        );
        break;
      case 2:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => PatientManagementPage()),
        );

    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final doctorName = (userProvider.name?.isEmpty ?? true) ? 'Bilinmiyor' : '${userProvider.name} ${userProvider.surname}';
    final doctorSpecialization = (userProvider.specialization?.isEmpty ?? true) ? 'Uzmanlık Alanı Bilinmiyor' : userProvider.specialization;

    return Scaffold(
      appBar: AppBar(
        title: Text(doctorName),
        centerTitle: true,
        backgroundColor: Colors.teal,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage: AssetImage('assets/doctor_profile.jpg'),
              backgroundColor: Colors.grey[300],
            ),
            const SizedBox(height: 16),
            Text(
              "$doctorSpecialization Doktoru $doctorName",
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.teal,
              ),
            ),
            const SizedBox(height: 16),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Bilgiler',
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ListTile(
                      leading: Icon(Icons.security_outlined, color: Colors.teal),
                      title: Text('Uzmanlık Alanı', style: TextStyle(fontSize: 24)),
                      subtitle: Text(userProvider.specialization ?? "Bilinmiyor", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    ),
                    const Divider(),
                    ListTile(
                      leading: Icon(Icons.email, color: Colors.teal),
                      title: Text('E-Mail', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      subtitle: Text(userProvider.email ?? 'Bilinmiyor', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                    ListTile(
                      leading: Icon(Icons.phone, color: Colors.teal),
                      title: Text('Telefon', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      subtitle: Text(userProvider.phone ?? 'Bilinmiyor', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Son Tanımlamalar',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.teal,
              ),
            ),
            const SizedBox(height: 8),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 4,
              child: Column(
                children: const [
                  ListTile(
                    leading: Icon(Icons.bug_report, color: Colors.green),
                    title: Text('Escherichia coli'),
                    subtitle: Text('Tanımlama Tarihi: 15 Ocak 2025'),
                  ),
                  Divider(),
                  ListTile(
                    leading: Icon(Icons.bug_report, color: Colors.orange),
                    title: Text('Staphylococcus aureus'),
                    subtitle: Text('Tanımlama Tarihi: 10 Ocak 2025'),
                  ),
                  Divider(),
                  ListTile(
                    leading: Icon(Icons.bug_report, color: Colors.red),
                    title: Text('Pseudomonas aeruginosa'),
                    subtitle: Text('Tanımlama Tarihi: 5 Ocak 2025'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        type: BottomNavigationBarType.fixed,
        onTap: _onItemTapped,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.blueGrey,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Anasayfa',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_box_rounded),
            label: 'Hasta Ekle',
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