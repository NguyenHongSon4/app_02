import 'package:flutter/material.dart';
import 'package:app_02/newNoteapp/model/NoteModel.dart';
import 'package:app_02/newNoteapp/db/NoteDatabaseHelper.dart';
import 'package:app_02/newNoteapp/ui/NoteForm.dart';
import 'package:app_02/newNoteapp/ui/NoteItem.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NoteListScreen extends StatefulWidget {
  final VoidCallback onThemeChanged;
  final bool isDarkMode;
  final Function(BuildContext) onLogout;

  const NoteListScreen({
    super.key,
    required this.onThemeChanged,
    required this.isDarkMode,
    required this.onLogout,
  });

  @override
  _NoteListScreenState createState() => _NoteListScreenState();
}

class _NoteListScreenState extends State<NoteListScreen> with TickerProviderStateMixin {
  late Future<List<Note>> _notesFuture;
  bool isGridView = false;
  bool _isSearching = false;
  String _searchQuery = '';
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  int? _userId;
  String _sortOption = 'date'; // Mặc định sắp xếp theo ngày
  int? _priorityFilter; // Lọc theo ưu tiên (null = không lọc, 1 = Thấp, 2 = Trung bình, 3 = Cao)
  String _tagFilter = ''; // Lọc theo nhãn

