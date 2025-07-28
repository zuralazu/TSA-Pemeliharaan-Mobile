import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:tunassiakanugrah/auth/register_page.dart';
import 'package:tunassiakanugrah/utama/dasbor_halaman.dart';
import 'package:tunassiakanugrah/model/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
    });

    final String username = _usernameController.text.trim();
    final String password = _passwordController.text;

    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Username dan Password harus diisi')),
      );
      setState(() {
        _isLoading = false;
      });
      return;
    }

    final String apiUrl = 'http://10.0.2.2:8000/api/login-android';

    try {
      print('Mengirim permintaan Login ke: $apiUrl');

      final Map<String, String> requestBody = {
        'username': username,
        'password': password,
      };

      print('Body permintaan: ${jsonEncode(requestBody)}');

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      print('Status Code: ${response.statusCode}');
      print('Response Headers: ${response.headers}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        User user = User(
          id: responseData['user']['id'],
          username: responseData['user']['username'],
          email: responseData['user']['email'],
          role: responseData['user']['role'],
          accessToken: responseData['access_token'],
        );

        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_data', jsonEncode(user.toJson()));
        await prefs.setString('access_token', user.accessToken ?? '');

        // Simpan timestamp login saat ini
        await prefs.setInt('login_timestamp', DateTime.now().millisecondsSinceEpoch);
        print('✅ USER DATA DISIMPAN: ${jsonEncode(user.toJson())}');
        print('✅ TIMESTAMP DISIMPAN: ${DateTime.now().millisecondsSinceEpoch}');


        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(responseData['message'] ?? 'Login berhasil'),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => DasborHalaman()),
        );
      } else if (response.statusCode == 422) {
        final Map<String, dynamic> errorData = json.decode(response.body);
        String errorMessage = "Login gagal: ";

        if (errorData.containsKey('errors')) {
          errorData['errors'].forEach((key, value) {
            if (value is List && value.isNotEmpty) {
              errorMessage += "${value[0]} ";
            }
          });
        } else if (errorData.containsKey('message')) {
          errorMessage = errorData['message'];
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
          ),
        );
      } else if (response.statusCode == 302) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error 302: Kemungkinan masalah routing atau CSRF. Periksa konfigurasi server.'),
            backgroundColor: Colors.red,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Terjadi kesalahan: ${response.statusCode}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Terjadi error koneksi: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(25.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Selamat datang di APK Tracker',
              style: TextStyle(fontSize: 18, color: Colors.grey[700]),
            ),
            SizedBox(height: 5),
            Text(
              'Login',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 40),
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(
                hintText: 'Username',
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
              ),
              keyboardType: TextInputType.text,
            ),
            SizedBox(height: 20),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                hintText: 'Password',
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
              ),
              obscureText: true,
            ),
            SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Fitur Lupa password belum diimplementasikan.')),
                  );
                },
                child: Text(
                  'Lupa password?',
                  style: TextStyle(color: Colors.blueAccent),
                ),
              ),
            ),
            SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _login,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  padding: EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: _isLoading
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text(
                  'Login',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
            SizedBox(height: 20),
            Align(
              alignment: Alignment.center,
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => RegisterPage()),
                  );
                },
                child: Text.rich(
                  TextSpan(
                    text: 'belum punya akun? ',
                    style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                    children: [
                      TextSpan(
                        text: 'buat akun',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blueAccent,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
