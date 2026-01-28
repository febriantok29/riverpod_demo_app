/// State untuk Task form (create/edit)
class TaskFormState {
  final bool isLoading;
  final String? errorMessage;
  final bool isSuccess;

  TaskFormState({
    this.isLoading = false,
    this.errorMessage,
    this.isSuccess = false,
  });

  TaskFormState copyWith({
    bool? isLoading,
    String? errorMessage,
    bool? isSuccess,
  }) {
    return TaskFormState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }
}