  @override
  void initState() {
    super.initState();
    _loadUserId();
    _refreshNotes();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  Future<void> _loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userId = prefs.getInt('userId');
    });
    _refreshNotes();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _refreshNotes() async {
    if (_userId == null) {
      setState(() {
        _notesFuture = Future.value([]);
      });
      return;
    }
    setState(() {
      _notesFuture = NoteDatabaseHelper.instance.getNotesByUserId(_userId!);
    });
  }

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      _searchQuery = '';
      _priorityFilter = null;
      _tagFilter = '';
    });
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
    });
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Lọc ghi chú'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Lọc theo ưu tiên
              const Text('Ưu tiên:', style: TextStyle(fontWeight: FontWeight.bold)),
              DropdownButton<int?>(
                value: _priorityFilter,
                items: const [
                  DropdownMenuItem(value: null, child: Text('Tất cả')),
                  DropdownMenuItem(value: 1, child: Text('Thấp')),
                  DropdownMenuItem(value: 2, child: Text('Trung bình')),
                  DropdownMenuItem(value: 3, child: Text('Cao')),
                ],
                onChanged: (value) {
                  setState(() {
                    _priorityFilter = value;
                  });
                  Navigator.of(ctx).pop();
                },
              ),
              const SizedBox(height: 16),
              // Lọc theo nhãn
              const Text('Nhãn:', style: TextStyle(fontWeight: FontWeight.bold)),
              TextField(
                onChanged: (value) {
                  setState(() {
                    _tagFilter = value;
                  });
                },
                decoration: const InputDecoration(
                  hintText: 'Nhập nhãn (rỗng để bỏ lọc)',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
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
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: _isSearching
            ? TextField(
          onChanged: _onSearchChanged,
          style: TextStyle(
            color: isDarkMode ? Colors.white : Colors.black,
          ),
          decoration: InputDecoration(
            hintText: 'Tìm kiếm ghi chú...',
            hintStyle: TextStyle(
              color: isDarkMode ? Colors.white54 : Colors.black54,
            ),
            border: InputBorder.none,
          ),
        )
            : const Text(
          'Ghi Chú Của Bạn',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.blue.withOpacity(0.8),
                Colors.blueGrey.withOpacity(0.3),
              ],
            ),
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Icon(
                _isSearching ? Icons.close : Icons.search,
                key: ValueKey<bool>(_isSearching),
                color: isDarkMode ? Colors.white : Colors.black,
              ),
            ),
            onPressed: _toggleSearch,
            tooltip: _isSearching ? 'Hủy tìm kiếm' : 'Tìm kiếm ghi chú',
          ),
          if (_isSearching)
            IconButton(
              icon: Icon(
                Icons.filter_list,
                color: isDarkMode ? Colors.white : Colors.black,
              ),
              onPressed: _showFilterDialog,
              tooltip: 'Lọc ghi chú',
            ),
          IconButton(
            icon: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Icon(
                isDarkMode ? Icons.wb_sunny : Icons.nightlight_round,
                key: ValueKey<bool>(isDarkMode),
                color: isDarkMode ? Colors.yellow : Colors.blue,
              ),
            ),
            onPressed: widget.onThemeChanged,
            tooltip: isDarkMode ? 'Chuyển sang chế độ sáng' : 'Chuyển sang chế độ tối',
          ),
          IconButton(
            icon: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Icon(
                isGridView ? Icons.list : Icons.grid_view,
                key: ValueKey<bool>(isGridView),
                color: isDarkMode ? Colors.white : Colors.black,
              ),
            ),
            onPressed: () => setState(() => isGridView = !isGridView),
            tooltip: isGridView ? 'Chuyển sang dạng danh sách' : 'Chuyển sang dạng lưới',
          ),
          IconButton(
            icon: Icon(
              Icons.refresh,
              color: isDarkMode ? Colors.white : Colors.black,
            ),
            onPressed: _refreshNotes,
            tooltip: 'Làm mới danh sách',
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'logout') {
                _showLogoutDialog();
              } else if (value == 'sort_date') {
                setState(() {
                  _sortOption = 'date';
                });
              } else if (value == 'sort_priority') {
                setState(() {
                  _sortOption = 'priority';
                });
              }
            },
            itemBuilder: (ctx) => [
              const PopupMenuItem(
                value: 'sort_date',
                child: Row(
                  children: [
                    Icon(Icons.date_range, color: Colors.blue),
                    SizedBox(width: 8),
                    Text('Sắp xếp theo ngày'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'sort_priority',
                child: Row(
                  children: [
                    Icon(Icons.priority_high, color: Colors.blue),
                    SizedBox(width: 8),
                    Text('Sắp xếp theo ưu tiên'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.exit_to_app, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Đăng xuất'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDarkMode
                ? [Colors.grey[900]!, Colors.grey[800]!]
                : [Colors.blue[50]!, Colors.white],
          ),
        ),
        child: SafeArea(
          child: FutureBuilder<List<Note>>(
            future: _notesFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(
                  child: Text(
                    'Đã xảy ra lỗi: ${snapshot.error}',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                );
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.note_add,
                        size: 80,
                        color: isDarkMode ? Colors.white54 : Colors.grey,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Không có ghi chú nào\nNhấn nút + để thêm ghi chú mới',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: isDarkMode ? Colors.white54 : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                );
              } else {
                // Lọc ghi chú
                final notes = snapshot.data!.where((note) {
                  bool matchesSearch = true;
                  bool matchesPriority = true;
                  bool matchesTag = true;

                  // Lọc theo từ khóa tìm kiếm (tiêu đề, nội dung)
                  if (_searchQuery.isNotEmpty) {
                    matchesSearch = note.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                        note.content.toLowerCase().contains(_searchQuery.toLowerCase());
                  }

                  // Lọc theo ưu tiên
                  if (_priorityFilter != null) {
                    matchesPriority = note.priority == _priorityFilter;
                  }

                  // Lọc theo nhãn
                  if (_tagFilter.isNotEmpty) {
                    matchesTag = note.tags?.any((tag) => tag.toLowerCase().contains(_tagFilter.toLowerCase())) ?? false;
                  }

                  return matchesSearch && matchesPriority && matchesTag;
                }).toList();

                // Sắp xếp ghi chú
                if (_sortOption == 'date') {
                  notes.sort((a, b) => b.createdAt.compareTo(a.createdAt)); // Mới nhất trước
                } else if (_sortOption == 'priority') {
                  notes.sort((a, b) => b.priority.compareTo(a.priority)); // Ưu tiên cao trước
                }

                if (notes.isEmpty) {
                  return Center(
                    child: Text(
                      'Không tìm thấy ghi chú nào',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: _refreshNotes,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: isGridView
                        ? GridView.builder(
                      key: const ValueKey<String>('grid'),
                      padding: const EdgeInsets.all(8),
                      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 200,
                        childAspectRatio: 0.7,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                      ),
                      itemCount: notes.length,
                      itemBuilder: (context, index) => FadeTransition(
                        opacity: _fadeAnimation,
                        child: NoteItem(
                          note: notes[index],
                          onDelete: _refreshNotes,
                        ),
                      ),
                    )
                        : ListView.builder(
                      key: const ValueKey<String>('list'),
                      padding: const EdgeInsets.all(8),
                      itemCount: notes.length,
                      itemBuilder: (context, index) => FadeTransition(
                        opacity: _fadeAnimation,
                        child: NoteItem(
                          note: notes[index],
                          onDelete: _refreshNotes,
                        ),
                      ),
                    ),
                  ),
                );
              }
            },
          ),
        ),
      ),
      floatingActionButton: ScaleTransition(
        scale: _pulseAnimation,
        child: FloatingActionButton(
          backgroundColor: Theme.of(context).primaryColor,
          onPressed: () async {
            final created = await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const NoteFormScreen()),
            );
            if (created == true) {
              _refreshNotes();
            }
          },
          tooltip: 'Thêm ghi chú mới',
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận đăng xuất'),
        content: const Text('Bạn có chắc chắn muốn đăng xuất?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              widget.onLogout(context);
            },
            child: const Text(
              'Đăng xuất',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}