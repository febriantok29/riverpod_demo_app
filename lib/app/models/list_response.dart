class ListResponse<T> {
  final List<T> data;
  final int total;
  final int page;
  final int limit;

  ListResponse({
    required this.data,
    required this.total,
    required this.page,
    required this.limit,
  });

  /// Factory untuk parsing JSON dengan custom parser untuk data list
  factory ListResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT, {
    String dataKey = 'data',
  }) {
    final data = <T>[];

    final rawData = json[dataKey];

    if (rawData is List) {
      for (final item in rawData) {
        if (item is Map<String, dynamic>) {
          data.add(fromJsonT(item));
        }
      }
    }

    final total = int.tryParse('${json['total']}') ?? 0;
    final skip = int.tryParse('${json['skip']}') ?? 0;
    final limit = int.tryParse('${json['limit']}') ?? 0;

    int? page = int.tryParse('${json['page']}');
    page ??= (skip / limit).ceil();

    return ListResponse<T>(data: data, total: total, page: page, limit: limit);
  }

  /// Check apakah masih ada data berikutnya untuk pagination
  bool get hasMore {
    final currentCount = (page * limit) + data.length;
    return currentCount < total;
  }

  /// Get skip value untuk API pagination
  int get skip => page * limit;
}
