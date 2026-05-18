// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appName => 'المنسق الواعي';

  @override
  String get goodMorning => 'صباح الخير';

  @override
  String get goodAfternoon => 'مساء النور';

  @override
  String get goodEvening => 'مساء الخير';

  @override
  String get welcomeBack => 'مرحباً بعودتك';

  @override
  String get monthlyBudget => 'الميزانية الشهرية';

  @override
  String get monthlyBudgetGoal => 'هدف المدخرات الشهري';

  @override
  String get totalBudget => 'إجمالي الميزانية';

  @override
  String get totalSpent => 'إجمالي المصروفات';

  @override
  String get totalSaved => 'إجمالي المدخرات';

  @override
  String get remaining => 'المتبقي';

  @override
  String get available => 'المتاح';

  @override
  String daysLeft(int days) {
    return 'باقي $days يوم هذا الشهر';
  }

  @override
  String get completed => 'مكتمل';

  @override
  String get thisMonth => 'هذا الشهر';

  @override
  String get spent => 'المصروف';

  @override
  String get saved => 'وُفِّر';

  @override
  String get spendingBreakdown => 'تفاصيل الإنفاق';

  @override
  String get allOnTrack => 'جميع الفئات في المسار الصحيح';

  @override
  String get nearLimit => 'قريبة من الحد';

  @override
  String get noSpendingYet => 'لا يوجد إنفاق مسجل بعد';

  @override
  String get noSpendingDesc => 'سيظهر مخطط إنفاقك هنا بمجرد تسجيل أول مصروف.';

  @override
  String get budgets => 'الميزانيات';

  @override
  String get addBudget => 'إضافة ميزانية';

  @override
  String get editBudget => 'تعديل الميزانية';

  @override
  String get deleteBudget => 'حذف الميزانية';

  @override
  String get noBudgets => 'لا توجد ميزانيات بعد';

  @override
  String get noBudgetsDesc => 'اضغط على زر + لإنشاء أول فئة ميزانية.';

  @override
  String get categoryName => 'اسم الفئة';

  @override
  String get categorySubtitle => 'وصف مختصر (اختياري)';

  @override
  String get allocatedAmount => 'المبلغ المخصص';

  @override
  String get categories => 'الفئات';

  @override
  String get saveAsTemplate => 'حفظ كقالب';

  @override
  String get useTemplate => 'استخدام قالب';

  @override
  String get useSavedTemplate => 'استخدام قالب محفوظ';

  @override
  String get subtractMoney => 'خصم مبلغ (إنفاق)';

  @override
  String get addMoney => 'إضافة مبلغ (دخل)';

  @override
  String get amount => 'المبلغ';

  @override
  String get note => 'ملاحظة';

  @override
  String get noteHint => 'مثال: اشتراك نتفليكس';

  @override
  String get makeRecurring => 'جعله متكرراً';

  @override
  String get everyMonth => 'كل شهر';

  @override
  String get everyWeek => 'كل أسبوع';

  @override
  String get expenseLabel => 'مصروف';

  @override
  String get incomeLabel => 'دخل';

  @override
  String get profile => 'الملف الشخصي';

  @override
  String get fullName => 'الاسم الكامل';

  @override
  String get email => 'البريد الإلكتروني';

  @override
  String get free => 'مجاني';

  @override
  String get upgrade => 'ترقية';

  @override
  String get notifications => 'الإشعارات';

  @override
  String get language => 'اللغة';

  @override
  String get logoutConfirmBody => 'هل أنت متأكد أنك تريد تسجيل الخروج؟';

  @override
  String get photoFailed => 'فشل رفع الصورة';

  @override
  String get ok => 'حسناً';

  @override
  String get home => 'الرئيسية';

  @override
  String get invest => 'استثمار';

  @override
  String get loading => 'جارٍ التحميل...';

  @override
  String get userDataNotFound => 'لم يتم العثور على بيانات المستخدم';

  @override
  String get newBudget => 'ميزانية جديدة';

  @override
  String get reports => 'التقارير';

  @override
  String get insights => 'التحليلات';

  @override
  String get reportsComingSoon => 'التقارير قريباً!';

  @override
  String get insightsComingSoon => 'التحليلات قريباً!';

  @override
  String get activeBudgets => 'الميزانيات النشطة';

  @override
  String get manage => 'إدارة';

  @override
  String get noBudgetsYet => 'لا توجد ميزانيات بعد';

  @override
  String get tapNewBudgetToStart => 'اضغط على \"ميزانية جديدة\" للبدء';

  @override
  String get createFirstBudget => 'إنشاء أول ميزانية';

  @override
  String get editSavingsGoal => 'تعديل هدف الادخار';

  @override
  String get monthlyGoal => 'الهدف الشهري';

  @override
  String get enterMonthlySavingsGoal => 'أدخل هدف الادخار الشهري';

  @override
  String get emailAddress => 'البريد الإلكتروني';

  @override
  String get password => 'كلمة المرور';

  @override
  String get enterEmail => 'الرجاء إدخال البريد الإلكتروني';

  @override
  String get validEmail => 'أدخل بريد إلكتروني صحيح';

  @override
  String get enterPassword => 'الرجاء إدخال كلمة المرور';

  @override
  String get passwordMin => 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';

  @override
  String get forgotPassword => 'نسيت كلمة المرور؟';

  @override
  String get signIn => 'تسجيل الدخول';

  @override
  String get continueGoogle => 'المتابعة باستخدام Google';

  @override
  String get dontHaveAccount => 'ليس لديك حساب؟';

  @override
  String get signUp => 'إنشاء حساب';

  @override
  String get welcomeLogin => 'مرحباً بعودتك! سجل الدخول للمتابعة';

  @override
  String welcomeUser(String name) {
    return 'مرحباً بعودتك، $name!';
  }

  @override
  String daysLeftText(int days) {
    return 'متبقي $days يوم';
  }

  @override
  String savedGoalText(String saved, String goal) {
    return 'تم توفير $saved • الهدف $goal';
  }

  @override
  String amountLeftText(String amount) {
    return 'متبقي $amount';
  }

  @override
  String get createAccount => 'إنشاء حساب';

  @override
  String get registerSubtitle => 'ابدأ رحلتك المالية الواعية';

  @override
  String get alreadyHaveAccount => 'لديك حساب بالفعل؟';

  @override
  String get fullNameHint => 'أدخل اسمك';

  @override
  String get emailHint => 'you@example.com';

  @override
  String get passwordHint => '6 أحرف على الأقل';

  @override
  String get confirmPasswordHint => 'أعد إدخال كلمة المرور';

  @override
  String get enterNameError => 'من فضلك أدخل الاسم';

  @override
  String get nameTooShortError => 'يجب أن يكون الاسم حرفين على الأقل';

  @override
  String get enterEmailError => 'من فضلك أدخل البريد الإلكتروني';

  @override
  String get validEmailError => 'أدخل بريد إلكتروني صحيح';

  @override
  String get enterPasswordError => 'من فضلك أدخل كلمة المرور';

  @override
  String get passwordLengthError => 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';

  @override
  String get confirmPasswordError => 'من فضلك أكد كلمة المرور';

  @override
  String get passwordMismatchError => 'كلمتا المرور غير متطابقتين';

  @override
  String get accountCreatedSuccess => 'تم إنشاء الحساب بنجاح!';

  @override
  String get aiInvest => 'الاستثمار الذكي';

  @override
  String get dashboard => 'لوحة التحكم';

  @override
  String get markets => 'الأسواق';

  @override
  String get aiAdvisor => 'المساعد الذكي';

  @override
  String get positions => 'المراكز';

  @override
  String get connectAlpacaAccount => 'ربط حساب Alpaca';

  @override
  String get alpacaDescription =>
      'تداول الذهب والفضة والبيتكوين والإيثريوم والأسهم من حساب واحد.\n\nابدأ بالتداول التجريبي مجانًا (100 ألف دولار وهمي).';

  @override
  String get connectAlpacaFirst => 'قم بربط Alpaca أولاً';

  @override
  String get noOpenPositions => 'لا توجد مراكز مفتوحة';

  @override
  String get connectToSeePositions => 'اربط Alpaca لرؤية مراكزك';

  @override
  String get chatHint =>
      'اسأل أي شيء — تحليل المحفظة، شراء الذهب، توقعات السوق...';

  @override
  String get loadingAgent => 'جاري تحميل الذكاء الاصطناعي...';

  @override
  String get aiAnalyzing => 'الذكاء الاصطناعي يحلل البيانات...';

  @override
  String get livePrices => 'الأسعار المباشرة';

  @override
  String get updated => 'تم التحديث';

  @override
  String get connectAlpaca => 'ربط ألباكا';

  @override
  String get refresh => 'تحديث';

  @override
  String get live => 'مباشر';

  @override
  String get alpacaIntro =>
      'تداول الذهب والفضة والبيتكوين والإيثريوم والأسهم — كل ذلك من حساب واحد.\n\nابدأ بالتداول التجريبي المجاني (100 ألف دولار افتراضي).';

  @override
  String get chatWithAi => 'أو فقط تحدث مع الذكاء الاصطناعي ←';

  @override
  String get metals => 'المعادن';

  @override
  String get crypto => 'العملات الرقمية';

  @override
  String get usStocks => 'الأسهم الأمريكية';

  @override
  String get showOpportunities => 'عرض الفرص';

  @override
  String get investBestPick => 'استثمر in أفضل فرصة';

  @override
  String get fullAutoScan => 'فحص تلقائي كامل';

  @override
  String get portfolioReview => 'مراجعة المحفظة';

  @override
  String get lockInGains => 'تثبيت الأرباح';

  @override
  String get execute => 'تنفيذ';

  @override
  String get noAlpacaConnected => 'لا يوجد حساب ألباكا متصل';

  @override
  String get connectAlpacaPositions => 'قم بربط ألباكا لرؤية مراكزك المباشرة';

  @override
  String get openPositions => 'المراكز المفتوحة';

  @override
  String get dashboardOpportunities =>
      'استخدم لوحة التحكم لاكتشاف فرص الاستثمار';

  @override
  String get closePosition => 'إغلاق المركز';

  @override
  String get livePortfolio => 'المحفظة المباشرة';

  @override
  String get autoRefresh30s => 'تحديث تلقائي كل 30 ثانية';

  @override
  String get entryPrice => 'سعر الدخول';

  @override
  String get currentPrice => 'السعر الحالي';

  @override
  String get marketValue => 'القيمة السوقية';

  @override
  String get sellPosition => 'بيع المركز';

  @override
  String get value => 'القيمة';

  @override
  String get profitLoss => 'الربح والخسارة';

  @override
  String tradeBuy(Object amount, Object asset) {
    return 'صفقة: شراء \$ $amount من $asset';
  }

  @override
  String tradeSell(Object percent, Object asset) {
    return 'صفقة: بيع $percent% من $asset';
  }

  @override
  String positionClosed(Object name) {
    return '✅ تم إغلاق $name — تم إرسال الطلب';
  }

  @override
  String get autoTradeDisabled => 'تم إيقاف التداول التلقائي بواسطة المستخدم';

  @override
  String get autoTradeEnabled =>
      'تم تفعيل التداول التلقائي. سيتم تشغيل التحليل كل ساعة في الخلفية';

  @override
  String autoSold(Object symbol) {
    return 'تم البيع التلقائي لـ $symbol بسعر السوق';
  }

  @override
  String autoSellFailed(Object error) {
    return 'فشل البيع التلقائي: $error';
  }

  @override
  String aiFoundOpportunities(Object count) {
    return 'وجد الذكاء الاصطناعي $count فرصة شراء وتحتاج إلى موافقتك';
  }

  @override
  String get view => 'عرض';

  @override
  String notOnAlpacaYet(Object asset) {
    return '$asset غير متوفر على Alpaca حالياً';
  }

  @override
  String boughtAsset(Object amount, Object asset) {
    return 'تم شراء \$ $amount من $asset';
  }

  @override
  String get confirmBuy => 'تأكيد الشراء';

  @override
  String get confirmSell => 'تأكيد البيع';

  @override
  String buyAssetAmount(Object amount, Object asset) {
    return 'شراء \$ $amount من $asset';
  }

  @override
  String sellAssetPercent(Object percent, Object asset) {
    return 'بيع $percent% من $asset';
  }

  @override
  String get alpacaSymbol => 'رمز Alpaca';

  @override
  String get realOrderWarning => 'سيتم تنفيذ أمر حقيقي على Alpaca';

  @override
  String get paperTradeWarning => 'تداول تجريبي — لا يتم استخدام أموال حقيقية';

  @override
  String get executeBuy => 'تنفيذ الشراء';

  @override
  String get executeSell => 'تنفيذ البيع';

  @override
  String get boughtOrderSubmitted => 'تم إرسال أمر الشراء إلى Alpaca';

  @override
  String get soldOrderSubmitted => 'تم إرسال أمر البيع إلى Alpaca';

  @override
  String get units => 'وحدات';

  @override
  String get unrealizedPnL => 'الأرباح والخسائر غير المحققة';

  @override
  String cashBuyingPower(Object cash, Object power) {
    return 'الرصيد النقدي: \$ $cash • القوة الشرائية: $power';
  }

  @override
  String get pnl => 'الأرباح والخسائر';

  @override
  String get closePositionButton => 'إغلاق الصفقة';

  @override
  String closedPositionOrderSubmitted(Object asset) {
    return 'تم إغلاق $asset وإرسال الطلب';
  }

  @override
  String get alpacaSettingsTitle => 'ربط حساب ألباكا';

  @override
  String get alpacaHowToTitle => '🔗 كيفية الحصول على مفاتيح API';

  @override
  String get alpacaStep1 => 'قم بإنشاء حساب مجاني في alpaca.markets';

  @override
  String get alpacaStep2 => 'اذهب إلى التداول التجريبي ← مفاتيح API';

  @override
  String get alpacaStep3 => 'أنشئ مفتاحًا جديدًا ثم انسخ القيمتين بالأسفل';

  @override
  String get alpacaStep4 =>
      'ابدأ بالوضع التجريبي (أموال افتراضية) للتجربة بأمان';

  @override
  String get alpacaPaperInfo =>
      '💰 يمنحك ألباكا 100,000 دولار افتراضي في الوضع التجريبي.';

  @override
  String get alpacaTradingMode => 'وضع التداول';

  @override
  String get alpacaPaperMode => '📄 تجريبي (آمن)';

  @override
  String get alpacaLiveMode => '💵 حقيقي (أموال حقيقية)';

  @override
  String get alpacaLiveWarning =>
      '⚠️ الوضع الحقيقي يستخدم أموالًا حقيقية. تأكد من فهم المخاطر.';

  @override
  String get alpacaApiKey => 'معرف مفتاح API';

  @override
  String get alpacaApiKeyHint => 'PKXXXXXXXXXXXXXXXXXXXXXXXX';

  @override
  String get alpacaSecretKey => 'المفتاح السري لـ API';

  @override
  String get alpacaSecretHint => '••••••••••••••••••••••••••••••••••••••••';

  @override
  String get alpacaConnectButton => 'ربط واختبار';

  @override
  String get alpacaTesting => 'جارٍ اختبار الاتصال...';

  @override
  String get alpacaMissingFields => 'يرجى إدخال مفتاح API والمفتاح السري';

  @override
  String get alpacaConnectionFailed => 'فشل الاتصال. تحقق من المفاتيح.';

  @override
  String get alpacaConnectedSnackbar => '✅ تم ربط ألباكا بنجاح! جاهز للتداول.';

  @override
  String get alpacaConnected => '✅ تم الاتصال!';

  @override
  String get alpacaCash => 'الرصيد النقدي';

  @override
  String get alpacaBuyingPower => 'القوة الشرائية';

  @override
  String get alpacaPortfolioValue => 'قيمة المحفظة';

  @override
  String get alpacaStatus => 'الحالة';

  @override
  String get notLoggedIn => 'لم تسجّل الدخول.';

  @override
  String setMonthlyBudget(String monthName) {
    return 'تعيين ميزانية $monthName';
  }

  @override
  String get editMonthlyBudget => 'تعديل الميزانية الشهرية';

  @override
  String get monthlyBudgetDescription =>
      'هذا هو الحد الإجمالي للإنفاق لهذا الشهر.';

  @override
  String get totalMonthlyBudget => 'إجمالي الميزانية الشهرية';

  @override
  String get totalMonthlyBudgetLabel => 'إجمالي الميزانية الشهرية';

  @override
  String get fullyAllocated => 'مُخصَّص بالكامل';

  @override
  String fullyAllocatedDescription(String amount) {
    return 'لقد خصصت كامل مبلغ $amount. قم بتعديل أو حذف فئة لتحرير مبلغ.';
  }

  @override
  String get addCategoryBudget => 'إضافة فئة ميزانية';

  @override
  String availableToAssign(String amount) {
    return '$amount متاح للتخصيص';
  }

  @override
  String get groceriesHint => 'مثال: البقالة';

  @override
  String maxAmount(String amount) {
    return 'الحد الأقصى $amount';
  }

  @override
  String get newCategory => 'فئة جديدة';

  @override
  String get category => 'فئة';

  @override
  String amountExceedsRemaining(String amount) {
    return 'المبلغ يتجاوز المتبقي $amount';
  }

  @override
  String get addMoneyDeposit => 'إضافة مبلغ (إيداع)';

  @override
  String get subtractMoneySpend => 'خصم مبلغ (إنفاق)';

  @override
  String get noteOptional => 'ملاحظة (اختياري)';

  @override
  String get salaryHint => 'مثال: الراتب';

  @override
  String get netflixHint => 'مثال: نتفليكس';

  @override
  String get editBudgetAmount => 'تعديل مبلغ الميزانية';

  @override
  String deleteBudgetQuestion(String title) {
    return 'هل تريد حذف \"$title\"؟ لا يمكن التراجع عن هذا.';
  }

  @override
  String get allocatedToCategories => 'المخصص للفئات';

  @override
  String get unallocated => 'غير مخصص';

  @override
  String get fullyAllocatedCheck => '✓ مخصص بالكامل';

  @override
  String get noCategoriesYet => 'لا توجد فئات بعد';

  @override
  String get divideBudgetHint => 'اضغط + لتقسيم ميزانيتك إلى فئات.';

  @override
  String spentAmount(String amount) {
    return 'المُنفق: $amount';
  }

  @override
  String leftAmount(String amount) {
    return 'المتبقي: $amount';
  }

  @override
  String get useAsTemplate => 'استخدام قالب';

  @override
  String get pickTemplate => 'اختر قالباً محفوظاً لتطبيقه.';

  @override
  String get noTemplatesYet => 'لا توجد قوالب بعد';

  @override
  String templateDescription(String count) {
    return 'حفظ هذه الـ $count فئات ومبالغها كقالب قابل لإعادة الاستخدام.';
  }

  @override
  String get templateName => 'اسم القالب';

  @override
  String get monthlyBudgetTemplate => 'قالب الميزانية الشهرية';

  @override
  String get saveTemplate => 'حفظ القالب';

  @override
  String templateSaved(String name) {
    return '✅ تم حفظ \"$name\" كقالب!';
  }

  @override
  String get transactionHistory => 'سجل المعاملات';

  @override
  String get addCategoryFirst => 'أضف فئة واحدة على الأقل قبل حفظ القالب.';

  @override
  String defaultTemplateName(String monthName) {
    return 'قالب $monthName';
  }

  @override
  String templateSummary(String count, String total) {
    return '$count فئات · الإجمالي $total';
  }

  @override
  String get noTemplatesHint =>
      'احفظ إعداد ميزانيتك الحالية كقالب لإعادة استخدامه الشهر القادم.';

  @override
  String templateApplied(String name) {
    return '✅ تم تطبيق \"$name\"! يمكنك تعديل المبالغ حسب الحاجة.';
  }

  @override
  String get failedToLoadCategories => 'فشل تحميل الفئات';

  @override
  String noBudgetForMonth(Object monthName) {
    return 'لا توجد ميزانية لـ $monthName';
  }

  @override
  String get budgetSetupDescription =>
      'حدد المبلغ الإجمالي ثم وزّعه على الفئات.';

  @override
  String get addCategoryBeforeTemplate =>
      'أضف فئة واحدة على الأقل قبل حفظ القالب.';

  @override
  String get use => 'استخدام';

  @override
  String get edit => 'تعديل';

  @override
  String get setupMonthTemplate =>
      'قم بإعداد ميزانية الشهر ثم اضغط على \"حفظ كقالب\".';

  @override
  String get add => 'إضافة';

  @override
  String get resetPassword => 'إعادة تعيين كلمة المرور';

  @override
  String get resetPasswordDescription =>
      'أدخل البريد الإلكتروني المرتبط بحسابك وسنرسل إليك رسالة تحتوي على تعليمات لإعادة تعيين كلمة المرور.';

  @override
  String get resetPasswordEmailSentDescription =>
      'تحقق من بريدك الإلكتروني للحصول على رابط إعادة تعيين كلمة المرور. إذا لم يظهر خلال بضع دقائق، تحقق من مجلد الرسائل غير المرغوب فيها.';

  @override
  String get pleaseEnterEmail => 'يرجى إدخال بريدك الإلكتروني';

  @override
  String get pleaseEnterValidEmail => 'يرجى إدخال بريد إلكتروني صالح';

  @override
  String get sendResetLink => 'إرسال رابط إعادة التعيين';

  @override
  String get backToLogin => 'العودة لتسجيل الدخول';

  @override
  String get passwordResetEmailSent =>
      'تم إرسال رابط إعادة تعيين كلمة المرور إلى بريدك الإلكتروني!';

  @override
  String get choosePhotoSource => 'اختر مصدر الصورة';

  @override
  String get takePhoto => 'التقاط صورة';

  @override
  String get chooseFromGallery => 'اختر من المعرض';

  @override
  String get uploadingPhoto => 'جارٍ رفع الصورة...';

  @override
  String get profileUpdated => 'تم تحديث صورة الملف الشخصي!';

  @override
  String get uploadFailed => 'فشل رفع الصورة';

  @override
  String get account => 'الحساب';

  @override
  String get membership => 'العضوية';

  @override
  String get settings => 'الإعدادات';

  @override
  String get currentPlan => 'الخطة الحالية';

  @override
  String get privacySecurity => 'الخصوصية والأمان';

  @override
  String get logout => 'تسجيل الخروج';

  @override
  String get logoutConfirmTitle => 'تسجيل الخروج';

  @override
  String get logoutConfirmMessage => 'هل أنت متأكد أنك تريد تسجيل الخروج؟';

  @override
  String get cancel => 'إلغاء';

  @override
  String get editName => 'تعديل الاسم';

  @override
  String get save => 'حفظ';

  @override
  String get appVersion => 'إصدار التطبيق 1.0.0';

  @override
  String get recurring => 'المعاملات المتكررة';

  @override
  String get noRecurringTitle => 'لا توجد معاملات متكررة';

  @override
  String get noRecurringSubtitle =>
      'عند إضافة أو صرف المال، فعّل خيار \"تكرار\" لجعلها تتكرر تلقائياً.';

  @override
  String get deleteRecurringTitle => 'حذف المعاملة المتكررة؟';

  @override
  String deleteRecurringMessage(Object note) {
    return 'لن يتم تطبيق \"$note\" تلقائياً بعد الآن.';
  }

  @override
  String get delete => 'حذف';

  @override
  String get next => 'التالي';

  @override
  String get monthJan => 'يناير';

  @override
  String get monthFeb => 'فبراير';

  @override
  String get monthMar => 'مارس';

  @override
  String get monthApr => 'أبريل';

  @override
  String get monthMay => 'مايو';

  @override
  String get monthJun => 'يونيو';

  @override
  String get monthJul => 'يوليو';

  @override
  String get monthAug => 'أغسطس';

  @override
  String get monthSep => 'سبتمبر';

  @override
  String get monthOct => 'أكتوبر';

  @override
  String get monthNov => 'نوفمبر';

  @override
  String get monthDec => 'ديسمبر';

  @override
  String nextDue(Object date) {
    return 'التالي: $date';
  }

  @override
  String get transactions => 'المعاملات';

  @override
  String get searchHint => 'ابحث بالوصف أو التصنيف…';

  @override
  String get newest => 'الأحدث';

  @override
  String get largest => 'الأكبر';

  @override
  String get all => 'الكل';

  @override
  String get expenses => 'المصروفات';

  @override
  String get income => 'الدخل';

  @override
  String get allCategories => 'كل التصنيفات';

  @override
  String get today => 'اليوم';

  @override
  String get yesterday => 'أمس';

  @override
  String get noResults => 'لا توجد نتائج';

  @override
  String get noTransactions => 'لا توجد معاملات';

  @override
  String get noResultsHint => 'حاول تعديل البحث أو الفلاتر.';

  @override
  String get noTransactionsHint =>
      'ستظهر معاملاتك هنا\nعند البدء بالصرف أو الإيداع.';

  @override
  String get clearFilters => 'مسح كل الفلاتر';

  @override
  String get auto => 'تلقائي';

  @override
  String transactionsCount(String count) {
    return '$count معاملة';
  }

  @override
  String get autoPrefix => '[تلقائي] ';

  @override
  String get autoLabel => 'تلقائي';

  @override
  String get am => 'ص';

  @override
  String get pm => 'م';

  @override
  String get privacyAndSecurity => 'الخصوصية والأمان';

  @override
  String get securitySettings => 'إعدادات الأمان';

  @override
  String get googleAccountManaged => 'حسابك تتم إدارته عبر Google.';

  @override
  String get keepAccountSecure =>
      'حافظ على أمان حسابك عبر تحديث كلمة المرور بانتظام.';

  @override
  String get signedInWithGoogle => 'تم تسجيل الدخول عبر Google';

  @override
  String get googlePasswordInfo =>
      'بما أنك تستخدم تسجيل الدخول عبر Google، يمكنك إدارة كلمة المرور من إعدادات حساب Google.';

  @override
  String get currentPassword => 'كلمة المرور الحالية';

  @override
  String get newPassword => 'كلمة المرور الجديدة';

  @override
  String get confirmNewPassword => 'تأكيد كلمة المرور الجديدة';

  @override
  String get updatePassword => 'تحديث كلمة المرور';

  @override
  String get fieldRequired => 'هذا الحقل مطلوب';

  @override
  String get passwordsDoNotMatch => 'كلمتا المرور غير متطابقتين';

  @override
  String get passwordTooShort => 'يجب أن تكون 6 أحرف على الأقل';

  @override
  String get passwordUpdatedSuccess => 'تم تحديث كلمة المرور بنجاح!';

  @override
  String get spendingInsights => 'تحليلات الإنفاق';

  @override
  String onTrack(int count) {
    return '$count على المسار الصحيح';
  }

  @override
  String overBudget(int count) {
    return '$count تجاوزوا الميزانية';
  }

  @override
  String get addBudgetCategoriesInsights =>
      'أضف فئات الميزانية لعرض التحليلات.';

  @override
  String overBudgetInsight(Object amount) {
    return 'لقد تجاوزت الميزانية بمقدار $amount.';
  }

  @override
  String nearlyAtLimitInsight(Object amount) {
    return 'تبقى $amount فقط قبل الوصول للحد.';
  }

  @override
  String usedPercentInsight(Object percent, Object days) {
    return 'استخدمت $percent% من ميزانيتك مع بقاء $days يوم.';
  }

  @override
  String halfwayBudgetInsight(Object amount) {
    return 'تبقى لديك نصف الميزانية: $amount.';
  }

  @override
  String savedThisMonthInsight(Object amount) {
    return 'رائع! لقد وفرت $amount هذا الشهر.';
  }

  @override
  String noSpendingInsight(Object amount) {
    return 'لا يوجد إنفاق بعد. لديك $amount متاح.';
  }

  @override
  String onTrackInsight(Object amount) {
    return 'أنت على المسار الصحيح ويتبقى $amount.';
  }

  @override
  String budgetFullyUsedInsight(Object days) {
    return 'تم استخدام الميزانية بالكامل. قد تنفد خلال $days يوم.';
  }

  @override
  String get spendingReport => 'تقرير المصاريف';

  @override
  String get breakdown => 'تفصيل';

  @override
  String get byCategory => 'حسب الفئة';

  @override
  String get allocated => 'المخصص';

  @override
  String get used => 'المستخدم';

  @override
  String get noBudgetData => 'لا توجد بيانات للميزانية لعرضها';

  @override
  String get aiInsightLabel => 'رؤية مالية ذكية';

  @override
  String get aiInsightRefreshTooltip => 'تحديث';

  @override
  String get aiInsightJustNow => 'الآن';

  @override
  String aiInsightMinutesAgo(int n) {
    return 'منذ $n د';
  }

  @override
  String aiInsightHoursAgo(int n) {
    return 'منذ $n س';
  }

  @override
  String get aiInsightErrorMsg => 'تعذّر تحميل الرؤية الذكية.';

  @override
  String get aiInsightRetryBtn => 'إعادة المحاولة';

  @override
  String get budgetsScreenTitle => 'الميزانية';

  @override
  String get reportsTitle => 'التقارير';

  @override
  String get localInsightsSectionTitle => 'ملاحظات فورية';

  @override
  String insightHighestSpending(String category, String percent) {
    return '$category هو أكبر نفقاتك بنسبة $percent من ميزانيته.';
  }

  @override
  String insightOverBudget(String categories) {
    return 'لقد تجاوزت ميزانيتك في: $categories.';
  }

  @override
  String insightWarningTotal(String percent) {
    return 'لقد استخدمت $percent من إجمالي ميزانيتك الشهرية — تمهّل!';
  }

  @override
  String insightGreatProgress(String percent) {
    return 'انضباط رائع! لم تنفق سوى $percent من ميزانيتك حتى الآن.';
  }

  @override
  String insightUnderUtilized(String categories) {
    return 'إنفاق منخفض في $categories — فكّر في إعادة توزيع الفائض.';
  }

  @override
  String insightNearLimit(String category, String percent) {
    return '$category على وشك الوصول إلى حدّه ($percent).';
  }
}
