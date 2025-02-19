import 'package:bakteri/EditProfilePage/EditProfilePage.dart';
import 'package:bakteri/ProfilePage/ProfilePage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../AddPatientPage/AddPatientPage.dart';
import '../PatientManagementPage/PatientManagementPage.dart';
import '../provider.dart';

class HomeScreen extends StatefulWidget {
  final String? name;
  final String? surname;
  final String? specialization;

  const HomeScreen({super.key, this.name, this.surname, this.specialization});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      HomeScreen(name: widget.name, surname: widget.surname, specialization: widget.specialization),
      const AddPatientPage(),
      const PatientManagementPage(),
      const DoctorProfilePage(),
      const EditProfilePage(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Anasayfa'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              margin: const EdgeInsets.only(bottom: 6.0),
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  'Hoş Geldiniz, ${userProvider.specialization} Doktoru ${userProvider.name} ${userProvider.surname}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 150,
                      height: 150,
                      child: ElevatedButton(
                        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AddPatientPage())),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          padding: const EdgeInsets.all(16),
                        ),
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_box_rounded, size: 36, color: Colors.white),
                            SizedBox(height: 8),
                            Text('Hasta Ekleme Paneli', textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: Colors.white)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: 150,
                      height: 150,
                      child: ElevatedButton(
                        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const PatientManagementPage())),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          padding: const EdgeInsets.all(16),
                        ),
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.person_2_sharp, size: 36, color: Colors.white),
                            SizedBox(height: 8),
                            Text('Hasta Yönetimi', textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: Colors.white)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,  // Always keep "Hasta Ekle" selected
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          // Disable navigation to the "Hasta Ekle" page
          if (index != 0) {
            setState(() {
              _currentIndex = index; // Update selected index
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