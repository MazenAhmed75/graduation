import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/budget_template_model.dart';
import '../models/budget_model.dart';
import '../services/budget_service.dart';
import '../utils/budget_categories.dart';

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
      title: b.customTitle.isNotEmpty ? b.customTitle : b.categoryKey,
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
  // ============================================================
  // APPLY: Create all categories from a template into a month
  //
  // UPDATED: Now requires [existingCategories] to be passed in.
  // We delete existing categories first to prevent duplicate
  // categories and ensure the allocation doesn't overflow.
  // ============================================================
  Future<void> applyTemplate({
    required String userId,
    required String monthId,
    required BudgetTemplateModel template,
    required List<BudgetModel> existingCategories,
  }) async {

    // 1. CLEAR EXISTING CATEGORIES
    // Why: We delete all existing categories to ensure a clean slate.
    // This prevents duplicated items (e.g., having two "Groceries" budgets)
    // and prevents the combined total from exceeding the monthly limit.
    for (final budget in existingCategories) {
      await _budgetService.deleteBudget(
        userId: userId,
        budgetId: budget.id,
      );
    }

    // 2. CREATE TEMPLATE CATEGORIES
    // Why: Now that the month is clean, we can safely loop through
    // the template categories and recreate them without clashes.
    for (final category in template.categories) {


      //  Check if the saved title matches a built-in system key (e.g., 'groceries')
      final isSystemCategory = budgetCategories.any((c) => c.key == category.title);

      // If it's a built-in system key, restore its proper core key and leave customTitle empty.
      // If it's a user-written name, treat it as a true 'custom' category.
      final finalCategoryKey = isSystemCategory ? category.title : 'custom';
      final finalCustomTitle = isSystemCategory ? '' : category.title;



      await _budgetService.addBudget(
        userId: userId,
        monthlyBudgetId: monthId,
        categoryKey: finalCategoryKey,     // Tells the app this is a user-defined custom budget  // 👈 Fixes localization mapping!
        customTitle: finalCustomTitle, // Puts the template name (e.g., "Books") here   // 👈 Keeps text blank for default categories
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