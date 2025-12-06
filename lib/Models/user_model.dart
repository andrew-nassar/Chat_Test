class UserDto {
  final String id;
  final String username;

  UserDto({
    required this.id,
    required this.username,
  });

  factory UserDto.fromJson(Map<String, dynamic> json) {
    return UserDto(
      id: json['id'],
      username: json['username'],
    );
  }
}

class PagedResult<T> {
  final List<T> items;
  final int totalCount;
  final bool hasNextPage;

  PagedResult({
    required this.items,
    required this.totalCount,
    required this.hasNextPage,
  });

  factory PagedResult.fromJson(Map<String, dynamic> json, T Function(Object?) fromJsonT) {
    return PagedResult<T>(
      items: (json['items'] as List).map(fromJsonT).toList(),
      totalCount: json['totalCount'],
      hasNextPage: json['hasNextPage'],
    );
  }
}