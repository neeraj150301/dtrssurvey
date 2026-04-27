class DashboardState {
  final bool isLoading;
  final int total;
  final int pending;
  final int completed;
  final String? error;

  DashboardState({
    this.isLoading = false,
    this.total = 0,
    this.pending = 0,
    this.completed = 0,
    this.error,
  });

  DashboardState copyWith({
    bool? isLoading,
    int? total,
    int? pending,
    int? completed,
    String? error,
  }) {
    return DashboardState(
      isLoading: isLoading ?? this.isLoading,
      total: total ?? this.total,
      pending: pending ?? this.pending,
      completed: completed ?? this.completed,
      error: error,
    );
  }
}
