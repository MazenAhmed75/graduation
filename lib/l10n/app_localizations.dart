import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Mindful Curator'**
  String get appName;

  /// No description provided for @goodMorning.
  ///
  /// In en, this message translates to:
  /// **'Good Morning'**
  String get goodMorning;

  /// No description provided for @goodAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good Afternoon'**
  String get goodAfternoon;

  /// No description provided for @goodEvening.
  ///
  /// In en, this message translates to:
  /// **'Good Evening'**
  String get goodEvening;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get welcomeBack;

  /// No description provided for @monthlyBudget.
  ///
  /// In en, this message translates to:
  /// **'Monthly Budget'**
  String get monthlyBudget;

  /// No description provided for @monthlyBudgetGoal.
  ///
  /// In en, this message translates to:
  /// **'Monthly Savings Goal'**
  String get monthlyBudgetGoal;

  /// No description provided for @totalBudget.
  ///
  /// In en, this message translates to:
  /// **'Total Budget'**
  String get totalBudget;

  /// No description provided for @totalSpent.
  ///
  /// In en, this message translates to:
  /// **'Total Spent'**
  String get totalSpent;

  /// No description provided for @totalSaved.
  ///
  /// In en, this message translates to:
  /// **'Total Saved'**
  String get totalSaved;

  /// No description provided for @remaining.
  ///
  /// In en, this message translates to:
  /// **'Remaining'**
  String get remaining;

  /// No description provided for @available.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get available;

  /// No description provided for @completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completed;

  /// No description provided for @thisMonth.
  ///
  /// In en, this message translates to:
  /// **'this month'**
  String get thisMonth;

  /// No description provided for @spent.
  ///
  /// In en, this message translates to:
  /// **'Spent'**
  String get spent;

  /// No description provided for @saved.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get saved;

  /// No description provided for @spendingBreakdown.
  ///
  /// In en, this message translates to:
  /// **'Spending Breakdown'**
  String get spendingBreakdown;

  /// No description provided for @allOnTrack.
  ///
  /// In en, this message translates to:
  /// **'All categories on track'**
  String get allOnTrack;

  /// No description provided for @nearLimit.
  ///
  /// In en, this message translates to:
  /// **'near limit'**
  String get nearLimit;

  /// No description provided for @noSpendingYet.
  ///
  /// In en, this message translates to:
  /// **'No spending recorded yet'**
  String get noSpendingYet;

  /// No description provided for @noSpendingDesc.
  ///
  /// In en, this message translates to:
  /// **'Your spending chart will appear here once you log your first expense.'**
  String get noSpendingDesc;

  /// No description provided for @budgets.
  ///
  /// In en, this message translates to:
  /// **'Budgets'**
  String get budgets;

  /// No description provided for @addBudget.
  ///
  /// In en, this message translates to:
  /// **'Add Budget'**
  String get addBudget;

  /// No description provided for @editBudget.
  ///
  /// In en, this message translates to:
  /// **'Edit Budget'**
  String get editBudget;

  /// No description provided for @deleteBudget.
  ///
  /// In en, this message translates to:
  /// **'Delete Budget'**
  String get deleteBudget;

  /// No description provided for @noBudgets.
  ///
  /// In en, this message translates to:
  /// **'No budgets yet'**
  String get noBudgets;

  /// No description provided for @noBudgetsDesc.
  ///
  /// In en, this message translates to:
  /// **'Tap the + button to create your first budget category.'**
  String get noBudgetsDesc;

  /// No description provided for @categoryName.
  ///
  /// In en, this message translates to:
  /// **'Category Name'**
  String get categoryName;

  /// No description provided for @categorySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Subtitle (optional)'**
  String get categorySubtitle;

  /// No description provided for @allocatedAmount.
  ///
  /// In en, this message translates to:
  /// **'Allocated Amount'**
  String get allocatedAmount;

  /// No description provided for @categories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get categories;

  /// No description provided for @saveAsTemplate.
  ///
  /// In en, this message translates to:
  /// **'Save as template'**
  String get saveAsTemplate;

  /// No description provided for @useTemplate.
  ///
  /// In en, this message translates to:
  /// **'Use a Template'**
  String get useTemplate;

  /// No description provided for @useSavedTemplate.
  ///
  /// In en, this message translates to:
  /// **'Use a saved template'**
  String get useSavedTemplate;

  /// No description provided for @subtractMoney.
  ///
  /// In en, this message translates to:
  /// **'Subtract Money (Spend)'**
  String get subtractMoney;

  /// No description provided for @addMoney.
  ///
  /// In en, this message translates to:
  /// **'Add Money (Income)'**
  String get addMoney;

  /// No description provided for @amount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amount;

  /// No description provided for @note.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get note;

  /// No description provided for @noteHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Netflix subscription'**
  String get noteHint;

  /// No description provided for @makeRecurring.
  ///
  /// In en, this message translates to:
  /// **'Make Recurring'**
  String get makeRecurring;

  /// No description provided for @everyMonth.
  ///
  /// In en, this message translates to:
  /// **'Every Month'**
  String get everyMonth;

  /// No description provided for @everyWeek.
  ///
  /// In en, this message translates to:
  /// **'Every Week'**
  String get everyWeek;

  /// No description provided for @expenseLabel.
  ///
  /// In en, this message translates to:
  /// **'Expense'**
  String get expenseLabel;

  /// No description provided for @incomeLabel.
  ///
  /// In en, this message translates to:
  /// **'Income'**
  String get incomeLabel;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @free.
  ///
  /// In en, this message translates to:
  /// **'Free'**
  String get free;

  /// No description provided for @upgrade.
  ///
  /// In en, this message translates to:
  /// **'Upgrade'**
  String get upgrade;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @logoutConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to log out?'**
  String get logoutConfirmBody;

  /// No description provided for @photoFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to upload photo'**
  String get photoFailed;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @invest.
  ///
  /// In en, this message translates to:
  /// **'Invest'**
  String get invest;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @userDataNotFound.
  ///
  /// In en, this message translates to:
  /// **'User data not found'**
  String get userDataNotFound;

  /// No description provided for @newBudget.
  ///
  /// In en, this message translates to:
  /// **'New Budget'**
  String get newBudget;

  /// No description provided for @reports.
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get reports;

  /// No description provided for @insights.
  ///
  /// In en, this message translates to:
  /// **'Insights'**
  String get insights;

  /// No description provided for @reportsComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Reports coming soon!'**
  String get reportsComingSoon;

  /// No description provided for @insightsComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Insights coming soon!'**
  String get insightsComingSoon;

  /// No description provided for @activeBudgets.
  ///
  /// In en, this message translates to:
  /// **'Active Budgets'**
  String get activeBudgets;

  /// No description provided for @manage.
  ///
  /// In en, this message translates to:
  /// **'Manage'**
  String get manage;

  /// No description provided for @noBudgetsYet.
  ///
  /// In en, this message translates to:
  /// **'No budgets yet'**
  String get noBudgetsYet;

  /// No description provided for @tapNewBudgetToStart.
  ///
  /// In en, this message translates to:
  /// **'Tap \"New Budget\" above to start tracking'**
  String get tapNewBudgetToStart;

  /// No description provided for @createFirstBudget.
  ///
  /// In en, this message translates to:
  /// **'Create First Budget'**
  String get createFirstBudget;

  /// No description provided for @editSavingsGoal.
  ///
  /// In en, this message translates to:
  /// **'Edit Savings Goal'**
  String get editSavingsGoal;

  /// No description provided for @monthlyGoal.
  ///
  /// In en, this message translates to:
  /// **'Monthly Goal (\$)'**
  String get monthlyGoal;

  /// No description provided for @enterMonthlySavingsGoal.
  ///
  /// In en, this message translates to:
  /// **'Enter your monthly savings goal'**
  String get enterMonthlySavingsGoal;

  /// No description provided for @emailAddress.
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get emailAddress;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @enterEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email'**
  String get enterEmail;

  /// No description provided for @validEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email'**
  String get validEmail;

  /// No description provided for @enterPassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter your password'**
  String get enterPassword;

  /// No description provided for @passwordMin.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get passwordMin;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// No description provided for @continueGoogle.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get continueGoogle;

  /// No description provided for @dontHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get dontHaveAccount;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUp;

  /// No description provided for @welcomeLogin.
  ///
  /// In en, this message translates to:
  /// **'Welcome back! Sign in to continue'**
  String get welcomeLogin;

  /// No description provided for @welcomeUser.
  ///
  /// In en, this message translates to:
  /// **'Welcome back, {name}!'**
  String welcomeUser(String name);

  /// No description provided for @daysLeftText.
  ///
  /// In en, this message translates to:
  /// **'{days} Days Left'**
  String daysLeftText(int days);

  /// No description provided for @savedGoalText.
  ///
  /// In en, this message translates to:
  /// **'Saved: {saved} • Goal: {goal}'**
  String savedGoalText(String saved, String goal);

  /// No description provided for @amountLeftText.
  ///
  /// In en, this message translates to:
  /// **'\${amount} left'**
  String amountLeftText(String amount);

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// No description provided for @registerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Start your mindful money journey'**
  String get registerSubtitle;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get alreadyHaveAccount;

  /// No description provided for @fullNameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your name'**
  String get fullNameHint;

  /// No description provided for @emailHint.
  ///
  /// In en, this message translates to:
  /// **'you@example.com'**
  String get emailHint;

  /// No description provided for @passwordHintRegister.
  ///
  /// In en, this message translates to:
  /// **'At least 6 characters'**
  String get passwordHintRegister;

  /// No description provided for @passwordHintLogin.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get passwordHintLogin;

  /// No description provided for @confirmPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Re-enter your password'**
  String get confirmPasswordHint;

  /// No description provided for @enterNameError.
  ///
  /// In en, this message translates to:
  /// **'Please enter your name'**
  String get enterNameError;

  /// No description provided for @nameTooShortError.
  ///
  /// In en, this message translates to:
  /// **'Name must be at least 2 characters'**
  String get nameTooShortError;

  /// No description provided for @enterEmailError.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email'**
  String get enterEmailError;

  /// No description provided for @validEmailError.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email'**
  String get validEmailError;

  /// No description provided for @enterPasswordError.
  ///
  /// In en, this message translates to:
  /// **'Please enter a password'**
  String get enterPasswordError;

  /// No description provided for @passwordLengthError.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get passwordLengthError;

  /// No description provided for @confirmPasswordError.
  ///
  /// In en, this message translates to:
  /// **'Please confirm your password'**
  String get confirmPasswordError;

  /// No description provided for @passwordMismatchError.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordMismatchError;

  /// No description provided for @accountCreatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Account created successfully!'**
  String get accountCreatedSuccess;

  /// No description provided for @aiInvest.
  ///
  /// In en, this message translates to:
  /// **'AI Invest'**
  String get aiInvest;

  /// No description provided for @dashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// No description provided for @markets.
  ///
  /// In en, this message translates to:
  /// **'Markets'**
  String get markets;

  /// No description provided for @aiAdvisor.
  ///
  /// In en, this message translates to:
  /// **'AI Advisor'**
  String get aiAdvisor;

  /// No description provided for @positions.
  ///
  /// In en, this message translates to:
  /// **'Positions'**
  String get positions;

  /// No description provided for @connectAlpacaAccount.
  ///
  /// In en, this message translates to:
  /// **'Connect Your Alpaca Account'**
  String get connectAlpacaAccount;

  /// No description provided for @alpacaDescription.
  ///
  /// In en, this message translates to:
  /// **'Trade Gold ETF, Silver ETF, Bitcoin, Ethereum and stocks — all from one account.\n\nStart with free Paper Trading (\$100k virtual cash).'**
  String get alpacaDescription;

  /// No description provided for @connectAlpacaFirst.
  ///
  /// In en, this message translates to:
  /// **'Connect Alpaca first'**
  String get connectAlpacaFirst;

  /// No description provided for @noOpenPositions.
  ///
  /// In en, this message translates to:
  /// **'No open positions'**
  String get noOpenPositions;

  /// No description provided for @connectToSeePositions.
  ///
  /// In en, this message translates to:
  /// **'Connect Alpaca to see your live positions'**
  String get connectToSeePositions;

  /// No description provided for @chatHint.
  ///
  /// In en, this message translates to:
  /// **'Ask anything — analyze portfolio, buy gold, market outlook...'**
  String get chatHint;

  /// No description provided for @loadingAgent.
  ///
  /// In en, this message translates to:
  /// **'Loading AI agent...'**
  String get loadingAgent;

  /// No description provided for @aiAnalyzing.
  ///
  /// In en, this message translates to:
  /// **'AI Agent is analyzing...'**
  String get aiAnalyzing;

  /// No description provided for @livePrices.
  ///
  /// In en, this message translates to:
  /// **'Live Prices'**
  String get livePrices;

  /// No description provided for @updated.
  ///
  /// In en, this message translates to:
  /// **'Updated'**
  String get updated;

  /// No description provided for @connectAlpaca.
  ///
  /// In en, this message translates to:
  /// **'Connect Alpaca'**
  String get connectAlpaca;

  /// No description provided for @refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// No description provided for @live.
  ///
  /// In en, this message translates to:
  /// **'LIVE'**
  String get live;

  /// No description provided for @alpacaIntro.
  ///
  /// In en, this message translates to:
  /// **'Trade Gold ETF, Silver ETF, Bitcoin, Ethereum and stocks — all from one account.\n\nStart with free Paper Trading (\$100k virtual cash).'**
  String get alpacaIntro;

  /// No description provided for @chatWithAi.
  ///
  /// In en, this message translates to:
  /// **'Or just chat with AI →'**
  String get chatWithAi;

  /// No description provided for @metals.
  ///
  /// In en, this message translates to:
  /// **'Metals'**
  String get metals;

  /// No description provided for @crypto.
  ///
  /// In en, this message translates to:
  /// **'Crypto'**
  String get crypto;

  /// No description provided for @usStocks.
  ///
  /// In en, this message translates to:
  /// **'US Stocks'**
  String get usStocks;

  /// No description provided for @showOpportunities.
  ///
  /// In en, this message translates to:
  /// **'Show opportunities'**
  String get showOpportunities;

  /// No description provided for @investBestPick.
  ///
  /// In en, this message translates to:
  /// **'Invest in best pick'**
  String get investBestPick;

  /// No description provided for @fullAutoScan.
  ///
  /// In en, this message translates to:
  /// **'Full auto-scan'**
  String get fullAutoScan;

  /// No description provided for @portfolioReview.
  ///
  /// In en, this message translates to:
  /// **'Portfolio review'**
  String get portfolioReview;

  /// No description provided for @lockInGains.
  ///
  /// In en, this message translates to:
  /// **'Lock in gains'**
  String get lockInGains;

  /// No description provided for @execute.
  ///
  /// In en, this message translates to:
  /// **'Execute'**
  String get execute;

  /// No description provided for @noAlpacaConnected.
  ///
  /// In en, this message translates to:
  /// **'No Alpaca account connected'**
  String get noAlpacaConnected;

  /// No description provided for @connectAlpacaPositions.
  ///
  /// In en, this message translates to:
  /// **'Connect Alpaca to see your live positions'**
  String get connectAlpacaPositions;

  /// No description provided for @openPositions.
  ///
  /// In en, this message translates to:
  /// **'Open Positions'**
  String get openPositions;

  /// No description provided for @dashboardOpportunities.
  ///
  /// In en, this message translates to:
  /// **'Use the Dashboard to find and invest in opportunities'**
  String get dashboardOpportunities;

  /// No description provided for @closePosition.
  ///
  /// In en, this message translates to:
  /// **'Close Position'**
  String get closePosition;

  /// No description provided for @livePortfolio.
  ///
  /// In en, this message translates to:
  /// **'LIVE PORTFOLIO'**
  String get livePortfolio;

  /// No description provided for @autoRefresh30s.
  ///
  /// In en, this message translates to:
  /// **'Auto-refresh 30s'**
  String get autoRefresh30s;

  /// No description provided for @entryPrice.
  ///
  /// In en, this message translates to:
  /// **'Entry price'**
  String get entryPrice;

  /// No description provided for @currentPrice.
  ///
  /// In en, this message translates to:
  /// **'Current price'**
  String get currentPrice;

  /// No description provided for @marketValue.
  ///
  /// In en, this message translates to:
  /// **'Market value'**
  String get marketValue;

  /// No description provided for @sellPosition.
  ///
  /// In en, this message translates to:
  /// **'Sell Position'**
  String get sellPosition;

  /// No description provided for @value.
  ///
  /// In en, this message translates to:
  /// **'Value'**
  String get value;

  /// No description provided for @profitLoss.
  ///
  /// In en, this message translates to:
  /// **'P&L'**
  String get profitLoss;

  /// No description provided for @tradeBuy.
  ///
  /// In en, this message translates to:
  /// **'Trade: BUY \${amount} of {asset}'**
  String tradeBuy(Object amount, Object asset);

  /// No description provided for @tradeSell.
  ///
  /// In en, this message translates to:
  /// **'Trade: SELL {percent}% of {asset}'**
  String tradeSell(Object percent, Object asset);

  /// No description provided for @positionClosed.
  ///
  /// In en, this message translates to:
  /// **'✅ Closed {name} — order submitted'**
  String positionClosed(Object name);

  /// No description provided for @autoTradeDisabled.
  ///
  /// In en, this message translates to:
  /// **'Auto-trade disabled by user.'**
  String get autoTradeDisabled;

  /// No description provided for @autoTradeEnabled.
  ///
  /// In en, this message translates to:
  /// **'Auto-trade enabled. Hourly analysis will run in background.'**
  String get autoTradeEnabled;

  /// No description provided for @autoSold.
  ///
  /// In en, this message translates to:
  /// **'AUTO-SOLD {symbol} at market price'**
  String autoSold(Object symbol);

  /// No description provided for @autoSellFailed.
  ///
  /// In en, this message translates to:
  /// **'Auto-sell failed: {error}'**
  String autoSellFailed(Object error);

  /// No description provided for @aiFoundOpportunities.
  ///
  /// In en, this message translates to:
  /// **'AI found {count} buy opportunities — your approval needed'**
  String aiFoundOpportunities(Object count);

  /// No description provided for @view.
  ///
  /// In en, this message translates to:
  /// **'View'**
  String get view;

  /// No description provided for @notOnAlpacaYet.
  ///
  /// In en, this message translates to:
  /// **'{asset} not on Alpaca yet'**
  String notOnAlpacaYet(Object asset);

  /// No description provided for @boughtAsset.
  ///
  /// In en, this message translates to:
  /// **'Bought \${amount} of {asset}'**
  String boughtAsset(Object amount, Object asset);

  /// No description provided for @confirmBuy.
  ///
  /// In en, this message translates to:
  /// **'Confirm Buy'**
  String get confirmBuy;

  /// No description provided for @confirmSell.
  ///
  /// In en, this message translates to:
  /// **'Confirm Sell'**
  String get confirmSell;

  /// No description provided for @buyAssetAmount.
  ///
  /// In en, this message translates to:
  /// **'Buy \${amount} of {asset}'**
  String buyAssetAmount(Object amount, Object asset);

  /// No description provided for @sellAssetPercent.
  ///
  /// In en, this message translates to:
  /// **'Sell {percent}% of {asset}'**
  String sellAssetPercent(Object percent, Object asset);

  /// No description provided for @alpacaSymbol.
  ///
  /// In en, this message translates to:
  /// **'Alpaca symbol'**
  String get alpacaSymbol;

  /// No description provided for @realOrderWarning.
  ///
  /// In en, this message translates to:
  /// **'⚠️ This will place a REAL order on Alpaca.'**
  String get realOrderWarning;

  /// No description provided for @paperTradeWarning.
  ///
  /// In en, this message translates to:
  /// **'📄 Paper trade — no real money moves.'**
  String get paperTradeWarning;

  /// No description provided for @executeBuy.
  ///
  /// In en, this message translates to:
  /// **'Execute Buy ✓'**
  String get executeBuy;

  /// No description provided for @executeSell.
  ///
  /// In en, this message translates to:
  /// **'Execute Sell ✓'**
  String get executeSell;

  /// No description provided for @boughtOrderSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Bought — order submitted to Alpaca'**
  String get boughtOrderSubmitted;

  /// No description provided for @soldOrderSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Sold — order submitted to Alpaca'**
  String get soldOrderSubmitted;

  /// No description provided for @units.
  ///
  /// In en, this message translates to:
  /// **'units'**
  String get units;

  /// No description provided for @unrealizedPnL.
  ///
  /// In en, this message translates to:
  /// **'unrealized P&L'**
  String get unrealizedPnL;

  /// No description provided for @cashBuyingPower.
  ///
  /// In en, this message translates to:
  /// **'Cash: \${cash} • Buying power: \${power}'**
  String cashBuyingPower(Object cash, Object power);

  /// No description provided for @pnl.
  ///
  /// In en, this message translates to:
  /// **'P&L'**
  String get pnl;

  /// No description provided for @closePositionButton.
  ///
  /// In en, this message translates to:
  /// **'Close Position'**
  String get closePositionButton;

  /// No description provided for @closedPositionOrderSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Closed {asset} — order submitted'**
  String closedPositionOrderSubmitted(Object asset);

  /// No description provided for @alpacaSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Connect Alpaca Account'**
  String get alpacaSettingsTitle;

  /// No description provided for @alpacaHowToTitle.
  ///
  /// In en, this message translates to:
  /// **'🔗 How to get your API keys'**
  String get alpacaHowToTitle;

  /// No description provided for @alpacaStep1.
  ///
  /// In en, this message translates to:
  /// **'Sign up FREE at alpaca.markets'**
  String get alpacaStep1;

  /// No description provided for @alpacaStep2.
  ///
  /// In en, this message translates to:
  /// **'Go to Paper Trading → API Keys'**
  String get alpacaStep2;

  /// No description provided for @alpacaStep3.
  ///
  /// In en, this message translates to:
  /// **'Generate a new key & copy both values below'**
  String get alpacaStep3;

  /// No description provided for @alpacaStep4.
  ///
  /// In en, this message translates to:
  /// **'Start in Paper mode (fake money) to test safely'**
  String get alpacaStep4;

  /// No description provided for @alpacaPaperInfo.
  ///
  /// In en, this message translates to:
  /// **'💰 Alpaca gives you \$100,000 virtual cash in Paper mode.'**
  String get alpacaPaperInfo;

  /// No description provided for @alpacaTradingMode.
  ///
  /// In en, this message translates to:
  /// **'Trading Mode'**
  String get alpacaTradingMode;

  /// No description provided for @alpacaPaperMode.
  ///
  /// In en, this message translates to:
  /// **'📄 Paper (Safe)'**
  String get alpacaPaperMode;

  /// No description provided for @alpacaLiveMode.
  ///
  /// In en, this message translates to:
  /// **'💵 Live (Real Money)'**
  String get alpacaLiveMode;

  /// No description provided for @alpacaLiveWarning.
  ///
  /// In en, this message translates to:
  /// **'⚠️ Live mode uses REAL money. Make sure you understand the risks.'**
  String get alpacaLiveWarning;

  /// No description provided for @alpacaApiKey.
  ///
  /// In en, this message translates to:
  /// **'API Key ID'**
  String get alpacaApiKey;

  /// No description provided for @alpacaApiKeyHint.
  ///
  /// In en, this message translates to:
  /// **'PKXXXXXXXXXXXXXXXXXXXXXXXX'**
  String get alpacaApiKeyHint;

  /// No description provided for @alpacaSecretKey.
  ///
  /// In en, this message translates to:
  /// **'API Secret Key'**
  String get alpacaSecretKey;

  /// No description provided for @alpacaSecretHint.
  ///
  /// In en, this message translates to:
  /// **'••••••••••••••••••••••••••••••••••••••••'**
  String get alpacaSecretHint;

  /// No description provided for @alpacaConnectButton.
  ///
  /// In en, this message translates to:
  /// **'Connect & Test'**
  String get alpacaConnectButton;

  /// No description provided for @alpacaTesting.
  ///
  /// In en, this message translates to:
  /// **'Testing connection...'**
  String get alpacaTesting;

  /// No description provided for @alpacaMissingFields.
  ///
  /// In en, this message translates to:
  /// **'Please enter both API Key and Secret'**
  String get alpacaMissingFields;

  /// No description provided for @alpacaConnectionFailed.
  ///
  /// In en, this message translates to:
  /// **'Connection failed. Check your keys.'**
  String get alpacaConnectionFailed;

  /// No description provided for @alpacaConnectedSnackbar.
  ///
  /// In en, this message translates to:
  /// **'✅ Alpaca connected! Ready to trade.'**
  String get alpacaConnectedSnackbar;

  /// No description provided for @alpacaConnected.
  ///
  /// In en, this message translates to:
  /// **'✅ Connected!'**
  String get alpacaConnected;

  /// No description provided for @alpacaCash.
  ///
  /// In en, this message translates to:
  /// **'Cash'**
  String get alpacaCash;

  /// No description provided for @alpacaBuyingPower.
  ///
  /// In en, this message translates to:
  /// **'Buying Power'**
  String get alpacaBuyingPower;

  /// No description provided for @alpacaPortfolioValue.
  ///
  /// In en, this message translates to:
  /// **'Portfolio Value'**
  String get alpacaPortfolioValue;

  /// No description provided for @alpacaStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get alpacaStatus;

  /// No description provided for @notLoggedIn.
  ///
  /// In en, this message translates to:
  /// **'Not logged in.'**
  String get notLoggedIn;

  /// No description provided for @setMonthlyBudget.
  ///
  /// In en, this message translates to:
  /// **'Set Budget for {monthName}'**
  String setMonthlyBudget(String monthName);

  /// No description provided for @editMonthlyBudget.
  ///
  /// In en, this message translates to:
  /// **'Edit Monthly Budget'**
  String get editMonthlyBudget;

  /// No description provided for @monthlyBudgetDescription.
  ///
  /// In en, this message translates to:
  /// **'This is your total spending limit for the month.'**
  String get monthlyBudgetDescription;

  /// No description provided for @totalMonthlyBudget.
  ///
  /// In en, this message translates to:
  /// **'Total Monthly Budget'**
  String get totalMonthlyBudget;

  /// No description provided for @totalMonthlyBudgetLabel.
  ///
  /// In en, this message translates to:
  /// **'Total monthly budget'**
  String get totalMonthlyBudgetLabel;

  /// No description provided for @fullyAllocated.
  ///
  /// In en, this message translates to:
  /// **'Fully Allocated'**
  String get fullyAllocated;

  /// No description provided for @fullyAllocatedDescription.
  ///
  /// In en, this message translates to:
  /// **'You have allocated all \${amount}. Edit or delete a category to free up money.'**
  String fullyAllocatedDescription(String amount);

  /// No description provided for @addCategoryBudget.
  ///
  /// In en, this message translates to:
  /// **'Add Category Budget'**
  String get addCategoryBudget;

  /// No description provided for @availableToAssign.
  ///
  /// In en, this message translates to:
  /// **'\${amount} available to assign'**
  String availableToAssign(String amount);

  /// No description provided for @groceriesHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Groceries'**
  String get groceriesHint;

  /// No description provided for @maxAmount.
  ///
  /// In en, this message translates to:
  /// **'Max {amount}'**
  String maxAmount(String amount);

  /// No description provided for @newCategory.
  ///
  /// In en, this message translates to:
  /// **'New Category'**
  String get newCategory;

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// No description provided for @amountExceedsRemaining.
  ///
  /// In en, this message translates to:
  /// **'Amount exceeds remaining \${amount}'**
  String amountExceedsRemaining(String amount);

  /// No description provided for @addMoneyDeposit.
  ///
  /// In en, this message translates to:
  /// **'Add Money (Deposit)'**
  String get addMoneyDeposit;

  /// No description provided for @subtractMoneySpend.
  ///
  /// In en, this message translates to:
  /// **'Subtract Money (Spend)'**
  String get subtractMoneySpend;

  /// No description provided for @noteOptional.
  ///
  /// In en, this message translates to:
  /// **'Note (optional)'**
  String get noteOptional;

  /// No description provided for @salaryHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Salary'**
  String get salaryHint;

  /// No description provided for @netflixHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Netflix'**
  String get netflixHint;

  /// No description provided for @editBudgetAmount.
  ///
  /// In en, this message translates to:
  /// **'Edit Budget Amount'**
  String get editBudgetAmount;

  /// No description provided for @deleteBudgetQuestion.
  ///
  /// In en, this message translates to:
  /// **'Delete \"{title}\"? This cannot be undone.'**
  String deleteBudgetQuestion(String title);

  /// No description provided for @allocatedToCategories.
  ///
  /// In en, this message translates to:
  /// **'Allocated to categories'**
  String get allocatedToCategories;

  /// No description provided for @unallocated.
  ///
  /// In en, this message translates to:
  /// **'Unallocated'**
  String get unallocated;

  /// No description provided for @fullyAllocatedCheck.
  ///
  /// In en, this message translates to:
  /// **'✓ Fully allocated'**
  String get fullyAllocatedCheck;

  /// No description provided for @noCategoriesYet.
  ///
  /// In en, this message translates to:
  /// **'No categories yet'**
  String get noCategoriesYet;

  /// No description provided for @divideBudgetHint.
  ///
  /// In en, this message translates to:
  /// **'Tap + to divide your budget into categories.'**
  String get divideBudgetHint;

  /// No description provided for @spentAmount.
  ///
  /// In en, this message translates to:
  /// **'Spent: \${amount}'**
  String spentAmount(String amount);

  /// No description provided for @leftAmount.
  ///
  /// In en, this message translates to:
  /// **'\${amount} left'**
  String leftAmount(String amount);

  /// No description provided for @useAsTemplate.
  ///
  /// In en, this message translates to:
  /// **'Use template'**
  String get useAsTemplate;

  /// No description provided for @pickTemplate.
  ///
  /// In en, this message translates to:
  /// **'Pick a saved template to apply.'**
  String get pickTemplate;

  /// No description provided for @noTemplatesYet.
  ///
  /// In en, this message translates to:
  /// **'No templates yet'**
  String get noTemplatesYet;

  /// No description provided for @templateDescription.
  ///
  /// In en, this message translates to:
  /// **'Save these {count} categories and their allocated amounts as a reusable template.'**
  String templateDescription(String count);

  /// No description provided for @templateName.
  ///
  /// In en, this message translates to:
  /// **'Template Name'**
  String get templateName;

  /// No description provided for @monthlyBudgetTemplate.
  ///
  /// In en, this message translates to:
  /// **'Monthly Budget Template'**
  String get monthlyBudgetTemplate;

  /// No description provided for @saveTemplate.
  ///
  /// In en, this message translates to:
  /// **'Save Template'**
  String get saveTemplate;

  /// No description provided for @templateSaved.
  ///
  /// In en, this message translates to:
  /// **'✅ \"{name}\" saved as template!'**
  String templateSaved(String name);

  /// No description provided for @transactionHistory.
  ///
  /// In en, this message translates to:
  /// **'Transaction History'**
  String get transactionHistory;

  /// No description provided for @addCategoryFirst.
  ///
  /// In en, this message translates to:
  /// **'Add at least one category before saving a template.'**
  String get addCategoryFirst;

  /// No description provided for @defaultTemplateName.
  ///
  /// In en, this message translates to:
  /// **'{monthName} Template'**
  String defaultTemplateName(String monthName);

  /// No description provided for @templateSummary.
  ///
  /// In en, this message translates to:
  /// **'{count} categories · \${total} total'**
  String templateSummary(String count, String total);

  /// No description provided for @noTemplatesHint.
  ///
  /// In en, this message translates to:
  /// **'Save your current budget setup as a template to reuse it next month.'**
  String get noTemplatesHint;

  /// No description provided for @templateApplied.
  ///
  /// In en, this message translates to:
  /// **'✅ \"{name}\" applied! Adjust amounts as needed.'**
  String templateApplied(String name);

  /// No description provided for @failedToLoadCategories.
  ///
  /// In en, this message translates to:
  /// **'Failed to load categories'**
  String get failedToLoadCategories;

  /// No description provided for @noBudgetForMonth.
  ///
  /// In en, this message translates to:
  /// **'No budget for {monthName}'**
  String noBudgetForMonth(Object monthName);

  /// No description provided for @budgetSetupDescription.
  ///
  /// In en, this message translates to:
  /// **'Set a total amount, then divide it into categories.'**
  String get budgetSetupDescription;

  /// No description provided for @addCategoryBeforeTemplate.
  ///
  /// In en, this message translates to:
  /// **'Add at least one category before saving a template.'**
  String get addCategoryBeforeTemplate;

  /// No description provided for @use.
  ///
  /// In en, this message translates to:
  /// **'Use'**
  String get use;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @setupMonthTemplate.
  ///
  /// In en, this message translates to:
  /// **'Set up a month and tap \"Save as Template\".'**
  String get setupMonthTemplate;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @resetPassword.
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get resetPassword;

  /// No description provided for @resetPasswordDescription.
  ///
  /// In en, this message translates to:
  /// **'Enter your email address and we\'ll send you a link to reset your password.'**
  String get resetPasswordDescription;

  /// No description provided for @resetPasswordEmailSentDescription.
  ///
  /// In en, this message translates to:
  /// **'Check your email for a link to reset your password.'**
  String get resetPasswordEmailSentDescription;

  /// No description provided for @pleaseEnterEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email'**
  String get pleaseEnterEmail;

  /// No description provided for @pleaseEnterValidEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email address'**
  String get pleaseEnterValidEmail;

  /// No description provided for @sendResetLink.
  ///
  /// In en, this message translates to:
  /// **'Send Reset Link'**
  String get sendResetLink;

  /// No description provided for @backToLogin.
  ///
  /// In en, this message translates to:
  /// **'Back to Login'**
  String get backToLogin;

  /// No description provided for @passwordResetEmailSent.
  ///
  /// In en, this message translates to:
  /// **'Password reset email sent successfully!'**
  String get passwordResetEmailSent;

  /// No description provided for @choosePhotoSource.
  ///
  /// In en, this message translates to:
  /// **'Choose Photo Source'**
  String get choosePhotoSource;

  /// No description provided for @takePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take Photo'**
  String get takePhoto;

  /// No description provided for @chooseFromGallery.
  ///
  /// In en, this message translates to:
  /// **'Choose from Gallery'**
  String get chooseFromGallery;

  /// No description provided for @uploadingPhoto.
  ///
  /// In en, this message translates to:
  /// **'Uploading photo...'**
  String get uploadingPhoto;

  /// No description provided for @profileUpdated.
  ///
  /// In en, this message translates to:
  /// **'Profile picture updated!'**
  String get profileUpdated;

  /// No description provided for @uploadFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to upload photo'**
  String get uploadFailed;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// No description provided for @membership.
  ///
  /// In en, this message translates to:
  /// **'Membership'**
  String get membership;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @currentPlan.
  ///
  /// In en, this message translates to:
  /// **'CURRENT PLAN'**
  String get currentPlan;

  /// No description provided for @privacySecurity.
  ///
  /// In en, this message translates to:
  /// **'Privacy & Security'**
  String get privacySecurity;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @logoutConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Log Out'**
  String get logoutConfirmTitle;

  /// No description provided for @logoutConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to log out?'**
  String get logoutConfirmMessage;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @editName.
  ///
  /// In en, this message translates to:
  /// **'Edit Name'**
  String get editName;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @appVersion.
  ///
  /// In en, this message translates to:
  /// **'App Version 1.0.0'**
  String get appVersion;

  /// No description provided for @recurring.
  ///
  /// In en, this message translates to:
  /// **'Recurring'**
  String get recurring;

  /// No description provided for @noRecurringTitle.
  ///
  /// In en, this message translates to:
  /// **'No recurring transactions'**
  String get noRecurringTitle;

  /// No description provided for @noRecurringSubtitle.
  ///
  /// In en, this message translates to:
  /// **'When you add or spend money, check \"Make recurring\" to set it on repeat.'**
  String get noRecurringSubtitle;

  /// No description provided for @deleteRecurringTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete recurring transaction?'**
  String get deleteRecurringTitle;

  /// No description provided for @deleteRecurringMessage.
  ///
  /// In en, this message translates to:
  /// **'\"{note}\" will no longer be applied automatically.'**
  String deleteRecurringMessage(Object note);

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @monthJan.
  ///
  /// In en, this message translates to:
  /// **'Jan'**
  String get monthJan;

  /// No description provided for @monthFeb.
  ///
  /// In en, this message translates to:
  /// **'Feb'**
  String get monthFeb;

  /// No description provided for @monthMar.
  ///
  /// In en, this message translates to:
  /// **'Mar'**
  String get monthMar;

  /// No description provided for @monthApr.
  ///
  /// In en, this message translates to:
  /// **'Apr'**
  String get monthApr;

  /// No description provided for @monthMay.
  ///
  /// In en, this message translates to:
  /// **'May'**
  String get monthMay;

  /// No description provided for @monthJun.
  ///
  /// In en, this message translates to:
  /// **'Jun'**
  String get monthJun;

  /// No description provided for @monthJul.
  ///
  /// In en, this message translates to:
  /// **'Jul'**
  String get monthJul;

  /// No description provided for @monthAug.
  ///
  /// In en, this message translates to:
  /// **'Aug'**
  String get monthAug;

  /// No description provided for @monthSep.
  ///
  /// In en, this message translates to:
  /// **'Sep'**
  String get monthSep;

  /// No description provided for @monthOct.
  ///
  /// In en, this message translates to:
  /// **'Oct'**
  String get monthOct;

  /// No description provided for @monthNov.
  ///
  /// In en, this message translates to:
  /// **'Nov'**
  String get monthNov;

  /// No description provided for @monthDec.
  ///
  /// In en, this message translates to:
  /// **'Dec'**
  String get monthDec;

  /// No description provided for @nextDue.
  ///
  /// In en, this message translates to:
  /// **'Next: {date}'**
  String nextDue(Object date);

  /// No description provided for @transactions.
  ///
  /// In en, this message translates to:
  /// **'Transactions'**
  String get transactions;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search by note or category…'**
  String get searchHint;

  /// No description provided for @newest.
  ///
  /// In en, this message translates to:
  /// **'Newest'**
  String get newest;

  /// No description provided for @largest.
  ///
  /// In en, this message translates to:
  /// **'Largest'**
  String get largest;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @expenses.
  ///
  /// In en, this message translates to:
  /// **'Expenses'**
  String get expenses;

  /// No description provided for @income.
  ///
  /// In en, this message translates to:
  /// **'Income'**
  String get income;

  /// No description provided for @allCategories.
  ///
  /// In en, this message translates to:
  /// **'All categories'**
  String get allCategories;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @yesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// No description provided for @noResults.
  ///
  /// In en, this message translates to:
  /// **'No results found'**
  String get noResults;

  /// No description provided for @noTransactions.
  ///
  /// In en, this message translates to:
  /// **'No transactions yet'**
  String get noTransactions;

  /// No description provided for @noResultsHint.
  ///
  /// In en, this message translates to:
  /// **'Try adjusting your search or filters.'**
  String get noResultsHint;

  /// No description provided for @noTransactionsHint.
  ///
  /// In en, this message translates to:
  /// **'Your deposits and spending will appear here.'**
  String get noTransactionsHint;

  /// No description provided for @clearFilters.
  ///
  /// In en, this message translates to:
  /// **'Clear all filters'**
  String get clearFilters;

  /// No description provided for @auto.
  ///
  /// In en, this message translates to:
  /// **'Auto'**
  String get auto;

  /// No description provided for @transactionsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} transactions'**
  String transactionsCount(String count);

  /// No description provided for @autoPrefix.
  ///
  /// In en, this message translates to:
  /// **'[Auto] '**
  String get autoPrefix;

  /// No description provided for @autoLabel.
  ///
  /// In en, this message translates to:
  /// **'Auto'**
  String get autoLabel;

  /// No description provided for @am.
  ///
  /// In en, this message translates to:
  /// **'AM'**
  String get am;

  /// No description provided for @pm.
  ///
  /// In en, this message translates to:
  /// **'PM'**
  String get pm;

  /// No description provided for @privacyAndSecurity.
  ///
  /// In en, this message translates to:
  /// **'Privacy & Security'**
  String get privacyAndSecurity;

  /// No description provided for @securitySettings.
  ///
  /// In en, this message translates to:
  /// **'Security Settings'**
  String get securitySettings;

  /// No description provided for @googleAccountManaged.
  ///
  /// In en, this message translates to:
  /// **'Your account is managed via Google.'**
  String get googleAccountManaged;

  /// No description provided for @keepAccountSecure.
  ///
  /// In en, this message translates to:
  /// **'Keep your account secure by updating your password regularly.'**
  String get keepAccountSecure;

  /// No description provided for @signedInWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Signed in with Google'**
  String get signedInWithGoogle;

  /// No description provided for @googlePasswordInfo.
  ///
  /// In en, this message translates to:
  /// **'Because you use Google Sign-In, you can manage your password directly in your Google Account settings.'**
  String get googlePasswordInfo;

  /// No description provided for @currentPassword.
  ///
  /// In en, this message translates to:
  /// **'Current Password'**
  String get currentPassword;

  /// No description provided for @newPassword.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get newPassword;

  /// No description provided for @confirmNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm New Password'**
  String get confirmNewPassword;

  /// No description provided for @updatePassword.
  ///
  /// In en, this message translates to:
  /// **'Update Password'**
  String get updatePassword;

  /// No description provided for @fieldRequired.
  ///
  /// In en, this message translates to:
  /// **'Field required'**
  String get fieldRequired;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDoNotMatch;

  /// No description provided for @passwordTooShort.
  ///
  /// In en, this message translates to:
  /// **'Must be at least 6 characters'**
  String get passwordTooShort;

  /// No description provided for @passwordUpdatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Password updated successfully!'**
  String get passwordUpdatedSuccess;

  /// No description provided for @spendingInsights.
  ///
  /// In en, this message translates to:
  /// **'Spending Insights'**
  String get spendingInsights;

  /// No description provided for @daysLeft.
  ///
  /// In en, this message translates to:
  /// **'{days} days left this month'**
  String daysLeft(int days);

  /// No description provided for @onTrack.
  ///
  /// In en, this message translates to:
  /// **'{count} on track'**
  String onTrack(int count);

  /// No description provided for @overBudget.
  ///
  /// In en, this message translates to:
  /// **'{count} over budget'**
  String overBudget(int count);

  /// No description provided for @addBudgetCategoriesInsights.
  ///
  /// In en, this message translates to:
  /// **'Add budget categories to see insights.'**
  String get addBudgetCategoriesInsights;

  /// No description provided for @overBudgetInsight.
  ///
  /// In en, this message translates to:
  /// **'Over budget by {amount}. Consider cutting back.'**
  String overBudgetInsight(Object amount);

  /// No description provided for @nearlyAtLimitInsight.
  ///
  /// In en, this message translates to:
  /// **'Only {amount} left — nearly at your limit!'**
  String nearlyAtLimitInsight(Object amount);

  /// No description provided for @usedPercentInsight.
  ///
  /// In en, this message translates to:
  /// **'You\'ve used {percent}% with {days} days to go.'**
  String usedPercentInsight(Object percent, Object days);

  /// No description provided for @halfwayBudgetInsight.
  ///
  /// In en, this message translates to:
  /// **'Halfway through budget. {amount} remaining — stay consistent.'**
  String halfwayBudgetInsight(Object amount);

  /// No description provided for @savedThisMonthInsight.
  ///
  /// In en, this message translates to:
  /// **'Great discipline! You saved {amount} this month.'**
  String savedThisMonthInsight(Object amount);

  /// No description provided for @noSpendingInsight.
  ///
  /// In en, this message translates to:
  /// **'No spending yet. {amount} is ready to use.'**
  String noSpendingInsight(Object amount);

  /// No description provided for @onTrackInsight.
  ///
  /// In en, this message translates to:
  /// **'On track — {amount} left for the rest of the month.'**
  String onTrackInsight(Object amount);

  /// No description provided for @budgetFullyUsedInsight.
  ///
  /// In en, this message translates to:
  /// **'You\'ve used the entire budget with {days} days remaining.'**
  String budgetFullyUsedInsight(Object days);

  /// No description provided for @spendingReport.
  ///
  /// In en, this message translates to:
  /// **'Spending Report'**
  String get spendingReport;

  /// No description provided for @breakdown.
  ///
  /// In en, this message translates to:
  /// **'Breakdown'**
  String get breakdown;

  /// No description provided for @byCategory.
  ///
  /// In en, this message translates to:
  /// **'By Category'**
  String get byCategory;

  /// No description provided for @allocated.
  ///
  /// In en, this message translates to:
  /// **'Allocated'**
  String get allocated;

  /// No description provided for @spendingReportSpent.
  ///
  /// In en, this message translates to:
  /// **'Spent'**
  String get spendingReportSpent;

  /// No description provided for @spendingReportRemaining.
  ///
  /// In en, this message translates to:
  /// **'Remaining'**
  String get spendingReportRemaining;

  /// No description provided for @used.
  ///
  /// In en, this message translates to:
  /// **'Used'**
  String get used;

  /// No description provided for @noBudgetData.
  ///
  /// In en, this message translates to:
  /// **'No budget data to display.'**
  String get noBudgetData;

  /// No description provided for @aiInsightLabel.
  ///
  /// In en, this message translates to:
  /// **'AI Financial Insight'**
  String get aiInsightLabel;

  /// No description provided for @aiInsightRefreshTooltip.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get aiInsightRefreshTooltip;

  /// No description provided for @aiInsightJustNow.
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get aiInsightJustNow;

  /// No description provided for @aiInsightMinutesAgo.
  ///
  /// In en, this message translates to:
  /// **'{n} min ago'**
  String aiInsightMinutesAgo(int n);

  /// No description provided for @aiInsightHoursAgo.
  ///
  /// In en, this message translates to:
  /// **'{n}h ago'**
  String aiInsightHoursAgo(int n);

  /// No description provided for @aiInsightErrorMsg.
  ///
  /// In en, this message translates to:
  /// **'Could not load AI insight.'**
  String get aiInsightErrorMsg;

  /// No description provided for @aiInsightRetryBtn.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get aiInsightRetryBtn;

  /// No description provided for @budgetsScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Budgets'**
  String get budgetsScreenTitle;

  /// No description provided for @reportsTitle.
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get reportsTitle;

  /// No description provided for @localInsightsSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Quick Insights'**
  String get localInsightsSectionTitle;

  /// No description provided for @insightHighestSpending.
  ///
  /// In en, this message translates to:
  /// **'{category} is your biggest expense at {percent} of its budget.'**
  String insightHighestSpending(String category, String percent);

  /// No description provided for @insightOverBudget.
  ///
  /// In en, this message translates to:
  /// **'You\'ve exceeded your budget in: {categories}.'**
  String insightOverBudget(String categories);

  /// No description provided for @insightWarningTotal.
  ///
  /// In en, this message translates to:
  /// **'You\'ve used {percent} of your total monthly budget — slow down!'**
  String insightWarningTotal(String percent);

  /// No description provided for @insightGreatProgress.
  ///
  /// In en, this message translates to:
  /// **'Great discipline! Only {percent} of your budget spent so far.'**
  String insightGreatProgress(String percent);

  /// No description provided for @insightUnderUtilized.
  ///
  /// In en, this message translates to:
  /// **'Low spend in {categories} — consider reallocating the surplus.'**
  String insightUnderUtilized(String categories);

  /// No description provided for @insightNearLimit.
  ///
  /// In en, this message translates to:
  /// **'{category} is almost at its limit ({percent}).'**
  String insightNearLimit(String category, String percent);

  /// No description provided for @cloudinaryUploadFailed.
  ///
  /// In en, this message translates to:
  /// **'Cloudinary upload failed'**
  String get cloudinaryUploadFailed;

  /// No description provided for @failedToUpload.
  ///
  /// In en, this message translates to:
  /// **'Failed to upload'**
  String get failedToUpload;

  /// No description provided for @category_groceries.
  ///
  /// In en, this message translates to:
  /// **'Groceries'**
  String get category_groceries;

  /// No description provided for @category_travel.
  ///
  /// In en, this message translates to:
  /// **'Travel'**
  String get category_travel;

  /// No description provided for @category_entertainment.
  ///
  /// In en, this message translates to:
  /// **'Entertainment'**
  String get category_entertainment;

  /// No description provided for @category_food.
  ///
  /// In en, this message translates to:
  /// **'Food & Dining'**
  String get category_food;

  /// No description provided for @category_shopping.
  ///
  /// In en, this message translates to:
  /// **'Shopping'**
  String get category_shopping;

  /// No description provided for @category_custom.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get category_custom;

  /// No description provided for @deposit.
  ///
  /// In en, this message translates to:
  /// **'Deposit'**
  String get deposit;

  /// No description provided for @withdraw.
  ///
  /// In en, this message translates to:
  /// **'Withdraw'**
  String get withdraw;

  /// No description provided for @failedToSave.
  ///
  /// In en, this message translates to:
  /// **'Failed to save: {error}'**
  String failedToSave(Object error);

  /// No description provided for @replaceCurrentCategories.
  ///
  /// In en, this message translates to:
  /// **'Replace Current Categories?'**
  String get replaceCurrentCategories;

  /// No description provided for @replaceCategoriesWarning.
  ///
  /// In en, this message translates to:
  /// **'Applying this template will remove your current category budgets and replace them with the template categories.'**
  String get replaceCategoriesWarning;

  /// No description provided for @replace.
  ///
  /// In en, this message translates to:
  /// **'Replace'**
  String get replace;

  /// No description provided for @overBy.
  ///
  /// In en, this message translates to:
  /// **'⚠️ Over by {amount}'**
  String overBy(Object amount);

  /// No description provided for @offlineBanner.
  ///
  /// In en, this message translates to:
  /// **'You\'re offline — changes will sync when reconnected'**
  String get offlineBanner;

  /// No description provided for @backendErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Server Connection Error'**
  String get backendErrorTitle;

  /// No description provided for @backendErrorSubtitle.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t retrieve your transaction history. Please check your internet connection or try again later.'**
  String get backendErrorSubtitle;

  /// No description provided for @photoUploadFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to upload photo'**
  String get photoUploadFailed;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @buyActionAmount.
  ///
  /// In en, this message translates to:
  /// **'🛒 Buy {amount} of {assetName}'**
  String buyActionAmount(Object amount, Object assetName);

  /// No description provided for @sellActionPercent.
  ///
  /// In en, this message translates to:
  /// **'💰 Sell {percent}% of {assetName}'**
  String sellActionPercent(Object percent, Object assetName);

  /// No description provided for @currentPriceLabel.
  ///
  /// In en, this message translates to:
  /// **'{price} current price'**
  String currentPriceLabel(Object price);

  /// No description provided for @alpacaSymbolLabel.
  ///
  /// In en, this message translates to:
  /// **'Alpaca symbol: {symbol}'**
  String alpacaSymbolLabel(Object symbol);

  /// No description provided for @dashboardBuySuccess.
  ///
  /// In en, this message translates to:
  /// **'✅ Bought {amount} of {assetName}'**
  String dashboardBuySuccess(Object amount, Object assetName);

  /// No description provided for @orderSubmittedSuccess.
  ///
  /// In en, this message translates to:
  /// **'✅ {actionType} — order submitted to Alpaca'**
  String orderSubmittedSuccess(Object actionType);

  /// No description provided for @boughtLabel.
  ///
  /// In en, this message translates to:
  /// **'Bought'**
  String get boughtLabel;

  /// No description provided for @soldLabel.
  ///
  /// In en, this message translates to:
  /// **'Sold'**
  String get soldLabel;

  /// No description provided for @suggestedLabel.
  ///
  /// In en, this message translates to:
  /// **'{amount} suggested • {horizon}'**
  String suggestedLabel(Object amount, Object horizon);

  /// No description provided for @tradeBuyLabel.
  ///
  /// In en, this message translates to:
  /// **'Trade: BUY {amount} of {assetName}'**
  String tradeBuyLabel(Object amount, Object assetName);

  /// No description provided for @tradeSellLabel.
  ///
  /// In en, this message translates to:
  /// **'Trade: SELL {percent}% of {assetName}'**
  String tradeSellLabel(Object percent, Object assetName);

  /// No description provided for @unrealizedPnlLabel.
  ///
  /// In en, this message translates to:
  /// **'{amount} unrealized P&L'**
  String unrealizedPnlLabel(Object amount);

  /// No description provided for @cashLabel.
  ///
  /// In en, this message translates to:
  /// **'Cash: {amount}'**
  String cashLabel(Object amount);

  /// No description provided for @buyingPowerLabel.
  ///
  /// In en, this message translates to:
  /// **'Buying power: {amount}'**
  String buyingPowerLabel(Object amount);

  /// No description provided for @unitsLabel.
  ///
  /// In en, this message translates to:
  /// **'{count} units'**
  String unitsLabel(Object count);

  /// No description provided for @valueLabel.
  ///
  /// In en, this message translates to:
  /// **'Value: {amount}'**
  String valueLabel(Object amount);

  /// No description provided for @pnlLabel.
  ///
  /// In en, this message translates to:
  /// **'P&L: {amount}'**
  String pnlLabel(Object amount);

  /// No description provided for @closePositionBtn.
  ///
  /// In en, this message translates to:
  /// **'Close Position'**
  String get closePositionBtn;

  /// No description provided for @closedSuccess.
  ///
  /// In en, this message translates to:
  /// **'✅ Closed {assetName} — order submitted'**
  String closedSuccess(Object assetName);

  /// No description provided for @passwordUpdatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Password updated successfully!'**
  String get passwordUpdatedSuccessfully;

  /// No description provided for @emailAlreadyInUse.
  ///
  /// In en, this message translates to:
  /// **'This email is already in use.'**
  String get emailAlreadyInUse;

  /// No description provided for @weakPassword.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters.'**
  String get weakPassword;

  /// No description provided for @invalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email.'**
  String get invalidEmail;

  /// No description provided for @registrationFailed.
  ///
  /// In en, this message translates to:
  /// **'Registration failed'**
  String get registrationFailed;

  /// No description provided for @unexpectedError.
  ///
  /// In en, this message translates to:
  /// **'An unexpected error occurred. Please try again.'**
  String get unexpectedError;

  /// No description provided for @userNotFound.
  ///
  /// In en, this message translates to:
  /// **'No account found with this email.'**
  String get userNotFound;

  /// No description provided for @wrongPassword.
  ///
  /// In en, this message translates to:
  /// **'Incorrect password.'**
  String get wrongPassword;

  /// No description provided for @loginFailed.
  ///
  /// In en, this message translates to:
  /// **'Login failed'**
  String get loginFailed;

  /// No description provided for @googleSignInCancelled.
  ///
  /// In en, this message translates to:
  /// **'Google sign in was cancelled.'**
  String get googleSignInCancelled;

  /// No description provided for @googleSignInFailed.
  ///
  /// In en, this message translates to:
  /// **'Google sign in failed. Please try again.'**
  String get googleSignInFailed;

  /// No description provided for @passwordResetFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to send password reset email'**
  String get passwordResetFailed;

  /// No description provided for @changePasswordUserNotFound.
  ///
  /// In en, this message translates to:
  /// **'User not found.'**
  String get changePasswordUserNotFound;

  /// No description provided for @changePasswordWrongPassword.
  ///
  /// In en, this message translates to:
  /// **'The old password you entered is incorrect.'**
  String get changePasswordWrongPassword;

  /// No description provided for @errorNoMarketData.
  ///
  /// In en, this message translates to:
  /// **'⚠️ No market data — skipping cycle.'**
  String get errorNoMarketData;

  /// No description provided for @errorAnalysisFailed.
  ///
  /// In en, this message translates to:
  /// **'❌ Analysis failed — API error.'**
  String get errorAnalysisFailed;

  /// No description provided for @errorParsePositions.
  ///
  /// In en, this message translates to:
  /// **'⚠️ Could not parse position decisions: {error}'**
  String errorParsePositions(Object error);

  /// No description provided for @errorParseBuyOpps.
  ///
  /// In en, this message translates to:
  /// **'⚠️ Could not parse buy opportunities: {error}'**
  String errorParseBuyOpps(Object error);

  /// No description provided for @errorCycle.
  ///
  /// In en, this message translates to:
  /// **'❌ Cycle error: {error}'**
  String errorCycle(Object error);

  /// No description provided for @alpaca_not_configured_settings.
  ///
  /// In en, this message translates to:
  /// **'Alpaca API not configured. Add your API keys in Settings.'**
  String get alpaca_not_configured_settings;

  /// No description provided for @alpaca_not_configured.
  ///
  /// In en, this message translates to:
  /// **'Alpaca not configured.'**
  String get alpaca_not_configured;

  /// No description provided for @order_failed.
  ///
  /// In en, this message translates to:
  /// **'Order failed.'**
  String get order_failed;

  /// No description provided for @close_failed.
  ///
  /// In en, this message translates to:
  /// **'Close failed ({error}).'**
  String close_failed(String error, Object statusCode);

  /// No description provided for @sell_failed.
  ///
  /// In en, this message translates to:
  /// **'Sell failed ({error}).'**
  String sell_failed(String error, Object statusCode);

  /// No description provided for @alpaca_api_error.
  ///
  /// In en, this message translates to:
  /// **'Alpaca error: {message}'**
  String alpaca_api_error(String message);

  /// No description provided for @alpaca_exception.
  ///
  /// In en, this message translates to:
  /// **'An unexpected error occurred: {exception}'**
  String alpaca_exception(String exception);

  /// No description provided for @registration_failed.
  ///
  /// In en, this message translates to:
  /// **'Registration failed: {message}'**
  String registration_failed(String message);

  /// No description provided for @login_failed.
  ///
  /// In en, this message translates to:
  /// **'Login failed: {message}'**
  String login_failed(String message);

  /// No description provided for @password_reset_failed.
  ///
  /// In en, this message translates to:
  /// **'Password reset failed: {message}'**
  String password_reset_failed(String message);

  /// No description provided for @auth_generic_message.
  ///
  /// In en, this message translates to:
  /// **'Authentication error: {message}'**
  String auth_generic_message(String message);

  /// No description provided for @auto_trade_enabled.
  ///
  /// In en, this message translates to:
  /// **'🤖 Auto-trade enabled. Cycle every {interval}.'**
  String auto_trade_enabled(String interval);

  /// No description provided for @auto_trade_disabled.
  ///
  /// In en, this message translates to:
  /// **'⏸ Auto-trade disabled.'**
  String get auto_trade_disabled;

  /// No description provided for @cycle_started_gathering.
  ///
  /// In en, this message translates to:
  /// **'📡 Cycle started — gathering live market data...'**
  String get cycle_started_gathering;

  /// No description provided for @no_market_data.
  ///
  /// In en, this message translates to:
  /// **'⚠️ No market data — skipping cycle.'**
  String get no_market_data;

  /// No description provided for @data_ready.
  ///
  /// In en, this message translates to:
  /// **'✅ Data ready: {assets} assets, {news} headlines, {positions} open positions, \${cash} cash'**
  String data_ready(Object assets, Object news, Object positions, Object cash);

  /// No description provided for @step_analyzing_sentiment.
  ///
  /// In en, this message translates to:
  /// **'🔍 Step 1/3 — Analyzing market sentiment & news...'**
  String get step_analyzing_sentiment;

  /// No description provided for @analysis_failed.
  ///
  /// In en, this message translates to:
  /// **'❌ Analysis failed — API error.'**
  String get analysis_failed;

  /// No description provided for @sentiment_preview.
  ///
  /// In en, this message translates to:
  /// **'📊 Sentiment: {preview}...'**
  String sentiment_preview(Object preview);

  /// No description provided for @step_evaluating_positions.
  ///
  /// In en, this message translates to:
  /// **'⚖️ Step 2/3 — Evaluating each open position...'**
  String get step_evaluating_positions;

  /// No description provided for @position_hold.
  ///
  /// In en, this message translates to:
  /// **'✅ HOLD {name}: {reason}'**
  String position_hold(Object name, Object reason);

  /// No description provided for @position_action.
  ///
  /// In en, this message translates to:
  /// **'⚡ {action} {name}: {reason}'**
  String position_action(Object action, Object name, Object reason);

  /// No description provided for @position_closed.
  ///
  /// In en, this message translates to:
  /// **'✅ {name} closed at market price'**
  String position_closed(Object name);

  /// No description provided for @parse_positions_error.
  ///
  /// In en, this message translates to:
  /// **'⚠️ Could not parse position decisions: {error}'**
  String parse_positions_error(Object error);

  /// No description provided for @no_open_positions.
  ///
  /// In en, this message translates to:
  /// **'📂 No open positions to evaluate.'**
  String get no_open_positions;

  /// No description provided for @step_scanning_buy_opps.
  ///
  /// In en, this message translates to:
  /// **'🔎 Step 3/3 — Scanning for new buy opportunities...'**
  String get step_scanning_buy_opps;

  /// No description provided for @parse_buy_opps_error.
  ///
  /// In en, this message translates to:
  /// **'⚠️ Could not parse buy opportunities: {error}'**
  String parse_buy_opps_error(Object error);

  /// No description provided for @buy_opportunities_found.
  ///
  /// In en, this message translates to:
  /// **'💡 Found {count} buy opportunities — awaiting your approval.'**
  String buy_opportunities_found(Object count);

  /// No description provided for @no_buy_opportunities.
  ///
  /// In en, this message translates to:
  /// **'📉 No strong buy opportunities found. Cash held for next cycle.'**
  String get no_buy_opportunities;

  /// No description provided for @cycle_complete_with_sells.
  ///
  /// In en, this message translates to:
  /// **'✅ Cycle complete. {count} sell(s) executed. Next run: {nextRun}'**
  String cycle_complete_with_sells(Object count, Object nextRun);

  /// No description provided for @cycle_complete_no_sells.
  ///
  /// In en, this message translates to:
  /// **'✅ Cycle complete. Next run: {nextRun}'**
  String cycle_complete_no_sells(Object nextRun);

  /// No description provided for @cycle_error.
  ///
  /// In en, this message translates to:
  /// **'❌ Cycle error: {error}'**
  String cycle_error(Object error);

  /// No description provided for @budget_warning_title.
  ///
  /// In en, this message translates to:
  /// **'Budget Warning'**
  String get budget_warning_title;

  /// No description provided for @budget_warning_body.
  ///
  /// In en, this message translates to:
  /// **'You have used {percentUsed}% of your {category} budget.'**
  String budget_warning_body(Object category, Object percentUsed);

  /// No description provided for @category_transport.
  ///
  /// In en, this message translates to:
  /// **'Transportation'**
  String get category_transport;

  /// No description provided for @category_bills.
  ///
  /// In en, this message translates to:
  /// **'Bills & Utilities'**
  String get category_bills;

  /// Fallback text for a recurring transaction without a specific note
  ///
  /// In en, this message translates to:
  /// **'{title} (recurring)'**
  String recurring_fallback(String title);

  /// Prefix applied to automatically generated recurring transactions
  ///
  /// In en, this message translates to:
  /// **'[Auto] {note}'**
  String auto_prefix(String note);

  /// Error displayed when the server rejects the profile picture upload
  ///
  /// In en, this message translates to:
  /// **'Cloudinary upload failed. Please try again.'**
  String get cloudinary_upload_failed;

  /// Generic fallback upload failure message
  ///
  /// In en, this message translates to:
  /// **'Failed to upload image due to a network or system error.'**
  String get failed_to_upload;

  /// No description provided for @notifBudgetExceededTitle.
  ///
  /// In en, this message translates to:
  /// **'🚨 Budget Exceeded: {title}'**
  String notifBudgetExceededTitle(Object title);

  /// No description provided for @notifBudgetExceededBody.
  ///
  /// In en, this message translates to:
  /// **'You have gone over your {title} budget!'**
  String notifBudgetExceededBody(Object title);

  /// No description provided for @notifBudgetWarningTitle.
  ///
  /// In en, this message translates to:
  /// **'⚠️ Budget Alert: {title}'**
  String notifBudgetWarningTitle(Object title);

  /// No description provided for @notifBudgetWarningBody.
  ///
  /// In en, this message translates to:
  /// **'You\'ve used {percent}% of your {title} budget with {days} days left.'**
  String notifBudgetWarningBody(Object days, Object percent, Object title);

  /// No description provided for @notifSavingsTitle.
  ///
  /// In en, this message translates to:
  /// **'🎉 Savings Goal Progress'**
  String get notifSavingsTitle;

  /// No description provided for @notifSavingsBody.
  ///
  /// In en, this message translates to:
  /// **'You\'re {percent}% of the way to your monthly savings goal!'**
  String notifSavingsBody(Object percent);

  /// No description provided for @notifWeeklyTitle.
  ///
  /// In en, this message translates to:
  /// **'Your Weekly Spending Recap 📊'**
  String get notifWeeklyTitle;

  /// No description provided for @notifWeeklyBody.
  ///
  /// In en, this message translates to:
  /// **'You used {percent}% of your budget. Most spent: {category}.'**
  String notifWeeklyBody(Object category, Object percent);

  /// Option to remove profile picture
  ///
  /// In en, this message translates to:
  /// **'Remove Photo'**
  String get removePhoto;

  /// Confirmation message before removing photo
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to remove your profile picture?'**
  String get removePhotoConfirm;

  /// Confirm remove action button
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get remove;

  /// Loading message while removing photo
  ///
  /// In en, this message translates to:
  /// **'Removing photo...'**
  String get removingPhoto;

  /// Success message after removing photo
  ///
  /// In en, this message translates to:
  /// **'Profile picture removed'**
  String get photoRemoved;

  /// Error message when photo removal fails
  ///
  /// In en, this message translates to:
  /// **'Failed to remove photo'**
  String get photoRemoveFailed;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
