import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/task.dart';
import '../../services/task_service.dart';
import '../../states/task_state.dart';

/// Providers untuk Task Module
class TaskProviders {
  // Provider untuk TaskService (singleton)
  static final service = Provider<TaskService>((ref) {
    final service = TaskService();

    // Dispose service ketika provider di-dispose
    ref.onDispose(() {
      service.dispose();
    });

    return service;
  });

  // StreamProvider untuk tasks stream
  // Ini yang akan digunakan dengan StreamBuilder di UI
  // StreamProvider otomatis handle loading, error, dan data state
  static final tasksStream = StreamProvider<List<Task>>((ref) {
    final service = ref.watch(TaskProviders.service);
    return service.tasksStream;
  });

  // StateNotifierProvider untuk Task Form operations
  static final form = StateNotifierProvider<TaskFormNotifier, TaskFormState>((
    ref,
  ) {
    final service = ref.watch(TaskProviders.service);
    return TaskFormNotifier(service);
  });
}

/// Notifier untuk mengelola Task Form state
class TaskFormNotifier extends StateNotifier<TaskFormState> {
  final TaskService _taskService;

  TaskFormNotifier(this._taskService) : super(TaskFormState());

  /// Create new task
  Future<void> createTask({
    required String title,
    required String description,
  }) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);

      await _taskService.createTask(title: title, description: description);

      state = state.copyWith(isLoading: false, isSuccess: true);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to create task: $e',
      );
    }
  }

  /// Update existing task
  Future<void> updateTask(Task task) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);

      await _taskService.updateTask(task);

      state = state.copyWith(isLoading: false, isSuccess: true);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to update task: $e',
      );
    }
  }

  /// Toggle task completion
  Future<void> toggleCompletion(String taskId) async {
    try {
      await _taskService.toggleTaskCompletion(taskId);
    } catch (e) {
      state = state.copyWith(errorMessage: 'Failed to toggle task: $e');
    }
  }

  /// Delete task
  Future<void> deleteTask(String taskId) async {
    try {
      await _taskService.deleteTask(taskId);
    } catch (e) {
      state = state.copyWith(errorMessage: 'Failed to delete task: $e');
    }
  }

  /// Reset state
  void resetState() {
    state = TaskFormState();
  }
}
