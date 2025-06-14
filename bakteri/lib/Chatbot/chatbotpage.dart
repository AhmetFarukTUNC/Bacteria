import 'dart:convert';
import 'package:bakteri/AddPatientPage/AddPatientPage.dart';
import 'package:bakteri/DatabaseOperations/DatabaseHelper.dart';
import 'package:bakteri/Homepage/HomeScreen.dart';
import 'package:bakteri/PatientManagementPage/PatientManagementPage.dart';
import 'package:bakteri/ProfilePage/ProfilePage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ChatbotPage extends StatefulWidget {
  final int userId;
  final int? id;
  const ChatbotPage({super.key,this.id,required this.userId});

  @override
  State<ChatbotPage> createState() => _ChatbotPageState();
}

class _ChatbotPageState extends State<ChatbotPage> {
  final TextEditingController _controller = TextEditingController();
  final TextEditingController _chatNameController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<String> _responses = [];
  bool _isLoading = false;
  List<Map<String, String>> _messages = [];
  int? _currentChatId;
  List<Map<String, dynamic>> _chats = [];

  @override
  void initState() {
    super.initState();
    _loadChats();

  }

  Future<void> _loadChats() async {
    final chats = await DatabaseHelper.instance.getAllChats(widget.userId);
    setState(() {
      _chats = chats.map((chat) => {
        'id': chat['id'] ?? 0,
        'name': (chat['baslik'] != null && chat['baslik'].toString().isNotEmpty)
            ? chat['baslik']
            : 'Adsız Sohbet',
      }).toList();
      print(chats);
    });
  }


  static const String apiKey = 'AIzaSyCxkttnOGepTgYPPgy9pVFHDbuB7Vlb-4k';
  int? selectedChatId;









  Future<void> _selectChat(int chatId) async {
    setState(() {
      _currentChatId = chatId;
      _messages.clear();
      _isLoading = true;
      selectedChatId = chatId;
      _loadChats();
    });

    final chatData = await DatabaseHelper.instance.getChatQuestionAndAnswer(chatId);

    if (chatData != null) {
      final soru = chatData['soru'];
      final cevap = chatData['cevap'];

      if (soru != null && soru.isNotEmpty) {
        _messages.add({'sender': 'user', 'text': soru});
      }
      if (cevap != null && cevap.isNotEmpty) {
        _messages.add({'sender': 'bot', 'text': cevap});
      }
    }

    setState(() {
      _isLoading = false;
    });

    await Future.delayed(const Duration(milliseconds: 300));
    _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
  }


  Future<void> _createNewChat() async {
    // Yeni sohbet başlığı oluştur
    int newIndex = _chats.length + 1;
    String newChatTitle = 'Yeni Sohbet $newIndex';

    // Veritabanına ekle
    int newChatId = await DatabaseHelper.instance.insertChat({
      'name': newChatTitle,
      'userId': widget.userId,

    });

    // Yeni sohbeti sohbete ekle
    setState(() {
      _chats.add({'id': newChatId, 'name': newChatTitle});
      _currentChatId = newChatId;
      _messages.clear();
    });
  }


  Future<void> getGeminiResponse(String prompt) async {
    const url = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=$apiKey';

    setState(() {
      _isLoading = true;
      _messages.add({'sender': 'user', 'text': prompt});
    });

    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'contents': [
          {
            'parts': [
              {'text': prompt}
            ]
          }
        ]
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final text = data['candidates'][0]['content']['parts'][0]['text'];

      setState(() {
        _messages.add({'sender': 'bot', 'text': text});
        _isLoading = false;
      });

      // ✅ Veritabanına soru ve cevap güncellemesi
      if (_currentChatId != null) {
        await DatabaseHelper.instance.updateChatWithFirstMessage(
          chatId: _currentChatId!,
          soru: prompt,
          cevap: text,
        );
      }

      await Future.delayed(const Duration(milliseconds: 300));
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    } else {
      setState(() {
        _messages.add({'sender': 'bot', 'text': 'Hata: ${response.body}'});
        _isLoading = false;
      });
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("🧠 AI Chatbot"),
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
        elevation: 6,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              child: Text(
                'Chatbot Menüsü',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              decoration: BoxDecoration(color: Colors.deepPurple),
            ),
            ListTile(
              title: const Text('Yeni Sohbet Başlat'),
              leading: const Icon(Icons.chat),
              onTap: () async {
                await _createNewChat(); // sohbeti oluştur
                Navigator.pop(context); // drawer'ı kapat
              },
            ),
            ListTile(
              title: const Text('Tüm Sohbeti Sil'),
              leading: const Icon(Icons.delete),
              onTap: () async {
                await DatabaseHelper.instance.deleteAllChatsForUser(widget.userId); // verileri sil
                await _loadChats(); // listeyi güncelle
                setState(() {
                  _messages.clear();
                  _currentChatId = null;
                  selectedChatId = null;
                });
                Navigator.pop(context); // drawer'ı kapat
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Tüm sohbetler silindi.")),
                );
              },
            ),

