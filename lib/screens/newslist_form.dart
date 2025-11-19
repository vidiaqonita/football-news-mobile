import 'package:flutter/material.dart';
import 'package:football_news/screens/login.dart';
import 'package:football_news/widgets/left_drawer.dart';
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:football_news/screens/menu.dart';

class NewsFormPage extends StatefulWidget {
    const NewsFormPage({super.key});

    @override
    State<NewsFormPage> createState() => NewsFormPageState();
}

class NewsFormPageState extends State<NewsFormPage> {
    final _formKey = GlobalKey<FormState>();
    String _title = "";
    String _content = "";
    String _category = "update"; // default
    String _thumbnail = "";
    bool _isFeatured = false; // default

    final List<String> _categories = [
      'transfer',
      'update',
      'exclusive',
      'match',
      'rumor',
      'analysis',
    ];
    
    @override
    Widget build(BuildContext context) {
        final request = context.watch<CookieRequest>();
        return Scaffold(
          appBar: AppBar(
            title: const Center(
              child: Text(
                'Add News Form',
              ),
            ),
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
          ),
          drawer: LeftDrawer(),
          body: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children:[
                  // === Title ===
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextFormField(
                      decoration: InputDecoration(
                        hintText: "Judul",
                        labelText: "Judul",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5.0),
                          borderSide: BorderSide(
                            color: Colors.blue, 
                          ),
                        ),
                      ),
                      onChanged: (String? value) {
                        setState(() {
                          _title = value!;
                        });
                      },
                      validator: (String? value) {
                        if (value == null || value.isEmpty) {
                          return "Judul tidak boleh kosong!";
                        }
                        return null;
                      },
                    ),
                  ),

                  // === Content ===
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextFormField(
                      maxLines: 5,
                      decoration: InputDecoration(
                        hintText: "Isi Berita",
                        labelText: "Isi Berita",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5.0),
                          borderSide: BorderSide(
                            color: Colors.blue, 
                          ),
                        ),
                      ),
                      onChanged: (String? value) {
                        setState(() {
                          _content = value!;
                        });
                      },
                      validator: (String? value) {
                        if (value == null || value.isEmpty) {
                          return "Isi Berita produk tidak boleh kosong!";
                        }
                        return null;
                      },
                    ),
                  ),

                  // === Category ===
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: "Kategori",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5.0),
                          borderSide: BorderSide(
                            color: Colors.blue, 
                          ),
                        ),
                      ),
                      // Pastikan nilai default _category sudah diatur ('new')
                      initialValue: _category.trim(), 
                      items: _categories
                          .map((cat) => DropdownMenuItem(
                                value: cat,
                                child: Text(
                                    cat[0].toUpperCase() + cat.substring(1)),
                              ))
                          .toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _category = newValue!;
                        });
                      },
                    ),
                  ),

                  // === Thumbnail URL ===
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextFormField(
                      decoration: InputDecoration(
                        hintText: "URL Thumbnail (opsional)",
                        labelText: "URL Thumbnail",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5.0),
                          borderSide: BorderSide(
                            color: Colors.blue, 
                          ),
                        ),
                      ),
                      onChanged: (String? value) {
                        setState(() {
                          _thumbnail = value!;
                        });
                      },
                    ),
                  ),

                  // === Is Featured ===
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SwitchListTile(
                      title: const Text("Tandai sebagai Berita Unggulan"),
                      value: _isFeatured,
                      onChanged: (bool value) {
                        setState(() {
                          _isFeatured = value;
                        });
                      },
                    ),
                  ),
                  // === Tombol Simpan ===
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor:
                              WidgetStateProperty.all(Colors.blue),
                        ),
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            
                            // *** PERUBAHAN KRITIS ADA DI SINI ***
                            // Menggunakan request.post dan mengirim data JSON
                            // Django harus merespons dengan JSON (lihat main/views.py yang sudah diperbaiki)
                            
                            final response = await request.post(
                              // Menggunakan full URL tanpa BASE_URL karena sudah diatur di main.dart
                              "$BASE_URL/create-flutter/",
                              // Body harus dalam format Map<String, dynamic> untuk request.post,
                              // KARENA API Anda di Django membaca JSON dari request.body.
                              // Menggunakan jsonEncode() adalah cara yang benar, dan pbp_django_auth 
                              // akan mengatur header Content-Type: application/json secara otomatis.
                              jsonEncode({
                                "title": _title,
                                "content": _content,
                                "thumbnail": _thumbnail,
                                "category": _category,
                                "is_featured": _isFeatured,
                              }),
                            );
                            
                            if (context.mounted) {
                              // Cek apakah ada 'status' di respons (yaitu respons JSON dari Django)
                              if (response.containsKey('status') && response['status'] == 'success') {
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(const SnackBar(
                                  content: Text("News successfully saved!"),
                                ));
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => MyHomePage()),
                                );
                              } else {
                                // Tangani error 401 atau 500 JSON di sini
                                String errorMessage = response.containsKey('message') 
                                    ? response['message'] 
                                    : "Failed to save news. Please check your authentication or server logs.";

                                ScaffoldMessenger.of(context)
                                    .showSnackBar(SnackBar(
                                  content: Text(errorMessage),
                                  backgroundColor: Colors.red.shade700,
                                ));
                              }
                            }
                          }
                        },
                        child: const Text(
                          "Save",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ],
              )
            ),
          ),
        );
    }
}