class Account {
  final String id;
  final String username;
  final String email;

  Account({required this.id, required this.username, required this.email});

  Map<String, dynamic> toMap() {
    return {'id': id, 'username': username, 'email': email};
  }

  factory Account.fromMap(Map<String, dynamic> map, String documentId) {
    return Account(
      id: documentId,
      username: map['username'] ?? '',
      email: map['email'] ?? '',
    );
  }
}
