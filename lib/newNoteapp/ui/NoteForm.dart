import 'dart:io';
import 'package:flutter/material.dart';
import 'package:app_02/newNoteapp/db/NoteDatabaseHelper.dart';
import 'package:app_02/newNoteapp/model/NoteModel.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NoteFormScreen extends StatefulWidget {
  final Note? note;

  const NoteFormScreen({super.key, this.note});

  @override
  _NoteFormScreenState createState() => _NoteFormScreenState();
}

class _NoteFormScreenState extends State<NoteFormScreen> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
  late String _title;
  late String _content;
  late int _priority;
  late int _userId; // Thêm userId
  List<String> _tags = [];
  String? _color;
  Color _selectedColor = Colors.white;
  String? _imagePath;
  File? _imageFile;
  final _tagController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    // Initialize values from note (if provided)
    _title = widget.note?.title ?? '';
    _content = widget.note?.content ?? '';
    _priority = widget.note?.priority ?? 1;
    _userId = widget.note?.userId ?? 1; // Mặc định userId = 1 nếu không có
    _tags = widget.note?.tags ?? [];
    _color = widget.note?.color;
    _imagePath = widget.note?.imagePath;

    // Lấy userId từ SharedPreferences
    _getUserId();

    // Handle initial color
    if (_color != null) {
      try {
        String hexColor = _color!.replaceFirst('#', '');
        if (hexColor.length == 6) {
          _selectedColor = Color(int.parse('0xff$hexColor'));
        }
      } catch (e) {
        _selectedColor = Colors.white;
      }
    }

    // Check if initial image exists
    if (_imagePath != null && File(_imagePath!).existsSync()) {
      _imageFile = File(_imagePath!);
    }

    // Initialize animation
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  Future<void> _getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userId = prefs.getInt('userId') ?? 1; // Mặc định userId = 1 nếu không tìm thấy
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    if (_color == null) {
      _selectedColor = isDarkMode ? Colors.grey[800]! : Colors.white;
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  void _addTag() {
    if (_tagController.text.trim().isNotEmpty) {
      setState(() {
        _tags.add(_tagController.text.trim());
        _tagController.clear();
      });
    }
  }

  void _removeTag(String tag) {
    setState(() {
      _tags.remove(tag);
    });
  }

  void _pickColor(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Chọn màu ghi chú'),
        content: SingleChildScrollView(
          child: BlockPicker(
            pickerColor: _selectedColor,
            onColorChanged: (Color newColor) {
              setState(() {
                _selectedColor = newColor;
                _color = newColor.value.toRadixString(16).substring(2, 8);
              });
            },
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Xong'),
          ),
        ],
      ),
    );
  }

  Future<bool> _requestCameraPermission() async {
    var status = await Permission.camera.status;
    print('Camera permission status: $status');
    if (!status.isGranted) {
      status = await Permission.camera.request();
      print('Camera permission after request: $status');
    }
    if (status.isPermanentlyDenied) {
      _scaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(
          content: const Text('Quyền camera bị từ chối. Vui lòng cấp quyền trong cài đặt.'),
          action: SnackBarAction(
            label: 'Cài đặt',
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

  Future<bool> _requestPhotosPermission() async {
    // Try photos permission first (iOS and Android 13+)
    var status = await Permission.photos.status;
    print('Photos permission status: $status');
    if (!status.isGranted) {
      status = await Permission.photos.request();
      print('Photos permission after request: $status');
    }

    // Fallback to storage permission for older Android versions (API < 33)
    if (!status.isGranted && Platform.isAndroid) {
      status = await Permission.storage.status;
      print('Storage permission status: $status');
      if (!status.isGranted) {
        status = await Permission.storage.request();
        print('Storage permission after request: $status');
      }
    }

    if (status.isPermanentlyDenied) {
      _scaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(
          content: const Text('Quyền truy cập ảnh bị từ chối. Vui lòng cấp quyền trong cài đặt.'),
          action: SnackBarAction(
            label: 'Cài đặt',
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

  Future<void> _deleteOldImage() async {
    if (_imagePath != null && await File(_imagePath!).exists()) {
      await File(_imagePath!).delete();
      print('Deleted old image: $_imagePath');
    }
  }

  Future<void> _takePhoto(BuildContext context) async {
    if (!await _requestCameraPermission()) {
      _scaffoldMessengerKey.currentState?.showSnackBar(
        const SnackBar(
          content: Text('Cần quyền camera để chụp ảnh'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );
      print('Picked photo: $photo');
      if (photo != null) {
        await _deleteOldImage();
        final directory = await getApplicationDocumentsDirectory();
        final imageName = 'note_image_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final newImagePath = '${directory.path}/$imageName';
        final File newImage = await File(photo.path).copy(newImagePath);
        print('Photo saved to: $newImagePath');
        setState(() {
          _imageFile = newImage;
          _imagePath = newImagePath;
        });
      } else {
        print('No photo taken');
      }
    } catch (e, stackTrace) {
      print('Error in _takePhoto: $e\n$stackTrace');
      _scaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(
          content: Text('Lỗi khi chụp ảnh: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _pickImage(BuildContext context) async {
    if (!await _requestPhotosPermission()) {
      _scaffoldMessengerKey.currentState?.showSnackBar(
        const SnackBar(
          content: Text('Cần quyền truy cập ảnh để chọn ảnh'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    try {
      // Try pickImage first
      XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      print('Picked image (pickImage): $image');

      // Fallback to pickMedia if pickImage fails
      if (image == null) {
        print('Falling back to pickMedia');
        image = await _picker.pickMedia();
        print('Picked media (pickMedia): $image');
      }

      if (image != null) {
        await _deleteOldImage();
        final directory = await getApplicationDocumentsDirectory();
        final imageName = 'note_image_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final newImagePath = '${directory.path}/$imageName';
        final File newImage = await File(image.path).copy(newImagePath);
        print('Image saved to: $newImagePath');
        setState(() {
          _imageFile = newImage;
          _imagePath = newImagePath;
        });
        _scaffoldMessengerKey.currentState?.showSnackBar(
          const SnackBar(
            content: Text('Đã chọn ảnh từ thư viện'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        print('No image selected from gallery');
        _scaffoldMessengerKey.currentState?.showSnackBar(
          const SnackBar(
            content: Text('Không có ảnh nào được chọn'),
            backgroundColor: Colors.orange,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e, stackTrace) {
      print('Error in _pickImage: $e\n$stackTrace');
      _scaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(
          content: Text('Lỗi khi chọn ảnh: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showImagePickerDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Chọn nguồn ảnh'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                _pickImage(context);
              },
              icon: const Icon(Icons.photo_library),
              label: const Text('Thư viện'),
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                _takePhoto(context);
              },
              icon: const Icon(Icons.camera_alt),
              label: const Text('Camera'),
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
        title: Text(widget.note == null ? 'Thêm ghi chú' : 'Sửa ghi chú'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.blue.withOpacity(0.8),
                Colors.cyan.withOpacity(0.3),
              ],
            ),
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
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
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              children: [
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    children: [
                      Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              TextFormField(
                                initialValue: _title,
                                decoration: InputDecoration(
                                  labelText: 'Tiêu đề',
                                  prefixIcon: const Icon(Icons.title, color: Colors.blue),
                                  filled: true,
                                  fillColor: isDarkMode ? Colors.grey[800] : Colors.grey[100],
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                                validator: (value) =>
                                value!.isEmpty ? 'Tiêu đề không được để trống' : null,
                                onSaved: (value) => _title = value!,
                              ),
                              const SizedBox(height: 12),
                              TextFormField(
                                initialValue: _content,
                                decoration: InputDecoration(
                                  labelText: 'Nội dung',
                                  prefixIcon: const Icon(Icons.description, color: Colors.blue),
                                  filled: true,
                                  fillColor: isDarkMode ? Colors.grey[800] : Colors.grey[100],
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                                maxLines: 3,
                                validator: (value) =>
                                value!.isEmpty ? 'Nội dung không được để trống' : null,
                                onSaved: (value) => _content = value!,
                              ),
                              const SizedBox(height: 12),
                              DropdownButtonFormField<int>(
                                value: _priority,
                                items: const [
                                  DropdownMenuItem(value: 1, child: Text('Thấp')),
                                  DropdownMenuItem(value: 2, child: Text('Trung bình')),
                                  DropdownMenuItem(value: 3, child: Text('Cao')),
                                ],
                                onChanged: (value) => setState(() => _priority = value!),
                                decoration: InputDecoration(
                                  labelText: 'Ưu tiên',
                                  prefixIcon: const Icon(Icons.priority_high, color: Colors.blue),
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
                      const SizedBox(height: 12),
                      Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                                        labelText: 'Nhãn',
                                        prefixIcon: const Icon(Icons.label, color: Colors.blue),
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
                                  IconButton(
                                    icon: const Icon(Icons.add, color: Colors.blue),
                                    onPressed: _addTag,
                                  ),
                                ],
                              ),
                              if (_tags.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                Wrap(
                                  spacing: 8,
                                  children: _tags
                                      .map((tag) => Chip(
                                    label: Text(tag),
                                    deleteIcon: const Icon(Icons.close, size: 18),
                                    onDeleted: () => _removeTag(tag),
                                  ))
                                      .toList(),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            children: [
                              const Text('Màu: ', style: TextStyle(fontWeight: FontWeight.bold)),
                              GestureDetector(
                                onTap: () => _pickColor(context),
                                child: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: _selectedColor,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: Colors.grey, width: 1),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        onPressed: () => _showImagePickerDialog(context),
                        icon: const Icon(Icons.image),
                        label: const Text('Thêm ảnh'),
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        ),
                      ),
                      if (_imageFile != null) ...[
                        const SizedBox(height: 12),
                        Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                FutureBuilder<bool>(
                                  future: _imageFile!.exists(),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState == ConnectionState.waiting) {
                                      return const CircularProgressIndicator(strokeWidth: 2);
                                    }
                                    if (snapshot.hasData && snapshot.data == true) {
                                      return ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.file(
                                          _imageFile!,
                                          height: 150,
                                          width: double.infinity,
                                          fit: BoxFit.cover,
                                        ),
                                      );
                                    }
                                    return const Text('Ảnh không tồn tại', style: TextStyle(color: Colors.red));
                                  },
                                ),
                                TextButton.icon(
                                  onPressed: () => setState(() {
                                    _imageFile = null;
                                    _imagePath = null;
                                  }),
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  label: const Text('Xóa ảnh', style: TextStyle(color: Colors.red)),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            _formKey.currentState!.save();
                            try {
                              String? validatedColor = _color;
                              if (validatedColor != null && validatedColor.length != 6) {
                                validatedColor = null;
                              }
                              if (_imagePath != null && !await File(_imagePath!).exists()) {
                                _imagePath = null;
                              }

                              final now = DateTime.now();
                              final note = Note(
                                id: widget.note?.id,
                                title: _title,
                                content: _content,
                                priority: _priority,
                                userId: _userId, // Lưu userId
                                createdAt: widget.note?.createdAt ?? now,
                                modifiedAt: now,
                                tags: _tags.isNotEmpty ? _tags : null,
                                color: validatedColor,
                                imagePath: _imagePath,
                              );

                              if (widget.note == null) {
                                await NoteDatabaseHelper.instance.insertNote(note);
                                _scaffoldMessengerKey.currentState?.showSnackBar(
                                  const SnackBar(
                                    content: Text('Đã thêm ghi chú'),
                                    backgroundColor: Colors.green,
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              } else {
                                await NoteDatabaseHelper.instance.updateNote(note);
                                _scaffoldMessengerKey.currentState?.showSnackBar(
                                  const SnackBar(
                                    content: Text('Đã sửa ghi chú'),
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
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                        ),
                        child: const Text('Lưu', style: TextStyle(fontSize: 16)),
                      ),
                      const SizedBox(height: 16),
                    ],
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