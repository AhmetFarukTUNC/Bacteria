import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import '../DatabaseOperations/DatabaseHelper.dart';
import 'dart:io';

class PatientManagementPage extends StatefulWidget {
  const PatientManagementPage({super.key});

  @override
  _PatientManagementPageState createState() => _PatientManagementPageState();
}

class _PatientManagementPageState extends State<PatientManagementPage> {
  late Future<List<Map<String, dynamic>>> _patients;
  int _selectedIndex = 0; // To track the selected tab

  @override
  void initState() {
    super.initState();
    _patients = DatabaseHelper.instance.getAllPatients();
  }

  // Handle Bottom Navigation Bar tab selection
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
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

          return Padding(
            padding: const EdgeInsets.all(0.0),
            child: DataTable(
              headingRowColor: MaterialStateColor.resolveWith((states) => Colors.teal),
              columns: const [
                DataColumn(
                  label: Center(child: Text('Hasta Adı', style: TextStyle(color: Colors.white))),
                ),
                DataColumn(
                  label: Center(child: Text('Hastalık', style: TextStyle(color: Colors.white))),
                ),
                DataColumn(
                  label: Center(child: Text('Detaylar', style: TextStyle(color: Colors.white))),
                ),
              ],
              rows: List.generate(
                patients.length,
                    (index) => DataRow(
                  cells: [
                    DataCell(
                      Center(
                        child: Text(
                          patients[index]['name'],
                          style: const TextStyle(color: Colors.teal),
                        ),
                      ),
                    ),
                    DataCell(
                      Center(
                        child: Text(
                          patients[index]['disease'],
                          style: const TextStyle(color: Colors.teal),
                        ),
                      ),
                    ),
                    DataCell(
                      Center(
                        child: IconButton(
                          icon: const Icon(Icons.arrow_forward_ios, color: Colors.teal),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PatientDetailPage(patient: patients[index]),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      // Bottom Navigation Bar
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Notifications',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.teal,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
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
