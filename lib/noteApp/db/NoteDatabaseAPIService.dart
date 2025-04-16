import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:app_02/noteApp/model/NoteModel.dart';

class NoteDatabaseHelper {
  static final NoteDatabaseHelper instance = NoteDatabaseHelper._init();
  final String baseUrl = 'https://my-json-server.typicode.com/NguyenHongSon4/note'; // URL của JSON Server

  NoteDatabaseHelper._init();

  // Lấy danh sách tất cả ghi chú
  Future<List<Note>> getAllNotes() async {
    final response = await http.get(Uri.parse('$baseUrl/notes'));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Note.fromMap(json)).toList();
    } else {
      throw Exception('Failed to load notes');
    }
  }

  // Lấy ghi chú theo ID
  Future<Note?> getNoteById(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/notes/$id'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return Note.fromMap(data);
    } else if (response.statusCode == 404) {
      return null;
    } else {
      throw Exception('Failed to load note');
    }
  }

  // Thêm ghi chú mới
  Future<int> insertNote(Note note) async {
    final response = await http.post(
      Uri.parse('$baseUrl/notes'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(note.toMap()..remove('id')), // Bỏ id vì server sẽ tự tạo
    );
    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return data['id']; // Trả về ID của ghi chú mới
    } else {
      throw Exception('Failed to insert note');
    }
  }

  // Cập nhật ghi chú
  Future<int> updateNote(Note note) async {
    final response = await http.put(
      Uri.parse('$baseUrl/notes/${note.id}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(note.toMap()),
    );
    if (response.statusCode == 200) {
      return 1; // Trả về 1 để báo thành công
    } else {
      throw Exception('Failed to update note');
    }
  }

  // Xóa ghi chú
  Future<int> deleteNote(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/notes/$id'));
    if (response.statusCode == 200) {
      return 1; // Trả về 1 để báo thành công
    } else {
      throw Exception('Failed to delete note');
    }
  }

  // Lấy ghi chú theo mức độ ưu tiên
  Future<List<Note>> getNotesByPriority(int priority) async {
    final response = await http.get(Uri.parse('$baseUrl/notes?priority=$priority'));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Note.fromMap(json)).toList();
    } else {
      throw Exception('Failed to load notes by priority');
    }
  }

  // Tìm kiếm ghi chú
  Future<List<Note>> searchNotes(String query) async {
    final response = await http.get(Uri.parse('$baseUrl/notes'));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      final allNotes = data.map((json) => Note.fromMap(json)).toList();
      return allNotes.where((note) =>
      note.title.toLowerCase().contains(query.toLowerCase()) ||
          note.content.toLowerCase().contains(query.toLowerCase())).toList();
    } else {
      throw Exception('Failed to search notes');
    }
  }
}