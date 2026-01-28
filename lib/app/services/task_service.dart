import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/task.dart';

/// Service untuk mengelola Task dengan pendekatan Stream
/// Stream memungkinkan UI otomatis update ketika data berubah
class TaskService {
  static const String _storageKey = 'tasks';

  // StreamController untuk broadcast perubahan data ke semua listener
  final _tasksController = StreamController<List<Task>>.broadcast();

  // Cache local untuk menyimpan tasks di memory
  List<Task> _tasks = [];

  TaskService() {
    // Load tasks dari storage saat service dibuat
    _loadTasks();
  }

  /// Stream yang bisa di-listen oleh UI
  /// Setiap kali data berubah, stream akan emit data baru
  Stream<List<Task>> get tasksStream => _tasksController.stream;

  /// Load tasks dari SharedPreferences
  Future<void> _loadTasks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? tasksJson = prefs.getString(_storageKey);

      if (tasksJson != null) {
        final List<dynamic> decoded = json.decode(tasksJson);
        _tasks = decoded.map((json) => Task.fromJson(json)).toList();
      }

      // Emit data ke stream setelah load
      _tasksController.add(_tasks);
    } catch (e) {
      _tasksController.addError('Failed to load tasks: $e');
    }
  }

  /// Save tasks ke SharedPreferences
  Future<void> _saveTasks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String tasksJson = json.encode(
        _tasks.map((task) => task.toJson()).toList(),
      );
      await prefs.setString(_storageKey, tasksJson);
    } catch (e) {
      throw Exception('Failed to save tasks: $e');
    }
  }

  /// Get all tasks (untuk keperluan non-stream)
  Future<List<Task>> getTasks() async {
    await _loadTasks();
    return _tasks;
  }

  /// Create new task
  Future<void> createTask({
    required String title,
    required String description,
  }) async {
    final newTask = Task(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      description: description,
      createdAt: DateTime.now(),
    );

    _tasks.add(newTask);
    await _saveTasks();

    // Emit updated list ke stream
    _tasksController.add(_tasks);
  }

  /// Update existing task
  Future<void> updateTask(Task updatedTask) async {
    final index = _tasks.indexWhere((task) => task.id == updatedTask.id);

    if (index != -1) {
      _tasks[index] = updatedTask;
      await _saveTasks();

      // Emit updated list ke stream
      _tasksController.add(_tasks);
    } else {
      throw Exception('Task not found');
    }
  }

  /// Toggle task completion status
  Future<void> toggleTaskCompletion(String taskId) async {
    final index = _tasks.indexWhere((task) => task.id == taskId);

    if (index != -1) {
      _tasks[index] = _tasks[index].copyWith(
        isCompleted: !_tasks[index].isCompleted,
      );
      await _saveTasks();

      // Emit updated list ke stream
      _tasksController.add(_tasks);
    } else {
      throw Exception('Task not found');
    }
  }

  /// Delete task
  Future<void> deleteTask(String taskId) async {
    _tasks.removeWhere((task) => task.id == taskId);
    await _saveTasks();

    // Emit updated list ke stream
    _tasksController.add(_tasks);
  }

  /// Get task by ID
  Task? getTaskById(String taskId) {
    try {
      return _tasks.firstWhere((task) => task.id == taskId);
    } catch (e) {
      return null;
    }
  }

  /// Dispose stream controller ketika service tidak digunakan lagi
  void dispose() {
    _tasksController.close();
  }
}
