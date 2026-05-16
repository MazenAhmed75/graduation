import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/budget_template_model.dart';
import '../models/budget_model.dart';
import '../services/budget_service.dart';

// ============================================================
// TemplateService
//
// Handles all budget template logic:
//   - Saving the current month's categories as a template
//   - Streaming the user's saved templates for display
//   - Applying a template to a new month (creates all categories)
//   - Deleting a template
//
// USAGE FLOW:
//   1. User sets up categories for the month
//   2. Taps "Save as Template" → _templateService.saveTemplate(...)
//   3. Next month: taps "Use Template" → picks one
//   4. _templateService.applyTemplate(...) creates all categories
// ============================================================
class TemplateService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final BudgetService _budgetService = BudgetService();

  // ── Firestore reference ──────────────────────────────────────
  CollectionReference _templatesRef(String userId) => _firestore
      .collection('users')
      .doc(userId)
      .collection('budgetTemplates');

  // ============================================================
  // SAVE: Snapshot the current month's categories as a template
  //
  // Call this when the user taps "Save as Template".
  // Pass the current categories list from the StreamBuilder.
  // ============================================================
  Future<void> saveTemplate({
    required String userId,
    required String name,
    required double totalAmount,
    required List<BudgetModel> categories,
  }) async {
    final docRef = _templatesRef(userId).doc();

    // Convert BudgetModel list → TemplateCategory list
    // (only saves title, subtitle, allocated, icon, color — not spent)
    final templateCategories = categories
        .map((b) => TemplateCategory(
      title: b.title,
      subtitle: b.subtitle,
      allocated: b.allocated,
      iconName: b.iconName,
      colorScheme: b.colorScheme,
    ))
        .toList();

    final template = BudgetTemplateModel(
      id: docRef.id,
      userId: userId,
      name: name,
      totalAmount: totalAmount,
      categories: templateCategories,
      createdAt: DateTime.now(),
    );

    await docRef.set(template.toMap());
  }

  // ============================================================
  // STREAM: Get all saved templates for display in picker
  // ============================================================
  Stream<List<BudgetTemplateModel>> getTemplatesStream(String userId) {
    return _templatesRef(userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => BudgetTemplateModel.fromMap(
        doc.id, doc.data() as Map<String, dynamic>))
        .toList());
  }

  // ============================================================
  // APPLY: Create all categories from a template into a month
  //
  // Call this after the user picks a template.
  // It calls the existing BudgetService.addBudget() for each
  // category — so all existing validation still applies.
  // ============================================================
  Future<void> applyTemplate({
    required String userId,
    required String monthId,
    required BudgetTemplateModel template,
  }) async {
    // Create each category from the template in order
    for (final category in template.categories) {
      await _budgetService.addBudget(
        userId: userId,
        monthlyBudgetId: monthId,
        title: category.title,
        subtitle: category.subtitle,
        allocated: category.allocated,
        iconName: category.iconName,
        colorScheme: category.colorScheme,
      );
    }
  }

  // ============================================================
  // DELETE: Remove a saved template permanently
  // ============================================================
  Future<void> deleteTemplate({
    required String userId,
    required String templateId,
  }) async {
    await _templatesRef(userId).doc(templateId).delete();
  }

  // ============================================================
  // RENAME: Update a template's display name
  // ============================================================
  Future<void> renameTemplate({
    required String userId,
    required String templateId,
    required String newName,
  }) async {
    await _templatesRef(userId)
        .doc(templateId)
        .update({'name': newName});
  }
}