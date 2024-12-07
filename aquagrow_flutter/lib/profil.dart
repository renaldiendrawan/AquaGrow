import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'login.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  File? _imageFile;
  bool _isLoading = false;
  String? _imagePath; // Path foto profil yang tersimpan

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      usernameController.text = prefs.getString('username') ?? '';
      passwordController.text = prefs.getString('password') ?? '';
      _imagePath = prefs.getString('foto_profil'); // Memuat path foto profil
    });
  }

  Future<void> _saveProfileLocally(String username, String password, String? imagePath) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', username);
    await prefs.setString('password', password);
    if (imagePath != null) {
      await prefs.setString('foto_profil', imagePath);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green[900],
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            Text(
              'Profil',
              style: TextStyle(
                color: Colors.white,
                fontSize: screenWidth * 0.05,
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: screenHeight * 0.1),
              GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: screenWidth * 0.2,
                  backgroundColor: Colors.green[900],
                  backgroundImage: _imageFile != null
                      ? FileImage(_imageFile!)
                      : (_imagePath != null ? FileImage(File(_imagePath!)) : null), // Menampilkan foto dari path yang tersimpan
                  child: (_imageFile == null && _imagePath == null)
                      ? Icon(
                          Icons.person,
                          size: screenWidth * 0.25,
                          color: Colors.white,
                        )
                      : null,
                ),
              ),
              SizedBox(height: screenHeight * 0.03),
              TextFormField(
                controller: usernameController,
                decoration: InputDecoration(
                  labelText: 'Nama Pengguna',
                  labelStyle: TextStyle(color: Colors.grey),
                  hintText: 'Masukkan Nama Pengguna',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.green, width: 1.5),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.green, width: 1.5),
                  ),
                  contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                ),
              ),
              SizedBox(height: screenHeight * 0.03),
              TextFormField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Kata Sandi',
                  labelStyle: TextStyle(color: Colors.grey),
                  hintText: 'Masukkan Kata Sandi',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.green, width: 1.5),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.green, width: 1.5),
                  ),
                  contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                ),
              ),
              SizedBox(height: screenHeight * 0.04),
              _isLoading
                  ? CircularProgressIndicator()
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildActionButton(
                          context,
                          label: 'Simpan',
                          color: Colors.blue,
                          onPressed: () => _showConfirmationDialog(
                            context,
                            title: "Konfirmasi Simpan",
                            content: "Apakah Anda yakin ingin menyimpan perubahan?",
                            confirmLabel: "Simpan",
                            onConfirm: () {
                              _updateProfile(context);
                            },
                          ),
                        ),
                        _buildActionButton(
                          context,
                          label: 'Keluar',
                          color: Colors.red,
                          onPressed: () => _showConfirmationDialog(
                            context,
                            title: "Konfirmasi Keluar",
                            content: "Apakah Anda yakin ingin keluar?",
                            confirmLabel: "Keluar",
                            onConfirm: () {
                              Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(builder: (context) => LoginScreen()),
                                (Route<dynamic> route) => false,
                              );
                            },
                          ),
                        ),
                      ],
                    ),
              SizedBox(height: screenHeight * 0.1),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
        _imagePath = pickedFile.path; // Menyimpan path foto yang dipilih
      });
    }
  }

  Future<void> _updateProfile(BuildContext context) async {
    if (usernameController.text.isEmpty || passwordController.text.isEmpty) {
      _showErrorDialog(context, message: "Nama Pengguna dan Kata Sandi tidak boleh kosong");
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse("http://192.168.231.37/api/update_profile.php"),
      );
      request.fields['id_user'] = '1';
      request.fields['username'] = usernameController.text;
      request.fields['password'] = passwordController.text;

      if (_imageFile != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'foto_profil',
            _imageFile!.path,
          ),
        );
      }

      final response = await request.send();
      final responseData = await http.Response.fromStream(response);

      final data = json.decode(responseData.body);

      if (data['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Profil berhasil diperbarui!')),
        );

        // Simpan data profil secara lokal, termasuk foto
        await _saveProfileLocally(usernameController.text, passwordController.text, _imagePath);
      } else {
        _showErrorDialog(context, message: "Gagal memperbarui profil: ${data['message']}");
      }
    } catch (e) {
      _showErrorDialog(context, message: "Terjadi kesalahan: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showConfirmationDialog(BuildContext context,
      {required String title, required String content, required String confirmLabel, required VoidCallback onConfirm}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: <Widget>[
            TextButton(
              child: Text(confirmLabel),
              onPressed: () {
                Navigator.of(context).pop();
                onConfirm();
              },
            ),
            TextButton(
              child: Text("Batal"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showErrorDialog(BuildContext context, {required String message}) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Gagal"),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text("OK"),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildActionButton(BuildContext context, {required String label, required Color color, required VoidCallback onPressed}) {
    final screenWidth = MediaQuery.of(context).size.width;

    return SizedBox(
      width: screenWidth * 0.4,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          padding: EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: screenWidth * 0.05,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

void main() => runApp(MaterialApp(
      home: ProfileScreen(),
    ));
