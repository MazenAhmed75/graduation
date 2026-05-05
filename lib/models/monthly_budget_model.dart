import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents the total budget a user sets for a given month.
/// The document ID in Firestore is the month string, e.g. "2026-05".
class MonthlyBudgetModel {
  final String id;          // "2026-05"
  final String userId;
  final double totalAmount;
  final DateTime createdAt;

  const MonthlyBudgetModel({
    required this.id,
    required this.userId,
    required this.totalAmount,
    required this.createdAt,
  });

  factory MonthlyBudgetModel.fromMap(String id, Map<String, dynamic> map) {
    return MonthlyBudgetModel(
      id: id,
      userId: map['userId'] as String,
      totalAmount: (map['totalAmount'] as num).toDouble(),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() => {
    'userId': userId,
    'totalAmount': totalAmount,
    'createdAt': Timestamp.fromDate(createdAt),
  };
}