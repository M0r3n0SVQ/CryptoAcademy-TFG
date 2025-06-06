typedef ContentItemParser<T> = T Function(Map<String, dynamic> itemJson);

class PaginatedResponseModel<T> {
  final List<T> content;
  final int totalPages;
  final int totalElements;
  final int number;
  final int size;
  final bool first;
  final bool last;
  final bool empty;

  PaginatedResponseModel({
    required this.content,
    required this.totalPages,
    required this.totalElements,
    required this.number,
    required this.size,
    required this.first,
    required this.last,
    required this.empty,
  });

  factory PaginatedResponseModel.fromJson(Map<String, dynamic> json, ContentItemParser<T> itemParser) {
    var list = json['content'] as List? ?? [];
    List<T> parsedContent = list.map((i) => itemParser(i as Map<String, dynamic>)).toList();

    return PaginatedResponseModel<T>(
      content: parsedContent,
      totalPages: json['totalPages'] as int? ?? 0,
      totalElements: json['totalElements'] as int? ?? 0,
      number: json['number'] as int? ?? 0,
      size: json['size'] as int? ?? 0,
      first: json['first'] as bool? ?? true,
      last: json['last'] as bool? ?? true,
      empty: json['empty'] as bool? ?? true,
    );
  }
}