            ListTile(
              title: const Text('Sohbet İsmini Değiştir'),
              leading: const Icon(Icons.edit),
              onTap: () {
  Navigator.pop(context);
  if (_currentChatId != null) {
    showDialog(
      context: context,
      builder: (context) {
        final TextEditingController _renameController = TextEditingController();
        return AlertDialog(
          title: const Text("Sohbet İsmini Değiştir"),
          content: TextField(
            controller: _renameController,
            decoration: const InputDecoration(hintText: "Yeni sohbet ismini girin"),
          ),
          actions: [
            TextButton(
              child: const Text("İptal"),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text("Kaydet"),
              onPressed: () async {
                String newName = _renameController.text.trim();
                if (newName.isNotEmpty) {
                  await DatabaseHelper.instance.updateChatName(
                    chatId: _currentChatId!,
                    newName: newName,
                    userId: widget.userId,
                  );
                  await _loadChats(); // Sohbet listesini güncelle
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Sohbet ismi güncellendi.")),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Lütfen önce bir sohbet seçin.")),
    );
  }
},

            ),
            const Divider(),

            // ✅ Dinamik sohbet listesi, seçilen chat mavi olacak
            ..._chats.map((chat) {
              final chatId = chat['id'];
              return ListTile(
                title: Text(chat['name'] ?? 'Adsız Sohbet'),
                tileColor: selectedChatId == chatId ? Colors.blue.shade100 : null,
                onTap: () {
                  _selectChat(chatId); // sohbeti seç
                  Navigator.pop(context); // drawer'ı kapat
                },
              );
            }).toList(),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 16),
            Expanded(
              child: _messages.isEmpty && !_isLoading
                  ? const SizedBox.shrink()
                  : _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                controller: _scrollController,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: _messages.map((msg) {
                    bool isUser = msg['sender'] == 'user';
                    return Align(
                      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                        constraints: const BoxConstraints(maxWidth: 300),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: isUser
                                ? [Colors.blue[300]!, Colors.blue[500]!]
                                : [Colors.deepPurple[200]!, Colors.deepPurple[400]!],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(16),
                            topRight: const Radius.circular(16),
                            bottomLeft: Radius.circular(isUser ? 16 : 0),
                            bottomRight: Radius.circular(isUser ? 0 : 16),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(2, 4),
                            ),
                          ],
                        ),
                        child: Text(
                          msg['text']!,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            height: 1.4,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    style: const TextStyle(color: Colors.black87),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      hintText: "Mesajınızı yazın...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    if (_controller.text.isNotEmpty) {
                      getGeminiResponse(_controller.text);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    shape: const CircleBorder(),
                    backgroundColor: Colors.deepPurple,
                    padding: const EdgeInsets.all(14),
                  ),
                  child: const Icon(Icons.send, color: Colors.white),
                ),
              ],
            ),

          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
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
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'Chatbot',
          ),
        ],
        currentIndex: 4,
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.blueGrey,
        onTap: (index) {
          if (index == 0) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => HomeScreen()),
            );
          }
          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AddPatientPage()),
            );
          }
          if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const PatientManagementPage()),
            );
          }
          if (index == 3) {

            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => DoctorProfilePage()),
            );
          }
        },
      ),
    );
  }

}