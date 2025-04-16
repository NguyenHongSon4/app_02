import 'dart:io';
import 'package:flutter/material.dart';
import 'package:app_02/noteApp/db/NoteDatabaseAPIService.dart';
import "package:app_02/noteApp/model/NoteModel.dart";
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class NoteFormScreen extends StatefulWidget {
  final Note? note;

  const NoteFormScreen({super.key, this.note});

  @override
  _NoteFormScreenState createState() => _NoteFormScreenState();
}

class _NoteFormScreenState extends State<NoteFormScreen> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
  late String title;
  late String content;
  late int priority;
  List<String> tags = [];
  String? color;
  Color _selectedColor = Colors.white; // Default color
  String? imagePath;
  File? _imageFile;
  final _tagController = TextEditingController();

  final ImagePicker _picker = ImagePicker();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    title = widget.note?.title ?? '';
    content = widget.note?.content ?? '';
    priority = widget.note?.priority ?? 1;
    tags = widget.note?.tags ?? [];
    color = widget.note?.color;
    imagePath = widget.note?.imagePath;

    // Initialize _selectedColor with a default value
    _selectedColor = Colors.white; // Default value, will be updated in didChangeDependencies

    if (color != null) {
      try {
        _selectedColor = Color(int.parse('0xff$color'));
      } catch (e) {
        _selectedColor = Colors.white;
      }
    }
    if (imagePath != null && File(imagePath!).existsSync()) {
      _imageFile = File(imagePath!);
      print('Ảnh ban đầu tồn tại tại: $imagePath');
    }

    // Animation cho giao diện
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();

    // Animation cho nút "Lưu"
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Safely access Theme.of(context) here
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    if (color == null) {
      // Only update _selectedColor if it hasn't been set by the note's color
      setState(() {
        _selectedColor = isDarkMode ? Colors.grey[800]! : Colors.white;
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pulseController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  void _addTag() {
    if (_tagController.text.isNotEmpty) {
      setState(() {
        tags.add(_tagController.text.trim());
        _tagController.clear();
      });
    }
  }

  void _removeTag(String tag) {
    setState(() {
      tags.remove(tag);
    });
  }

  void _pickColor(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tùy chọn màu ghi chú'),
        content: SingleChildScrollView(
          child: BlockPicker(
            pickerColor: _selectedColor,
            onColorChanged: (Color newColor) {
              setState(() {
                _selectedColor = newColor;
                String hexColor = newColor.value.toRadixString(16).padLeft(8, '0').substring(2);
                color = hexColor;
              });
            },
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Xong'),
          ),
        ],
      ),
    );
  }

  Future<bool> _requestCameraPermission() async {
    var status = await Permission.camera.status;
    if (!status.isGranted) {
      status = await Permission.camera.request();
    }
    if (status.isPermanentlyDenied) {
      _scaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(
          content: const Text('Quyền camera bị từ chối vĩnh viễn. Vui lòng cấp quyền trong cài đặt.'),
          action: SnackBarAction(
            label: 'Mở cài đặt',
            onPressed: openAppSettings,
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return false;
    }
    return status.isGranted;
  }

  Future<bool> _requestStoragePermission() async {
    var status = await Permission.photos.status;
    if (!status.isGranted) {
      status = await Permission.photos.request();
    }
    if (status.isPermanentlyDenied) {
      _scaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(
          content: const Text('Quyền truy cập ảnh bị từ chối vĩnh viễn. Vui lòng cấp quyền trong cài đặt.'),
          action: SnackBarAction(
            label: 'Mở cài đặt',
            onPressed: openAppSettings,
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return false;
    }
    return status.isGranted;
  }

  Future<void> _takePhoto(BuildContext context) async {
    bool hasPermission = await _requestCameraPermission();
    if (!hasPermission) {
      _scaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(
          content: const Text('Cần cấp quyền truy cập camera để chụp ảnh'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    try {
      final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
      if (photo != null) {
        final directory = await getApplicationDocumentsDirectory();
        final imageName = 'note_image_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final imagePath = '${directory.path}/$imageName';
        final File newImage = await File(photo.path).copy(imagePath);
        print('Đã sao chép ảnh từ ${photo.path} sang $imagePath');
        if (await newImage.exists()) {
          print('File ảnh tồn tại sau khi sao chép');
        } else {
          print('File ảnh KHÔNG tồn tại sau khi sao chép');
        }
        setState(() {
          _imageFile = newImage;
          this.imagePath = imagePath;
        });
      } else {
        _scaffoldMessengerKey.currentState?.showSnackBar(
          SnackBar(
            content: const Text('Không có ảnh được chọn'),
            backgroundColor: Colors.orange,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      _scaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(
          content: Text('Lỗi khi chụp ảnh: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      print('Lỗi khi chụp ảnh: $e');
    }
  }

  Future<void> _pickImage(BuildContext context) async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final directory = await getApplicationDocumentsDirectory();
      final imageName = 'note_image_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final imagePath = '${directory.path}/$imageName';
      final File newImage = await File(image.path).copy(imagePath);
      setState(() {
        _imageFile = newImage;
        this.imagePath = imagePath;
      });
    }
  }

  void _showImagePickerDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Chọn ảnh từ thư viện hoặc chụp ảnh'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                _pickImage(context);
              },
              icon: const Icon(Icons.photo_library),
              label: const Text('Chọn ảnh từ thư viện'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                foregroundColor: Theme.of(context).primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                _takePhoto(context);
              },
              icon: const Icon(Icons.camera_alt),
              label: const Text('Chụp ảnh từ camera'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                foregroundColor: Theme.of(context).primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      key: _scaffoldMessengerKey,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(widget.note == null ? 'Thêm Ghi Chú' : 'Sửa Ghi Chú'),
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
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    children: [
                      // Card chứa các trường nhập liệu
                      Card(
                        elevation: 8,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              // Tiêu đề
                              TextFormField(
                                initialValue: title,
                                decoration: InputDecoration(
                                  labelText: 'Tiêu đề',
                                  prefixIcon: const Icon(
                                    Icons.title,
                                    color: Colors.blue,
                                  ),
                                  filled: true,
                                  fillColor: isDarkMode ? Colors.grey[800] : Colors.grey[100],
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
                                    return 'Tiêu đề không được để trống';
                                  }
                                  return null;
                                },
                                onSaved: (value) => title = value!,
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                              const SizedBox(height: 16),
                              // Nội dung
                              TextFormField(
                                initialValue: content,
                                decoration: InputDecoration(
                                  labelText: 'Nội dung',
                                  prefixIcon: const Icon(
                                    Icons.description,
                                    color: Colors.blue,
                                  ),
                                  filled: true,
                                  fillColor: isDarkMode ? Colors.grey[800] : Colors.grey[100],
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
                                maxLines: 3,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Nội dung không được để trống';
                                  }
                                  return null;
                                },
                                onSaved: (value) => content = value!,
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                              const SizedBox(height: 16),
                              // Mức độ ưu tiên
                              DropdownButtonFormField<int>(
                                value: priority,
                                items: const [
                                  DropdownMenuItem(value: 1, child: Text('Thấp')),
                                  DropdownMenuItem(value: 2, child: Text('Trung bình')),
                                  DropdownMenuItem(value: 3, child: Text('Cao')),
                                ],
                                onChanged: (value) => setState(() => priority = value!),
                                decoration: InputDecoration(
                                  labelText: 'Mức độ ưu tiên',
                                  prefixIcon: const Icon(
                                    Icons.priority_high,
                                    color: Colors.blue,
                                  ),
                                  filled: true,
                                  fillColor: isDarkMode ? Colors.grey[800] : Colors.grey[100],
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Nhập nhãn (tags)
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
                              Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      controller: _tagController,
                                      decoration: InputDecoration(
                                        labelText: 'Thêm nhãn',
                                        prefixIcon: const Icon(
                                          Icons.label,
                                          color: Colors.blue,
                                        ),
                                        filled: true,
                                        fillColor: isDarkMode ? Colors.grey[800] : Colors.grey[100],
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                          borderSide: BorderSide.none,
                                        ),
                                      ),
                                      onSubmitted: (_) => _addTag(),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  IconButton(
                                    icon: const Icon(Icons.add, color: Colors.blue),
                                    onPressed: _addTag,
                                    tooltip: 'Thêm nhãn',
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              if (tags.isNotEmpty)
                                Wrap(
                                  spacing: 8,
                                  children: tags.map((tag) {
                                    return Chip(
                                      label: Text(tag),
                                      backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                                      deleteIcon: const Icon(Icons.close, size: 18),
                                      onDeleted: () => _removeTag(tag),
                                    );
                                  }).toList(),
                                ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Chọn màu
                      Card(
                        elevation: 8,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            children: [
                              const Text(
                                'Chọn màu: ',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              GestureDetector(
                                onTap: () => _pickColor(context),
                                child: Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        _selectedColor,
                                        _selectedColor.withOpacity(0.7),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: isDarkMode ? Colors.white70 : Colors.black54,
                                      width: 2,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.2),
                                        blurRadius: 5,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Thêm ảnh
                      ElevatedButton.icon(
                        onPressed: () => _showImagePickerDialog(context),
                        icon: const Icon(Icons.image),
                        label: const Text('Thêm ảnh'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                          foregroundColor: Theme.of(context).primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Hiển thị ảnh đã chọn
                      if (_imageFile != null)
                        Card(
                          elevation: 8,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                FutureBuilder<bool>(
                                  future: _imageFile!.exists(),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState == ConnectionState.waiting) {
                                      return const CircularProgressIndicator(
                                        strokeWidth: 2,
                                      );
                                    }
                                    if (snapshot.hasData && snapshot.data == true) {
                                      return ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: Image.file(
                                          _imageFile!,
                                          height: 200,
                                          width: double.infinity,
                                          fit: BoxFit.cover,
                                        ),
                                      );
                                    }
                                    return const Text(
                                      'Ảnh không tồn tại',
                                      style: TextStyle(color: Colors.red),
                                    );
                                  },
                                ),
                                const SizedBox(height: 8),
                                TextButton.icon(
                                  onPressed: () {
                                    setState(() {
                                      _imageFile = null;
                                      imagePath = null;
                                    });
                                  },
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  label: const Text(
                                    'Xóa ảnh',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      const SizedBox(height: 16),
                      // Nút Lưu
                      ScaleTransition(
                        scale: _pulseAnimation,
                        child: ElevatedButton(
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              _formKey.currentState!.save();
                              try {
                                final now = DateTime.now();
                                final note = Note(
                                  id: widget.note?.id,
                                  title: title,
                                  content: content,
                                  priority: priority,
                                  createdAt: widget.note?.createdAt ?? now,
                                  modifiedAt: now,
                                  tags: tags,
                                  color: color,
                                  imagePath: imagePath,
                                );
                                if (widget.note == null) {
                                  await NoteDatabaseHelper.instance.insertNote(note);
                                  _scaffoldMessengerKey.currentState?.showSnackBar(
                                    SnackBar(
                                      content: const Text('Ghi chú đã được thêm'),
                                      backgroundColor: Colors.green,
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                } else {
                                  await NoteDatabaseHelper.instance.updateNote(note);
                                  _scaffoldMessengerKey.currentState?.showSnackBar(
                                    SnackBar(
                                      content: const Text('Ghi chú đã được sửa'),
                                      backgroundColor: Colors.green,
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                }
                                Navigator.pop(context, true);
                              } catch (e) {
                                _scaffoldMessengerKey.currentState?.showSnackBar(
                                  SnackBar(
                                    content: Text('Lỗi khi lưu ghi chú: $e'),
                                    backgroundColor: Colors.red,
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                            elevation: 5,
                          ),
                          child: const Text(
                            'Lưu',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}