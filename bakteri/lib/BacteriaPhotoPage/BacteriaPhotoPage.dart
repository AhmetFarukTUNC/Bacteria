// Bakteri Fotoğrafı Çekme Sayfası
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

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