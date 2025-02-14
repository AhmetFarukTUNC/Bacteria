import 'package:flutter/material.dart';
import 'dart:async';

import 'SplashScreen/SplashScreen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bakteri Tanımlama Projesi',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue), // Mavi tonları için güncellendi
        useMaterial3: true,
      ),
      home: SplashScreen(),
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




