class PaginationRequestDto {
  final int page;
  final int pageSize;
  final String? search;
  final String? sortBy;
  final String? sortOrder;
  final String? type;

  PaginationRequestDto({
    required this.page,
    required this.pageSize,
    this.search,
    this.sortBy,
    this.sortOrder,
    this.type,
  });

  /// ✅ Sửa: trả đủ các trường để có thể gửi query đúng
  Map<String, dynamic> toMap() {
    return {
      'page': page,
      'pageSize': pageSize,
      if (search != null) 'search': search,
      if (sortBy != null) 'sortBy': sortBy,
      if (sortOrder != null) 'sortOrder': sortOrder,
      if (type != null) 'type': type,
    };
  }
}
