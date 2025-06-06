typedef DataParser<T> = T Function(dynamic data);

class ApiResponse<T> {
  final bool success;
  final String message;
  final T? data;

  ApiResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory ApiResponse.fromJson(Map<String, dynamic> json, DataParser<T> parseData) {
    return ApiResponse<T>(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? 'Mensaje no disponible',
      data: json.containsKey('data') && json['data'] != null
            ? parseData(json['data']) 
            : null,
    );
  }

  Map<String, dynamic> toJson(Map<String, dynamic> Function(T? data) dataToJson) {
    return {
      'success': success,
      'message': message,
      'data': data != null ? dataToJson(data) : null,
    };
  }
}
