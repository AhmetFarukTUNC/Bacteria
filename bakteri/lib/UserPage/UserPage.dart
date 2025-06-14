import 'package:bakteri/AddPatientPage/AddPatientPage.dart';
import 'package:bakteri/Chatbot/chatbotpage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
    final existingUser = await DatabaseHelper.instance.getUserByEmail(email);

    if (existingUser != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bu e-posta adresi zaten kayıtlı!')),
      );
      return;
    }

    final user = {
      'name': name,
      'surname': surname,
      'email': email,
      'password': password,
      'specialization': specialization,
      'phone': phone,
    };

    await DatabaseHelper.instance.insertUser(user);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Kayıt başarılı')),
    );
    setState(() {
      isLogin = true;
    });
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Lütfen bir e-posta girin';
    }

    // Geçerli bir e-posta formatı kontrolü
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');

    if (!emailRegex.hasMatch(value)) {
      return 'Geçerli bir e-posta adresi girin';
    }
    return null; // Geçerliyse hata mesajı dönmez
  }

  Future<void> loginUser(String email, String password) async {
    final user = await DatabaseHelper.instance.getUserByEmailAndPassword(email, password);

    if (user != null) {
      Provider.of<UserProvider>(context, listen: false).setUser(
        user['name'],
        user['surname'],
        user['specialization'],
        user['email'],
        user['phone'],
        user["password"]
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomeScreen(
            id: user["id"],
            name: user['name'],
            surname: user['surname'],
            specialization: user['specialization'],


          ),
        ),

      );

    }


    else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Hatalı e-posta veya şifre')),
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
                  Icon(
                    isLogin ? Icons.lock : Icons.person_add,
                    size: 100,
                    color: isLogin ? Colors.blue : Colors.green,
                  ),
                  const SizedBox(height: 20),
                  if (!isLogin) ...[
                    _buildTextField(_nameController, 'Ad', Icons.person),
                    const SizedBox(height: 20),
                    _buildTextField(_surnameController, 'Soyad', Icons.person_outline),
                    const SizedBox(height: 20),
                    _buildTextField(_specializationController, 'Uzmanlık Alanı', Icons.medical_services),
                    const SizedBox(height: 20),
                  ],
        TextFormField(
        controller: _emailController,
        decoration: InputDecoration(
        labelText: 'E-Posta',
        prefixIcon: Icon(Icons.email),
        border: OutlineInputBorder(),
      ),
      keyboardType: TextInputType.emailAddress,
      validator: _validateEmail,
    ),
                  const SizedBox(height: 20),
                  _buildTextField(_passwordController, 'Şifre', Icons.lock, obscureText: true),
                  const SizedBox(height: 20),
                  if (!isLogin)
                    TextFormField(
                      controller: _phoneController,
                      decoration: const InputDecoration(
                        labelText: 'Hasta Telefonu',
                        prefixIcon: Icon(Icons.phone), // Telefon ikonu eklendi
                        border: OutlineInputBorder(), // Kenarlık ekleyerek daha belirgin hale getirdik
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Lütfen hasta telefonu girin';
                        }
                        return null;
                      },
                    ),

                  const SizedBox(height: 40),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState?.validate() ?? false) {
                        final name = _nameController.text;
                        final surname = _surnameController.text;
                        final email = _emailController.text;
                        final password = _passwordController.text;
                        final specialization = _specializationController.text;
                        final phone = _phoneController.text;

                        if (!isLogin) {
                          registerUser(name, surname, email, password, specialization, phone);
                        } else {
                          loginUser(email, password);
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: isLogin ? Colors.blue : Colors.green,
                      padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 18),
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
                      child: const Text(
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

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {bool obscureText = false}) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: const OutlineInputBorder(),
      ),
      obscureText: obscureText,
      validator: (value) => value == null || value.isEmpty ? 'Lütfen $label girin' : null,
    );
  }
}
