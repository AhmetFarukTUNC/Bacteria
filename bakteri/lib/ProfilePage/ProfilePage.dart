import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider.dart';

class DoctorProfilePage extends StatelessWidget {
  const DoctorProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Accessing the userProvider instance
    final userProvider = Provider.of<UserProvider>(context);

    // Handle null checks for name, surname, and specialization
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
            // Doktorun profil resmi
            CircleAvatar(
              radius: 50,
              backgroundImage: AssetImage('assets/doctor_profile.jpg'), // Profil resmi
              backgroundColor: Colors.grey[300],
            ),
            const SizedBox(height: 16),

            // Doktorun adı, soyadı ve uzmanlık alanı
            Text(
              "$doctorSpecialization Doktoru $doctorName",
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.teal,
              ),
            ),
            const SizedBox(height: 8),

            // Uzmanlık alanı

            const SizedBox(height: 16),

            // Doktor bilgileri
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
                      leading: Icon(Icons.local_hospital, color: Colors.teal),
                      title: Text(style:TextStyle(fontSize: 24),'Uzmanlık Alanı'),
                      subtitle: Text(style:TextStyle(fontSize: 20,fontWeight: FontWeight.bold),userProvider.specialization ?? "Bilinmiyor"),
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.local_hospital, color: Colors.teal),
                      title: const Text(style:TextStyle(fontSize: 20,fontWeight: FontWeight.bold),'E-Mail'),
                      subtitle: Text(style:TextStyle(fontSize: 18,fontWeight: FontWeight.bold),userProvider.email ?? 'Bilinmiyor'),
                    ),
                    ListTile(
                      leading: Icon(Icons.phone, color: Colors.teal),
                      title: const Text(style:TextStyle(fontSize: 20,fontWeight: FontWeight.bold),'Telefon'),
                      subtitle: Text(style:TextStyle(fontSize: 18,fontWeight: FontWeight.bold),userProvider.phone ?? 'Bilinmiyor'), // null control
                    ),



                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Son tanımlamalar başlığı
            const Text(
              'Son Tanımlamalar',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.teal,
              ),
            ),
            const SizedBox(height: 8),

            // Son tanımlamalar listesi
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
            const SizedBox(height: 16),

            // Profil düzenleme düğmesi
            ElevatedButton.icon(
              onPressed: () {
                // Buraya profil düzenleme fonksiyonu eklenebilir
              },
              icon: const Icon(Icons.edit),
              label: const Text('Profili Düzenle'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
