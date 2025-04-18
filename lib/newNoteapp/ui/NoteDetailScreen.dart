import 'dart:io';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart'; // Thư viện để chia sẻ
import "package:app_02/newNoteapp/model/NoteModel.dart";

class NoteDetailScreen extends StatefulWidget {
  final Note note;

  const NoteDetailScreen({super.key, required this.note});

  @override
  _NoteDetailScreenState createState() => _NoteDetailScreenState();
}

class _NoteDetailScreenState extends State<NoteDetailScreen> with SingleTickerProviderStateMixin {
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
    _animationController.dispose();
    super.dispose();
  }

  // Phương thức chia sẻ ghi chú
  void _shareNote() {
    final String shareText = '''
Tiêu đề: ${widget.note.title}
Nội dung: ${widget.note.content}
Ưu tiên: ${widget.note.priority == 1 ? "Thấp" : widget.note.priority == 2 ? "Trung bình" : "Cao"}
Thời gian tạo: ${widget.note.createdAt}
Thời gian sửa: ${widget.note.modifiedAt}
Nhãn: ${widget.note.tags?.join(', ') ?? 'Không có nhãn'}
    ''';
    Share.share(shareText, subject: widget.note.title);
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true, // Cho phép nền kéo dài lên AppBar
      appBar: AppBar(
        title: Text(widget.note.title),
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.orange.withOpacity(0.8),
                Colors.yellow.withOpacity(0.3),
              ],
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _shareNote,
            tooltip: 'Chia sẻ ghi chú',
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
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
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
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Nội dung
                            _buildInfoRow(
                              icon: Icons.description,
                              label: 'Nội dung',
                              value: widget.note.content,
                              context: context,
                            ),
                            const SizedBox(height: 16),
                            // Ưu tiên
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
                            // Thời gian tạo
                            _buildInfoRow(
                              icon: Icons.event,
                              label: 'Thời gian tạo',
                              value: widget.note.createdAt.toString(),
                              context: context,
                            ),
                            const SizedBox(height: 16),
                            // Thời gian sửa
                            _buildInfoRow(
                              icon: Icons.update,
                              label: 'Thời gian sửa',
                              value: widget.note.modifiedAt.toString(),
                              context: context,
                            ),
                            // Nhãn
                            if (widget.note.tags != null && widget.note.tags!.isNotEmpty)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 16),
                                  _buildInfoRow(
                                    icon: Icons.label,
                                    label: 'Nhãn',
                                    value: widget.note.tags!.join(', '),
                                    context: context,
                                  ),
                                ],
                              ),
                            // Màu
                            if (widget.note.color != null)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 16),
                                  _buildInfoRow(
                                    icon: Icons.color_lens,
                                    label: 'Màu',
                                    value: widget.note.color!,
                                    color: Color(
                                      int.parse(
                                        widget.note.color!.replaceFirst('#', ''),
                                        radix: 16,
                                      ) + 0xFF000000,
                                    ),
                                    context: context,
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Ảnh đính kèm
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
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
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
                                ClipRRect(
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
      ),
    );
  }

  // Widget phụ để hiển thị một hàng thông tin
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