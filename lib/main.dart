import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app_02/noteApp/ui/LoginScreen.dart';
import 'package:app_02/noteApp/ui/NoteListScreen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isDarkMode = false;

  @override
  void initState() {
    super.initState();
    _loadTheme();
  }

  // Tải trạng thái chủ đề từ SharedPreferences
  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    });
  }

  // Lưu trạng thái chủ đề vào SharedPreferences
  Future<void> _saveTheme(bool isDarkMode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', isDarkMode);
  }

  // Chuyển đổi giữa chế độ sáng và tối
  void _toggleTheme() {
    setState(() {
      _isDarkMode = !_isDarkMode;
      _saveTheme(_isDarkMode);
    });
  }

  // Phương thức đăng xuất
  Future<void> _logout(BuildContext context) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận đăng xuất'),
        content: const Text('Bạn có chắc chắn muốn đăng xuất không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Đăng xuất'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final prefs = await SharedPreferences.getInstance();
    print("Before logout - isLoggedIn: ${prefs.getBool('isLoggedIn')}");
    await prefs.clear();
    print("After logout - isLoggedIn: ${prefs.getBool('isLoggedIn') ?? false}");
    print("All keys after logout: ${prefs.getKeys()}");

    if (context.mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => LoginScreen(
            onThemeChanged: _toggleTheme,
            isDarkMode: _isDarkMode,
            onLogout: _logout,
          ),
        ),
            (Route<dynamic> route) => false,
      );
    }

    print("Đăng xuất thành công");
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quản Lý Ghi Chú',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.light,
        scaffoldBackgroundColor: Colors.white,
        cardTheme: const CardTheme(
          color: Colors.white,
          elevation: 2,
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.black),
          bodyMedium: TextStyle(color: Colors.black87),
        ),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      darkTheme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.grey[900],
        cardTheme: CardTheme(
          color: Colors.grey[800],
          elevation: 2,
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.white),
          bodyMedium: TextStyle(color: Colors.white70),
        ),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: AuthCheckWidget(
        isDarkMode: _isDarkMode,
        onThemeChanged: _toggleTheme,
        onLogout: _logout,
      ),
    );
  }
}

class AuthCheckWidget extends StatelessWidget {
  final bool isDarkMode;
  final VoidCallback onThemeChanged;
  final Function(BuildContext) onLogout;

  const AuthCheckWidget({
    super.key,
    required this.isDarkMode,
    required this.onThemeChanged,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<SharedPreferences>(
      future: SharedPreferences.getInstance(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (!snapshot.hasData) {
          return LoginScreen(
            onThemeChanged: onThemeChanged,
            isDarkMode: isDarkMode,
            onLogout: onLogout,
          );
        }

        final prefs = snapshot.data!;
        final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
        print("App start - isLoggedIn: $isLoggedIn");

        if (isLoggedIn) {
          print("User is logged in");
          return NoteListScreen(
            onThemeChanged: onThemeChanged,
            isDarkMode: isDarkMode,
            onLogout: onLogout,
          );
        } else {
          print("User is not logged in");
          return LoginScreen(
            onThemeChanged: onThemeChanged,
            isDarkMode: isDarkMode,
            onLogout: onLogout,
          );
        }
      },
    );
  }
}