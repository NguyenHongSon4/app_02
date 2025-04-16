import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../db/NoteAccountAPIService.dart';
import 'NoteListScreen.dart';

class LoginScreen extends StatefulWidget {
  final VoidCallback onThemeChanged;
  final bool isDarkMode;
  final Function(BuildContext) onLogout;

  const LoginScreen({
    super.key,
    required this.onThemeChanged,
    required this.isDarkMode,
    required this.onLogout,
  });

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    // Khởi tạo animation
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final account = await NoteAccountAPIService.instance.login(
          _usernameController.text,
          _passwordController.text,
        );

        setState(() {
          _isLoading = false;
        });

        if (account != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setInt('userId', account.userId);
          await prefs.setInt('accountId', account.id!);
          await prefs.setString('username', account.username);
          await prefs.setBool('isLoggedIn', true);

          if (mounted) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => NoteListScreen(
                  onThemeChanged: widget.onThemeChanged,
                  isDarkMode: widget.isDarkMode,
                  onLogout: widget.onLogout,
                ),
              ),
            );
          }
        } else {
          _showErrorDialog('Đăng nhập thất bại',
              'Tên đăng nhập hoặc mật khẩu không đúng hoặc tài khoản không hoạt động.');
        }
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        _showErrorDialog('Lỗi đăng nhập', 'Đã xảy ra lỗi: $e');
      }
    }
  }

  Future<void> _logout(BuildContext context) async {
    if (!mounted) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => LoginScreen(
            onThemeChanged: widget.onThemeChanged,
            isDarkMode: widget.isDarkMode,
            onLogout: widget.onLogout,
          ),
        ),
            (Route<dynamic> route) => false,
      );
    }

    print("Logout");
  }

  void _showErrorDialog(String title, String message) {
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Đăng nhập'),
        actions: [
          IconButton(
            icon: Icon(
              widget.isDarkMode ? Icons.wb_sunny : Icons.nightlight_round,
              color: widget.isDarkMode ? Colors.yellow : Colors.blue,
            ),
            onPressed: widget.onThemeChanged,
            tooltip: widget.isDarkMode ? 'Chuyển sang chế độ sáng' : 'Chuyển sang chế độ tối',
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: widget.isDarkMode
                ? [Colors.grey[900]!, Colors.grey[800]!]
                : [Colors.blue[50]!, Colors.white],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Logo
                    Container(
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Theme.of(context).primaryColor.withOpacity(0.1),
                      ),
                      child: Icon(
                        Icons.note_alt,
                        size: 80,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Chào mừng đến với NoteApp',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: widget.isDarkMode ? Colors.white : Colors.blue[900],
                      ),
                    ),
                    const SizedBox(height: 32),
                    // Form đăng nhập
                    Card(
                      elevation: 8,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              // Trường tên đăng nhập
                              TextFormField(
                                controller: _usernameController,
                                decoration: InputDecoration(
                                  labelText: 'Tên đăng nhập',
                                  prefixIcon: const Icon(
                                    Icons.person,
                                    color: Colors.blue,
                                  ),
                                  filled: true,
                                  fillColor: widget.isDarkMode
                                      ? Colors.grey[800]
                                      : Colors.grey[100],
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      color: Colors.blue,
                                      width: 2,
                                    ),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Vui lòng nhập tên đăng nhập';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              // Trường mật khẩu
                              TextFormField(
                                controller: _passwordController,
                                obscureText: _obscurePassword,
                                decoration: InputDecoration(
                                  labelText: 'Mật khẩu',
                                  prefixIcon: const Icon(
                                    Icons.lock,
                                    color: Colors.blue,
                                  ),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscurePassword
                                          ? Icons.visibility
                                          : Icons.visibility_off,
                                      color: Colors.blue,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _obscurePassword = !_obscurePassword;
                                      });
                                    },
                                  ),
                                  filled: true,
                                  fillColor: widget.isDarkMode
                                      ? Colors.grey[800]
                                      : Colors.grey[100],
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      color: Colors.blue,
                                      width: 2,
                                    ),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Vui lòng nhập mật khẩu';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 24),
                              // Nút đăng nhập
                              ElevatedButton(
                                onPressed: _isLoading ? null : _login,
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 16, horizontal: 32),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 5,
                                  backgroundColor: Colors.blue,
                                  foregroundColor: Colors.white,
                                ),
                                child: _isLoading
                                    ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                                    : const Text(
                                  'ĐĂNG NHẬP',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Liên kết quên mật khẩu
                    Center(
                      child: TextButton(
                        onPressed: () {
                          // Xử lý quên mật khẩu
                        },
                        child: Text(
                          'Quên mật khẩu?',
                          style: TextStyle(
                            color: widget.isDarkMode ? Colors.blue[300] : Colors.blue,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
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