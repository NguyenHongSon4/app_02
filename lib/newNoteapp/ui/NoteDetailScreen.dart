import 'dart:io';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:app_02/newNoteapp/model/NoteModel.dart';
import 'package:app_02/newNoteapp/db/NoteAccountDatabaseHelper.dart';
import 'package:app_02/newNoteapp/ui/NoteForm.dart';

class NoteDetailScreen extends StatefulWidget {
  final Note note;

  const NoteDetailScreen({super.key, required this.note});

  @override
  _NoteDetailScreenState createState() => _NoteDetailScreenState();
}

class _NoteDetailScreenState extends State<NoteDetailScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  String? _username;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();

    _loadUsername();
  }

  Future<void> _loadUsername() async {
    final account = await NoteAccountDatabaseHelper.instance.getAccountByUserId(widget.note.userId);
    setState(() {
      _username = account?.username ?? 'Không xác định';
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _shareNote() {
    final String shareText = '''
Tiêu đề: ${widget.note.title}
Nội dung: ${widget.note.content}
Người tạo: $_username
Ưu tiên: ${widget.note.priority == 1 ? "Thấp" : widget.note.priority == 2 ? "Trung bình" : "Cao"}
Thời gian tạo: ${widget.note.createdAt}
Thời gian sửa: ${widget.note.modifiedAt}
Nhãn: ${widget.note.tags?.join(', ') ?? 'Không có nhãn'}
    ''';
    if (widget.note.imagePath != null && File(widget.note.imagePath!).existsSync()) {
      Share.shareFiles([widget.note.imagePath!], text: shareText, subject: widget.note.title);
    } else {
      Share.share(shareText, subject: widget.note.title);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    Color? noteColor;
    try {
      noteColor = widget.note.color != null
          ? Color(int.parse(widget.note.color!.replaceFirst('#', ''), radix: 16) + 0xFF000000)
          : null;
    } catch (e) {
      noteColor = null;
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).primaryColor,
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => NoteFormScreen(note: widget.note)),
          );
          if (result == true && mounted) {
            Navigator.of(context).pop(true); // Quay lại NoteListScreen để làm mới
          }
        },
        tooltip: 'Chỉnh sửa ghi chú',
        child: const Icon(Icons.edit, color: Colors.white),
      ),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200.0,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(widget.note.title),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: noteColor != null
                        ? [noteColor.withOpacity(0.8), noteColor.withOpacity(0.3)]
                        : [
                      Colors.orange.withOpacity(0.8),
                      Colors.yellow.withOpacity(0.3),
                    ],
                  ),
                ),
              ),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
            actions: [
              IconButton(
                icon: const Icon(Icons.share),
                color: Colors.white,
                onPressed: _shareNote,
                tooltip: 'Chia sẻ ghi chú',
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDarkMode
                      ? [Colors.grey[900]!, Colors.grey[800]!]
                      : [Colors.blue[50]!, Colors.white],
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Card chứa thông tin ghi chú
                      Card(
                        elevation: 8,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        color: noteColor?.withOpacity(0.1) ?? (isDarkMode ? Colors.grey[850] : Colors.white),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildInfoRow(
                                icon: Icons.person,
                                label: 'Người tạo',
                                value: _username ?? 'Đang tải...',
                                context: context,
                              ),
                              const SizedBox(height: 16),
                              _buildInfoRow(
                                icon: Icons.description,
                                label: 'Nội dung',
                                value: widget.note.content,
                                context: context,
                              ),
                              const SizedBox(height: 16),
                              _buildInfoRow(
                                icon: Icons.priority_high,
                                label: 'Ưu tiên',
                                value: widget.note.priority == 1
                                    ? "Thấp"
                                    : widget.note.priority == 2
                                    ? "Trung bình"
                                    : "Cao",
                                color: widget.note.priority == 1
                                    ? Colors.green
                                    : widget.note.priority == 2
                                    ? Colors.orange
                                    : Colors.red,
                                context: context,
                              ),
                              const SizedBox(height: 16),
                              _buildInfoRow(
                                icon: Icons.event,
                                label: 'Thời gian tạo',
                                value: widget.note.createdAt.toString(),
                                context: context,
                              ),
                              const SizedBox(height: 16),
                              _buildInfoRow(
                                icon: Icons.update,
                                label: 'Thời gian sửa',
                                value: widget.note.modifiedAt.toString(),
                                context: context,
                              ),
                              if (widget.note.tags != null && widget.note.tags!.isNotEmpty)
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 16),
                                    Text(
                                      'Nhãn:',
                                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Wrap(
                                      spacing: 8,
                                      children: widget.note.tags!
                                          .map(
                                            (tag) => Chip(
                                          label: Text(tag),
                                          backgroundColor: noteColor?.withOpacity(0.3) ??
                                              Theme.of(context).primaryColor.withOpacity(0.3),
                                          labelStyle: TextStyle(
                                            color: isDarkMode ? Colors.white : Colors.black87,
                                          ),
                                        ),
                                      )
                                          .toList(),
                                    ),
                                  ],
                                ),
                              if (widget.note.color != null)
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 16),
                                    _buildInfoRow(
                                      icon: Icons.color_lens,
                                      label: 'Màu',
                                      value: widget.note.color!,
                                      color: noteColor,
                                      context: context,
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (widget.note.imagePath != null && widget.note.imagePath!.isNotEmpty)
                        FutureBuilder<bool>(
                          future: Future(() async {
                            try {
                              final file = File(widget.note.imagePath!);
                              return await file.exists();
                            } catch (e) {
                              return false;
                            }
                          }),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const Center(
                                child: CircularProgressIndicator(strokeWidth: 2),
                              );
                            }
                            if (snapshot.hasData && snapshot.data == true) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Ảnh đính kèm:',
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Hero(
                                    tag: 'note_image_${widget.note.id}',
                                    child: GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => FullScreenImage(
                                              imagePath: widget.note.imagePath!,
                                            ),
                                          ),
                                        );
                                      },
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: Image.file(
                                          File(widget.note.imagePath!),
                                          height: 300,
                                          width: double.infinity,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) {
                                            return const Text(
                                              'Không thể tải ảnh',
                                              style: TextStyle(color: Colors.red),
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            }
                            return const SizedBox.shrink();
                          },
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    Color? color,
    required BuildContext context,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: color ?? Theme.of(context).primaryColor,
          size: 24,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$label:',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: color ?? Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class FullScreenImage extends StatelessWidget {
  final String imagePath;

  const FullScreenImage({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      body: Center(
        child: Hero(
          tag: 'note_image_${imagePath.hashCode}',
          child: Image.file(
            File(imagePath),
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return const Text(
                'Không thể tải ảnh',
                style: TextStyle(color: Colors.white),
              );
            },
          ),
        ),
      ),
    );
  }
}