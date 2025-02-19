import 'package:bakteri/provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'SplashScreen/SplashScreen.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => UserProvider(),
      child: MyApp(),
    ),

  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Bakteri Tanımlama Projesi',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: SplashScreen(), // SplashScreen yerine HomePage kullanıldı
    );
  }
}

// Bakteri Fotoğrafı Çekme Sayfası
class BacteriaPhotoPage extends StatelessWidget {
  const BacteriaPhotoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bakteri Fotoğrafı Çek ve Tanımla')),
      body: const Center(
        child: Text('Bakteri Fotoğrafı Çekme Sayfası'),
      ),
    );
  }
}
