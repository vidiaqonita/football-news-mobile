import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:football_news/screens/login.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';


class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // 1. GlobalKey untuk mengontrol form state
  final _formKey = GlobalKey<FormState>();
  
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              // 2. Bungkus semua field input dengan Form widget
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    const Text(
                      'Register',
                      style: TextStyle(
                        fontSize: 24.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 30.0),
                    TextFormField(
                      controller: _usernameController,
                      decoration: const InputDecoration(
                        labelText: 'Username',
                        hintText: 'Enter your username',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12.0)),
                        ),
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your username';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12.0),
                    TextFormField(
                      controller: _passwordController,
                      decoration: const InputDecoration(
                        labelText: 'Password',
                        hintText: 'Enter your password',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12.0)),
                        ),
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                      ),
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12.0),
                    TextFormField(
                      controller: _confirmPasswordController,
                      decoration: const InputDecoration(
                        labelText: 'Confirm Password',
                        hintText: 'Confirm your password',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12.0)),
                        ),
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                      ),
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please confirm your password';
                        }
                        // Pengecekan krusial: pastikan password cocok
                        if (value != _passwordController.text) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24.0),
                    ElevatedButton(
                      onPressed: () async {
                        // Hanya lanjutkan jika validasi form berhasil
                        if (_formKey.currentState!.validate()) {
                          String username = _usernameController.text;
                          String password1 = _passwordController.text;
                          String password2 = _confirmPasswordController.text;

                          try {
                            // Menggunakan BASE_URL yang diimpor dari login.dart
                            final response = await request.postJson(
                                "$BASE_URL/auth/register/", 
                                jsonEncode({
                                  "username": username,
                                  "password1": password1,
                                  "password2": password2,
                                }));
                            
                            if (context.mounted) {
                              // Cek apakah server mengirim status 'success'
                              if (response.containsKey('status') && response['status'] == 'success') {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Successfully registered!'),
                                  ),
                                );
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const LoginPage()),
                                );
                              } else {
                                // Tentukan pesan error yang robust:
                                String errorMessage = 'Registration Failed. Server did not return "success". ';
  
                                if (response.containsKey('message')) {
                                    errorMessage = response['message'];
                                } else if (response.containsKey('errors')) {
                                    var errors = response['errors'];
                                    errorMessage = (errors is List) ? errors.join('\n') : errors.toString();
                                } else {
                                    errorMessage += response.toString();
                                }
                                
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Gagal Registrasi: $errorMessage'),
                                    duration: const Duration(seconds: 5),
                                  ),
                                );
                              }
                            }
                          } catch (e) {
                             if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('KESALAHAN JARINGAN: Gagal menghubungi server atau memproses respons. Pastikan URL sudah benar dan server aktif. Error: $e'),
                                    duration: const Duration(seconds: 7),
                                  ),
                                );
                             }
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        minimumSize: Size(double.infinity, 50),
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                      ),
                      child: const Text('Register'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}