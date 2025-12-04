class AuthResponse {
  final String accessToken;
  final String username;
  final String roles;
  final String id;

  AuthResponse({
    required this.accessToken,
    required this.username,
    required this.roles,
    required this.id,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      accessToken: json['accessToken'],
      username: json['username'],
      roles: json['roles'],
      id: json['id'],
    );
  }
}
