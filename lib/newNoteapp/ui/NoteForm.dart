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
  late int _userId;
  List<String> _tags = [];
  String? _color;
  Color _selectedColor = Colors.white;
  String? _imagePath;
  File? _imageFile;
  final _tagController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;
  List<String> _suggestedTags = [];

  @override
  void initState() {
    super.initState();
    _title = widget.note?.title ?? '';
    _content = widget.note?.content ?? '';
    _priority = widget.note?.priority ?? 1;
    _userId = widget.note?.userId ?? 1;
    _tags = widget.note?.tags ?? [];
    _color = widget.note?.color;
    _imagePath = widget.note?.imagePath;

    _getUserId();
    _loadSuggestedTags();

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

    if (_imagePath != null && File(_imagePath!).existsSync()) {
      _imageFile = File(_imagePath!);
    }

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();

    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );
  }

  Future<void> _getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userId = prefs.getInt('userId') ?? 1;
    });
  }

  Future<void> _loadSuggestedTags() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _suggestedTags = prefs.getStringList('suggestedTags') ?? [];
    });
  }

  Future<void> _saveSuggestedTags() async {
    final prefs = await SharedPreferences.getInstance();
    final uniqueTags = _suggestedTags.toSet().union(_tags.toSet()).toList();
    await prefs.setStringList('suggestedTags', uniqueTags);
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
    _scaleController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  void _addTag(String tag) {
    if (tag.trim().isNotEmpty) {
      setState(() {
        _tags.add(tag.trim());
        _tagController.clear();
      });
      _saveSuggestedTags();
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
    if (!status.isGranted) {
      status = await Permission.camera.request();
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
    var status = await Permission.photos.status;
    if (!status.isGranted) {
      status = await Permission.photos.request();
    }
    if (!status.isGranted && Platform.isAndroid) {
      status = await Permission.storage.status;
      if (!status.isGranted) {
        status = await Permission.storage.request();
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
      if (photo != null) {
        await _deleteOldImage();
        final directory = await getApplicationDocumentsDirectory();
        final imageName = 'note_image_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final newImagePath = '${directory.path}/$imageName';
        final File newImage = await File(photo.path).copy(newImagePath);
        setState(() {
          _imageFile = newImage;
          _imagePath = newImagePath;
        });
      }
    } catch (e) {
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
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      if (image != null) {
        await _deleteOldImage();
        final directory = await getApplicationDocumentsDirectory();
        final imageName = 'note_image_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final newImagePath = '${directory.path}/$imageName';
        final File newImage = await File(image.path).copy(newImagePath);
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
      }
    } catch (e) {
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
                _selectedColor.withOpacity(0.8),
                _selectedColor.withOpacity(0.3),
              ],
            ),
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
            tooltip: 'Hủy',
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
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
              children: [
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Thông tin chính
                      Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Thông tin chính',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                ),
                              ),
                              const SizedBox(height: 12),
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
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(color: Colors.blue, width: 2),
                                  ),
                                ),
                                maxLength: 50,
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
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(color: Colors.blue, width: 2),
                                  ),
                                ),
                                maxLines: 4,
                                validator: (value) =>
                                value!.isEmpty ? 'Nội dung không được để trống' : null,
                                onSaved: (value) => _content = value!,
                              ),
                              const SizedBox(height: 12),
                              InputDecorator(
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
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    ChoiceChip(
                                      label: const Text('Thấp'),
                                      selected: _priority == 1,
                                      selectedColor: Colors.green,
                                      onSelected: (selected) => setState(() => _priority = 1),
                                    ),
                                    ChoiceChip(
                                      label: const Text('Trung bình'),
                                      selected: _priority == 2,
                                      selectedColor: Colors.yellow,
                                      onSelected: (selected) => setState(() => _priority = 2),
                                    ),
                                    ChoiceChip(
                                      label: const Text('Cao'),
                                      selected: _priority == 3,
                                      selectedColor: Colors.red,
                                      onSelected: (selected) => setState(() => _priority = 3),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Nhãn
                      Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        child: ExpansionTile(
                          title: const Text(
                            'Nhãn',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Autocomplete<String>(
                                    optionsBuilder: (TextEditingValue textEditingValue) {
                                      if (textEditingValue.text.isEmpty) {
                                        return const Iterable<String>.empty();
                                      }
                                      return _suggestedTags.where((tag) => tag
                                          .toLowerCase()
                                          .contains(textEditingValue.text.toLowerCase()));
                                    },
                                    onSelected: (String selection) => _addTag(selection),
                                    fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                                      _tagController.value = controller.value;
                                      return TextField(
                                        controller: controller,
                                        focusNode: focusNode,
                                        decoration: InputDecoration(
                                          labelText: 'Nhãn (phân tách bằng dấu phẩy)',
                                          prefixIcon: const Icon(Icons.label, color: Colors.blue),
                                          filled: true,
                                          fillColor: isDarkMode ? Colors.grey[800] : Colors.grey[100],
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(12),
                                            borderSide: BorderSide.none,
                                          ),
                                        ),
                                        onSubmitted: (value) {
                                          final tags = value.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty);
                                          for (var tag in tags) {
                                            _addTag(tag);
                                          }
                                          controller.clear();
                                        },
                                      );
                                    },
                                  ),
                                  if (_tags.isNotEmpty) ...[
                                    const SizedBox(height: 12),
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
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Màu và ảnh
                      Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        child: ExpansionTile(
                          title: const Text(
                            'Tùy chỉnh nâng cao',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
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
                                    GestureDetector(
                                      onTap: () {
                                        showDialog(
                                          context: context,
                                          builder: (context) => Dialog(
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Image.file(_imageFile!, fit: BoxFit.contain),
                                                TextButton(
                                                  onPressed: () => Navigator.pop(context),
                                                  child: const Text('Đóng'),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.file(
                                          _imageFile!,
                                          height: 150,
                                          width: double.infinity,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
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
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Nút lưu
                      ScaleTransition(
                        scale: _scaleAnimation,
                        child: ElevatedButton(
                          onPressed: () async {
                            _scaleController.forward().then((_) => _scaleController.reverse());
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
                                  userId: _userId,
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
                            elevation: 4,
                          ),
                          child: const Text('Lưu', style: TextStyle(fontSize: 16)),
                        ),
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