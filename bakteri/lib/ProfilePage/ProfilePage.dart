import 'package:flutter/material.dart';

class DoctorProfilePage extends StatelessWidget {
  const DoctorProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Doktor Profili'),
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

            // Doktorun adı
            const Text(
              'Dr. Ahmet Faruk Tunc',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.teal,
              ),
            ),
            const SizedBox(height: 8),

            // Uzmanlık alanı
            const Text(
              'Mikrobiyoloji ve Enfeksiyon Hastalıkları Uzmanı',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
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
                  children: const [
                    Text(
                      'Bilgiler',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    ListTile(
                      leading: Icon(Icons.local_hospital, color: Colors.teal),
                      title: Text('Hastane'),
                      subtitle: Text('İstanbul Eğitim ve Araştırma Hastanesi'),
                    ),
                    Divider(),
                    ListTile(
                      leading: Icon(Icons.phone, color: Colors.teal),
                      title: Text('Telefon'),
                      subtitle: Text('+90 532 456 78 90'),
                    ),
                    Divider(),
                    ListTile(
                      leading: Icon(Icons.email, color: Colors.teal),
                      title: Text('Email'),
                      subtitle: Text('dr.ahmetfaruk@example.com'),
                    ),
                    Divider(),
                    ListTile(
                      leading: Icon(Icons.business_center, color: Colors.teal),
                      title: Text('Deneyim'),
                      subtitle: Text('10+ yıl'),
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
