class Account {
  final String id;
  final String username;
  final String email;
  final bool isAdmin;

  Account({
    required this.id, 
    required this.username, 
    required this.email,
    this.isAdmin = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id, 
      'username': username, 
      'email': email,
      'isAdmin': isAdmin,
    };
  }

  factory Account.fromMap(Map<String, dynamic> map, String documentId) {
    return Account(
      id: documentId,
      username: map['username'] ?? '',
      email: map['email'] ?? '',
      isAdmin: map['isAdmin'] ?? false,
    );
  }
}