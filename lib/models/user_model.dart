
class UserModel {
  final String id;                    // Same as Firebase Auth UID
  String name;                        // Display name
  String email;                       // Email address
  String photoUrl;                    // Profile picture URL
  double monthlySavingsGoal;          // The big goal shown on Home screen
  double savingsCurrentAmount;        // How much has been saved this month
  bool notificationsEnabled;          // From Profile screen toggle

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.photoUrl = '',
    this.monthlySavingsGoal = 0.0,
    this.savingsCurrentAmount = 0.0,
    this.notificationsEnabled = true,
  });

  // Save to Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'photoUrl': photoUrl,
      'monthlySavingsGoal': monthlySavingsGoal,
      'savingsCurrentAmount': savingsCurrentAmount,
      'notificationsEnabled': notificationsEnabled,
    };
  }

  // Load from Firestore
  factory UserModel.fromMap(String id, Map<String, dynamic> map) {
    return UserModel(
      id: id,
      name: map['name'] ?? 'User',
      email: map['email'] ?? '',
      photoUrl: map['photoUrl'] ?? '',
      monthlySavingsGoal: (map['monthlySavingsGoal'] ?? 0).toDouble(),
      savingsCurrentAmount: (map['savingsCurrentAmount'] ?? 0).toDouble(),
      notificationsEnabled: map['notificationsEnabled'] ?? true,
    );
  }
}