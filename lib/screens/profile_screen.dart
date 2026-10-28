import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  final TextEditingController _favoriteController = TextEditingController();
  bool _isInit = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInit) {
      final provider = Provider.of<UserProvider>(context, listen: false);
      _nameController = TextEditingController(text: provider.user.name);
      _emailController = TextEditingController(text: provider.user.email);
      _isInit = false;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _favoriteController.dispose();
    super.dispose();
  }

  // --- LATIHAN 5: Validasi Keamanan Input Profil ---
  void _saveProfile() {
    // Jalankan validasi Form
    if (_formKey.currentState!.validate()) {
      final nameInput = _nameController.text.trim();
      final emailInput = _emailController.text.trim();

      // Validasi tambahan pencegahan karakter berbahaya / script injection sederhana
      if (nameInput.contains('<script>') || emailInput.contains('<script>')) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Peringatan Keamanan: Input mengandung karakter ilegal!'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final provider = context.read<UserProvider>();
      final updatedUser = provider.user.copyWith(
        name: nameInput,
        email: emailInput,
        isLoggedIn: true,
      );
      
      provider.updateUser(updatedUser);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profil berhasil divalidasi dan disimpan secara aman!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Apakah Anda yakin ingin logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<UserProvider>().logout();
              Navigator.pop(context);
            },
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<UserProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil & Keamanan'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: [
          if (provider.user.isLoggedIn)
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: _logout,
              tooltip: 'Logout',
            ),
        ],
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 16),
                      const CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.deepPurple,
                        child: Icon(
                          Icons.security,
                          size: 60,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      // Input Nama dengan Validasi Ketat
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Nama Lengkap',
                          prefixIcon: Icon(Icons.person),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Nama tidak boleh kosong';
                          }
                          if (value.trim().length < 3) {
                            return 'Nama minimal harus terdiri dari 3 karakter';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      // Input Email dengan Regex Validasi Aman
                      TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          labelText: 'Email Institusi / Pribadi',
                          prefixIcon: Icon(Icons.email),
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Email tidak boleh kosong';
                          }
                          // Regex standar validasi email
                          final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                          if (!emailRegex.hasMatch(value.trim())) {
                            return 'Format email tidak valid (contoh: nama@domain.com)';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      
                      ElevatedButton.icon(
                        onPressed: _saveProfile,
                        icon: const Icon(Icons.verified_user),
                        label: const Text('Simpan & Validasi Profil'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      const Text(
                        'Daftar Hobi / Item Favorit',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _favoriteController,
                              decoration: const InputDecoration(
                                hintText: 'Tambah hobi baru...',
                                border: OutlineInputBorder(),
                                isDense: true,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () {
                              // Validasi input kosong sebelum menambah hobi
                              if (_favoriteController.text.trim().isNotEmpty) {
                                provider.addFavorite(_favoriteController.text);
                                _favoriteController.clear();
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Item hobi tidak boleh kosong!'),
                                    backgroundColor: Colors.orange,
                                  ),
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepPurple,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Tambah'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      provider.favorites.isEmpty
                          ? const Text(
                              'Belum ada item favorit.',
                              style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
                            )
                          : ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: provider.favorites.length,
                              itemBuilder: (context, index) {
                                return Card(
                                  child: ListTile(
                                    leading: const Icon(Icons.star, color: Colors.amber),
                                    title: Text(provider.favorites[index]),
                                    trailing: IconButton(
                                      icon: const Icon(Icons.delete, color: Colors.red),
                                      onPressed: () {
                                        provider.removeFavorite(index);
                                      },
                                    ),
                                  ),
                                );
                              },
                            ),
                      const SizedBox(height: 16),
                      
                      // Card Informasi Keamanan SharedPreferences
                      Card(
                        color: Colors.amber[50],
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.security, color: Colors.amber[800]),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'Catatan Validasi & Keamanan (Latihan 5)',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                '• Validasi form memastikan input email & nama sesuai format.\n'
                                '• SharedPreferences menyimpan data secara lokal dalam plaintext.\n'
                                '• Untuk data sensitif tingkat lanjut, disarankan enkripsi tambahan.',
                                style: TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}