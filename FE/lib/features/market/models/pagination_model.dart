class PaginationModel {
  const PaginationModel(
      {required this.page,
      required this.perPage,
      required this.total,
      required this.totalPages,
      required this.hasNext,
      required this.hasPrevious});
  final int page, perPage, total, totalPages;
  final bool hasNext, hasPrevious;
  factory PaginationModel.fromJson(Map<String, dynamic>? json,
      {int fallbackPage = 1, int fallbackPerPage = 20, int fallbackTotal = 0}) {
    final data = json ?? const <String, dynamic>{};
    int read(String key, int fallback) => data[key] is num
        ? (data[key] as num).toInt()
        : int.tryParse('${data[key]}') ?? fallback;
    bool readBool(String key, bool fallback) =>
        data[key] is bool ? data[key] as bool : fallback;
    final page = read('page', fallbackPage),
        perPage = read('per_page', fallbackPerPage);
    final total = read('total', fallbackTotal),
        totalPages =
            read('total_pages', perPage == 0 ? 0 : (total / perPage).ceil());
    return PaginationModel(
        page: page,
        perPage: perPage,
        total: total,
        totalPages: totalPages,
        hasNext: readBool('has_next', page < totalPages),
        hasPrevious: readBool('has_previous', page > 1));
  }
}
