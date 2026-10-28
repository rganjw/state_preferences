import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';

class UserProvider extends ChangeNotifier {
  User _user = User(name: '', email: '');
  bool _isLoading = true;
  bool _isDarkMode = false;
  int _visitCount = 0;
  List<String> _favorites = [];

  User get user => _user;
  bool get isLoading => _isLoading;
  bool get isDarkMode => _isDarkMode;
  int get visitCount => _visitCount;
  List<String> get favorites => _favorites;

  UserProvider() {
    _loadAllData();
  }

  // Memuat seluruh data dari SharedPreferences saat inisialisasi
  Future<void> _loadAllData() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString('user_name') ?? '';
    final email = prefs.getString('user_email') ?? '';
    final isLoggedIn = prefs.getBool('is_logged_in') ?? false;
    _isDarkMode = prefs.getBool('is_dark_mode') ?? false;
    
    // Counter Kunjungan (Latihan 2)
    int currentCount = prefs.getInt('visit_count') ?? 0;
    currentCount++;
    await prefs.setInt('visit_count', currentCount);
    _visitCount = currentCount;

    // Daftar Favorit (Latihan 3)
    _favorites = prefs.getStringList('favorites') ?? [];

    _user = User(name: name, email: email, isLoggedIn: isLoggedIn);
    _isLoading = false;
    notifyListeners();
  }

  // Mengubah dan menyimpan tema (Latihan 1)
  Future<void> toggleTheme(bool value) async {
    _isDarkMode = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_dark_mode', value);
  }

  // Menyimpan data user ke SharedPreferences
  Future<void> updateUser(User newUser) async {
    _isLoading = true;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', newUser.name);
    await prefs.setString('user_email', newUser.email);
    await prefs.setBool('is_logged_in', newUser.isLoggedIn);

    _user = newUser;
    _isLoading = false;
    notifyListeners();
  }

  // Logout: hapus status login dan nama dari SharedPreferences
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_name');
    await prefs.setBool('is_logged_in', false);

    _user = _user.copyWith(name: '', isLoggedIn: false);
    notifyListeners();
  }

  // Tambah item favorit (Latihan 3)
  Future<void> addFavorite(String item) async {
    if (item.trim().isEmpty) return;
    _favorites.add(item.trim());
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('favorites', _favorites);
  }

  // Hapus item favorit (Latihan 3)
  Future<void> removeFavorite(int index) async {
    _favorites.removeAt(index);
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('favorites', _favorites);
  }
}