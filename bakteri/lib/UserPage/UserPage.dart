import 'package:bakteri/AddPatientPage/AddPatientPage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../DatabaseOperations/DatabaseHelper.dart';
import '../Homepage/HomeScreen.dart';
import '../provider.dart';

class UserPage extends StatefulWidget {
  const UserPage({super.key});

  @override
  _UserPageState createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _surnameController = TextEditingController();
  final TextEditingController _specializationController = TextEditingController(); // Uzmanlık alanı
  final TextEditingController _phoneController = TextEditingController(); // Telefon numarası

  bool isLogin = true;

  Future<void> registerUser(String name, String surname, String email, String password, String specialization, String phone) async {
    final user = {
      'name': name,
      'surname': surname,
      'email': email,
      'password': password,
      'specialization': specialization, // Uzmanlık alanı
      'phone': phone, // Telefon numarası
    };

    await DatabaseHelper.instance.insertUser(user);
    print("Kayıt Başarılı!");
  }

  Future<void> loginUser(String email, String password) async {
    // Veritabanında kullanıcıyı sorgulama
    final user = await DatabaseHelper.instance.getUserByEmailAndPassword(email, password);

    if (user != null) {

      // Kullanıcı bilgilerini UserProvider'a gönderme
      Provider.of<UserProvider>(context, listen: false).setUser(
        user['name'],
        user['surname'],
        user['specialization'],
        user['email'],
        user['phone'],);
      // Giriş başarılı
      print("Giriş Başarılı!");

      // Kullanıcı bilgilerini HomeScreen'e gönderme
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomeScreen(
            name: user['name'],
            surname: user['surname'],
            specialization: user['specialization'],

          ),
        ),
      );


    } else {
      // Hatalı giriş
      print("Hatalı e-posta veya şifre");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Hatalı e-posta veya şifre')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isLogin ? 'Oturum Aç' : 'Kaydol'),
        backgroundColor: isLogin ? Colors.blue : Colors.green,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  if (isLogin)
                    Icon(
                      Icons.lock,
                      size: 100,
                      color: Colors.blue,
                    ),
                  const SizedBox(height: 20),
                  if (!isLogin)
                    Icon(
                      Icons.person_add,
                      size: 100,
                      color: Colors.green,
                    ),
                  const SizedBox(height: 20),
                  if (!isLogin)
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Ad',
                        prefixIcon: Icon(Icons.person),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Lütfen adınızı girin';
                        }
                        return null;
                      },
                    ),
                  const SizedBox(height: 20),
                  if (!isLogin)
                    TextFormField(
                      controller: _surnameController,
                      decoration: const InputDecoration(
                        labelText: 'Soyad',
                        prefixIcon: Icon(Icons.person_outline),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Lütfen soyadınızı girin';
                        }
                        return null;
                      },
                    ),
                  const SizedBox(height: 20),
                  if (!isLogin)
                    TextFormField(
                      controller: _specializationController, // Uzmanlık alanı
                      decoration: const InputDecoration(
                        labelText: 'Uzmanlık Alanı',
                        prefixIcon: Icon(Icons.medical_services),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Lütfen uzmanlık alanını girin';
                        }
                        return null;
                      },
                    ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'E-posta',
                      prefixIcon: Icon(Icons.email),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Lütfen e-posta adresinizi girin';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _passwordController,
                    decoration: const InputDecoration(
                      labelText: 'Şifre',
                      prefixIcon: Icon(Icons.lock),
                      border: OutlineInputBorder(),
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Lütfen şifrenizi girin';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  if (!isLogin)
                    TextFormField(
                      controller: _phoneController, // Telefon numarası
                      decoration: const InputDecoration(
                        labelText: 'Telefon Numarası',
                        prefixIcon: Icon(Icons.phone),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Lütfen telefon numaranızı girin';
                        }
                        return null;
                      },
                    ),
                  const SizedBox(height: 40),
                  ElevatedButton(
                    onPressed: () {
                      Provider.of<UserProvider>(context, listen: false).setUser(
                        _nameController.text,
                          _surnameController.text,
                        _specializationController.text,
                        _emailController.text,
                      _phoneController.text);

                      if (_formKey.currentState?.validate() ?? false) {
                        String name = _nameController.text;
                        String surname = _surnameController.text;
                        String email = _emailController.text;
                        String password = _passwordController.text;
                        String specialization = _specializationController.text;
                        String phone = _phoneController.text;

                        if (!isLogin) {
                          registerUser(name, surname, email, password, specialization, phone);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Kayıt başarılı'),
                            ),
                          );
                          setState(() {
                            isLogin = true;
                          });
                        } else {
                          loginUser(email, password);
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: isLogin ? Colors.blue : Colors.green,
                      padding: EdgeInsets.symmetric(horizontal: 60, vertical: 18),
                    ),
                    child: Text(isLogin ? 'Giriş Yap' : 'Kaydol'),
                  ),
                  const SizedBox(height: 20),
                  if (isLogin)
                    TextButton(
                      onPressed: () {
                        setState(() {
                          isLogin = false;
                        });
                      },
                      child: Text(
                        'Hesabınız yok mu? Kaydolun',
                        style: TextStyle(
                          color: Colors.blue,
                          fontSize: 16,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}