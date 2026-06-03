// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Mindful Curator';

  @override
  String get goodMorning => 'Good Morning';

  @override
  String get goodAfternoon => 'Good Afternoon';

  @override
  String get goodEvening => 'Good Evening';

  @override
  String get welcomeBack => 'Welcome back';

  @override
  String get monthlyBudget => 'Monthly Budget';

  @override
  String get monthlyBudgetGoal => 'Monthly Savings Goal';

  @override
  String get totalBudget => 'Total Budget';

  @override
  String get totalSpent => 'Total Spent';

  @override
  String get totalSaved => 'Total Saved';

  @override
  String get remaining => 'Remaining';

  @override
  String get available => 'Available';

  @override
  String get completed => 'Completed';

  @override
  String get thisMonth => 'this month';

  @override
  String get spent => 'Spent';

  @override
  String get saved => 'Saved';

  @override
  String get spendingBreakdown => 'Spending Breakdown';

  @override
  String get allOnTrack => 'All categories on track';

  @override
  String get nearLimit => 'near limit';

  @override
  String get noSpendingYet => 'No spending recorded yet';

  @override
  String get noSpendingDesc =>
      'Your spending chart will appear here once you log your first expense.';

  @override
  String get budgets => 'Budgets';

  @override
  String get addBudget => 'Add Budget';

  @override
  String get editBudget => 'Edit Budget';

  @override
  String get deleteBudget => 'Delete Budget';

  @override
  String get noBudgets => 'No budgets yet';

  @override
  String get noBudgetsDesc =>
      'Tap the + button to create your first budget category.';

  @override
  String get categoryName => 'Category Name';

  @override
  String get categorySubtitle => 'Subtitle (optional)';

  @override
  String get allocatedAmount => 'Allocated Amount';

  @override
  String get categories => 'Categories';

  @override
  String get saveAsTemplate => 'Save as template';

  @override
  String get useTemplate => 'Use a Template';

  @override
  String get useSavedTemplate => 'Use a saved template';

  @override
  String get subtractMoney => 'Subtract Money (Spend)';

  @override
  String get addMoney => 'Add Money (Income)';

  @override
  String get amount => 'Amount';

  @override
  String get note => 'Note';

  @override
  String get noteHint => 'e.g. Netflix subscription';

  @override
  String get makeRecurring => 'Make Recurring';

  @override
  String get everyMonth => 'Every Month';

  @override
  String get everyWeek => 'Every Week';

  @override
  String get expenseLabel => 'Expense';

  @override
  String get incomeLabel => 'Income';

  @override
  String get profile => 'Profile';

  @override
  String get fullName => 'Full Name';

  @override
  String get email => 'Email';

  @override
  String get free => 'Free';

  @override
  String get upgrade => 'Upgrade';

  @override
  String get notifications => 'Notifications';

  @override
  String get language => 'Language';

  @override
  String get logoutConfirmBody => 'Are you sure you want to log out?';

  @override
  String get photoFailed => 'Failed to upload photo';

  @override
  String get ok => 'OK';

  @override
  String get home => 'Home';

  @override
  String get invest => 'Invest';

  @override
  String get loading => 'Loading...';

  @override
  String get userDataNotFound => 'User data not found';

  @override
  String get newBudget => 'New Budget';

  @override
  String get reports => 'Reports';

  @override
  String get insights => 'Insights';

  @override
  String get reportsComingSoon => 'Reports coming soon!';

  @override
  String get insightsComingSoon => 'Insights coming soon!';

  @override
  String get activeBudgets => 'Active Budgets';

  @override
  String get manage => 'Manage';

  @override
  String get noBudgetsYet => 'No budgets yet';

  @override
  String get tapNewBudgetToStart =>
      'Tap \"New Budget\" above to start tracking';

  @override
  String get createFirstBudget => 'Create First Budget';

  @override
  String get editSavingsGoal => 'Edit Savings Goal';

  @override
  String get monthlyGoal => 'Monthly Goal (\$)';

  @override
  String get enterMonthlySavingsGoal => 'Enter your monthly savings goal';

  @override
  String get emailAddress => 'Email Address';

  @override
  String get password => 'Password';

  @override
  String get enterEmail => 'Please enter your email';

  @override
  String get validEmail => 'Please enter a valid email';

  @override
  String get enterPassword => 'Please enter your password';

  @override
  String get passwordMin => 'Password must be at least 6 characters';

  @override
  String get forgotPassword => 'Forgot Password?';

  @override
  String get signIn => 'Sign In';

  @override
  String get continueGoogle => 'Continue with Google';

  @override
  String get dontHaveAccount => 'Don\'t have an account?';

  @override
  String get signUp => 'Sign Up';

  @override
  String get welcomeLogin => 'Welcome back! Sign in to continue';

  @override
  String welcomeUser(String name) {
    return 'Welcome back, $name!';
  }

  @override
  String daysLeftText(int days) {
    return '$days Days Left';
  }

  @override
  String savedGoalText(String saved, String goal) {
    return 'Saved: $saved • Goal: $goal';
  }

  @override
  String amountLeftText(String amount) {
    return '\$$amount left';
  }

  @override
  String get createAccount => 'Create Account';

  @override
  String get registerSubtitle => 'Start your mindful money journey';

  @override
  String get alreadyHaveAccount => 'Already have an account?';

  @override
  String get fullNameHint => 'Enter your name';

  @override
  String get emailHint => 'you@example.com';

  @override
  String get passwordHintRegister => 'At least 6 characters';

  @override
  String get passwordHintLogin => 'Enter your password';

  @override
  String get confirmPasswordHint => 'Re-enter your password';

  @override
  String get enterNameError => 'Please enter your name';

  @override
  String get nameTooShortError => 'Name must be at least 2 characters';

  @override
  String get enterEmailError => 'Please enter your email';

  @override
  String get validEmailError => 'Please enter a valid email';

  @override
  String get enterPasswordError => 'Please enter a password';

  @override
  String get passwordLengthError => 'Password must be at least 6 characters';

  @override
  String get confirmPasswordError => 'Please confirm your password';

  @override
  String get passwordMismatchError => 'Passwords do not match';

  @override
  String get accountCreatedSuccess => 'Account created successfully!';

  @override
  String get aiInvest => 'AI Invest';

  @override
  String get dashboard => 'Dashboard';

  @override
  String get markets => 'Markets';

  @override
  String get aiAdvisor => 'AI Advisor';

  @override
  String get positions => 'Positions';

  @override
  String get connectAlpacaAccount => 'Connect Your Alpaca Account';

  @override
  String get alpacaDescription =>
      'Trade Gold ETF, Silver ETF, Bitcoin, Ethereum and stocks — all from one account.\n\nStart with free Paper Trading (\$100k virtual cash).';

  @override
  String get connectAlpacaFirst => 'Connect Alpaca first';

  @override
  String get noOpenPositions => 'No open positions';

  @override
  String get connectToSeePositions =>
      'Connect Alpaca to see your live positions';

  @override
  String get chatHint =>
      'Ask anything — analyze portfolio, buy gold, market outlook...';

  @override
  String get loadingAgent => 'Loading AI agent...';

  @override
  String get aiAnalyzing => 'AI Agent is analyzing...';

  @override
  String get livePrices => 'Live Prices';

  @override
  String get updated => 'Updated';

  @override
  String get connectAlpaca => 'Connect Alpaca';

  @override
  String get refresh => 'Refresh';

  @override
  String get live => 'LIVE';

  @override
  String get alpacaIntro =>
      'Trade Gold ETF, Silver ETF, Bitcoin, Ethereum and stocks — all from one account.\n\nStart with free Paper Trading (\$100k virtual cash).';

  @override
  String get chatWithAi => 'Or just chat with AI →';

  @override
  String get metals => 'Metals';

  @override
  String get crypto => 'Crypto';

  @override
  String get usStocks => 'US Stocks';

  @override
  String get showOpportunities => 'Show opportunities';

  @override
  String get investBestPick => 'Invest in best pick';

  @override
  String get fullAutoScan => 'Full auto-scan';

  @override
  String get portfolioReview => 'Portfolio review';

  @override
  String get lockInGains => 'Lock in gains';

  @override
  String get execute => 'Execute';

  @override
  String get noAlpacaConnected => 'No Alpaca account connected';

  @override
  String get connectAlpacaPositions =>
      'Connect Alpaca to see your live positions';

  @override
  String get openPositions => 'Open Positions';

  @override
  String get dashboardOpportunities =>
      'Use the Dashboard to find and invest in opportunities';

  @override
  String get closePosition => 'Close Position';

  @override
  String get livePortfolio => 'LIVE PORTFOLIO';

  @override
  String get autoRefresh30s => 'Auto-refresh 30s';

  @override
  String get entryPrice => 'Entry price';

  @override
  String get currentPrice => 'Current price';

  @override
  String get marketValue => 'Market value';

  @override
  String get sellPosition => 'Sell Position';

  @override
  String get value => 'Value';

  @override
  String get profitLoss => 'P&L';

  @override
  String tradeBuy(Object amount, Object asset) {
    return 'Trade: BUY \$$amount of $asset';
  }

  @override
  String tradeSell(Object percent, Object asset) {
    return 'Trade: SELL $percent% of $asset';
  }

  @override
  String positionClosed(Object name) {
    return '✅ Closed $name — order submitted';
  }

  @override
  String get autoTradeDisabled => 'Auto-trade disabled by user.';

  @override
  String get autoTradeEnabled =>
      'Auto-trade enabled. Hourly analysis will run in background.';

  @override
  String autoSold(Object symbol) {
    return 'AUTO-SOLD $symbol at market price';
  }

  @override
  String autoSellFailed(Object error) {
    return 'Auto-sell failed: $error';
  }

  @override
  String aiFoundOpportunities(Object count) {
    return 'AI found $count buy opportunities — your approval needed';
  }

  @override
  String get view => 'View';

  @override
  String notOnAlpacaYet(Object asset) {
    return '$asset not on Alpaca yet';
  }

  @override
  String boughtAsset(Object amount, Object asset) {
    return 'Bought \$$amount of $asset';
  }

  @override
  String get confirmBuy => 'Confirm Buy';

  @override
  String get confirmSell => 'Confirm Sell';

  @override
  String buyAssetAmount(Object amount, Object asset) {
    return 'Buy \$$amount of $asset';
  }

  @override
  String sellAssetPercent(Object percent, Object asset) {
    return 'Sell $percent% of $asset';
  }

  @override
  String get alpacaSymbol => 'Alpaca symbol';

  @override
  String get realOrderWarning => '⚠️ This will place a REAL order on Alpaca.';

  @override
  String get paperTradeWarning => '📄 Paper trade — no real money moves.';

  @override
  String get executeBuy => 'Execute Buy ✓';

  @override
  String get executeSell => 'Execute Sell ✓';

  @override
  String get boughtOrderSubmitted => 'Bought — order submitted to Alpaca';

  @override
  String get soldOrderSubmitted => 'Sold — order submitted to Alpaca';

  @override
  String get units => 'units';

  @override
  String get unrealizedPnL => 'unrealized P&L';

  @override
  String cashBuyingPower(Object cash, Object power) {
    return 'Cash: \$$cash • Buying power: \$$power';
  }

  @override
  String get pnl => 'P&L';

  @override
  String get closePositionButton => 'Close Position';

  @override
  String closedPositionOrderSubmitted(Object asset) {
    return 'Closed $asset — order submitted';
  }

  @override
  String get alpacaSettingsTitle => 'Connect Alpaca Account';

  @override
  String get alpacaHowToTitle => '🔗 How to get your API keys';

  @override
  String get alpacaStep1 => 'Sign up FREE at alpaca.markets';

  @override
  String get alpacaStep2 => 'Go to Paper Trading → API Keys';

  @override
  String get alpacaStep3 => 'Generate a new key & copy both values below';

  @override
  String get alpacaStep4 => 'Start in Paper mode (fake money) to test safely';

  @override
  String get alpacaPaperInfo =>
      '💰 Alpaca gives you \$100,000 virtual cash in Paper mode.';

  @override
  String get alpacaTradingMode => 'Trading Mode';

  @override
  String get alpacaPaperMode => '📄 Paper (Safe)';

  @override
  String get alpacaLiveMode => '💵 Live (Real Money)';

  @override
  String get alpacaLiveWarning =>
      '⚠️ Live mode uses REAL money. Make sure you understand the risks.';

  @override
  String get alpacaApiKey => 'API Key ID';

  @override
  String get alpacaApiKeyHint => 'PKXXXXXXXXXXXXXXXXXXXXXXXX';

  @override
  String get alpacaSecretKey => 'API Secret Key';

  @override
  String get alpacaSecretHint => '••••••••••••••••••••••••••••••••••••••••';

  @override
  String get alpacaConnectButton => 'Connect & Test';

  @override
  String get alpacaTesting => 'Testing connection...';

  @override
  String get alpacaMissingFields => 'Please enter both API Key and Secret';

  @override
  String get alpacaConnectionFailed => 'Connection failed. Check your keys.';

  @override
  String get alpacaConnectedSnackbar => '✅ Alpaca connected! Ready to trade.';

  @override
  String get alpacaConnected => '✅ Connected!';

  @override
  String get alpacaCash => 'Cash';

  @override
  String get alpacaBuyingPower => 'Buying Power';

  @override
  String get alpacaPortfolioValue => 'Portfolio Value';

  @override
  String get alpacaStatus => 'Status';

  @override
  String get notLoggedIn => 'Not logged in.';

  @override
  String setMonthlyBudget(String monthName) {
    return 'Set Budget for $monthName';
  }

  @override
  String get editMonthlyBudget => 'Edit Monthly Budget';

  @override
  String get monthlyBudgetDescription =>
      'This is your total spending limit for the month.';

  @override
  String get totalMonthlyBudget => 'Total Monthly Budget';

  @override
  String get totalMonthlyBudgetLabel => 'Total monthly budget';

  @override
  String get fullyAllocated => 'Fully Allocated';

  @override
  String fullyAllocatedDescription(String amount) {
    return 'You have allocated all \$$amount. Edit or delete a category to free up money.';
  }

  @override
  String get addCategoryBudget => 'Add Category Budget';

  @override
  String availableToAssign(String amount) {
    return '\$$amount available to assign';
  }

  @override
  String get groceriesHint => 'e.g. Groceries';

  @override
  String maxAmount(String amount) {
    return 'Max $amount';
  }

  @override
  String get newCategory => 'New Category';

  @override
  String get category => 'Category';

  @override
  String amountExceedsRemaining(String amount) {
    return 'Amount exceeds remaining \$$amount';
  }

  @override
  String get addMoneyDeposit => 'Add Money (Deposit)';

  @override
  String get subtractMoneySpend => 'Subtract Money (Spend)';

  @override
  String get noteOptional => 'Note (optional)';

  @override
  String get salaryHint => 'e.g. Salary';

  @override
  String get netflixHint => 'e.g. Netflix';

  @override
  String get editBudgetAmount => 'Edit Budget Amount';

  @override
  String deleteBudgetQuestion(String title) {
    return 'Delete \"$title\"? This cannot be undone.';
  }

  @override
  String get allocatedToCategories => 'Allocated to categories';

  @override
  String get unallocated => 'Unallocated';

  @override
  String get fullyAllocatedCheck => '✓ Fully allocated';

  @override
  String get noCategoriesYet => 'No categories yet';

  @override
  String get divideBudgetHint => 'Tap + to divide your budget into categories.';

  @override
  String spentAmount(String amount) {
    return 'Spent: \$$amount';
  }

  @override
  String leftAmount(String amount) {
    return '\$$amount left';
  }

  @override
  String get useAsTemplate => 'Use template';

  @override
  String get pickTemplate => 'Pick a saved template to apply.';

  @override
  String get noTemplatesYet => 'No templates yet';

  @override
  String templateDescription(String count) {
    return 'Save these $count categories and their allocated amounts as a reusable template.';
  }

  @override
  String get templateName => 'Template Name';

  @override
  String get monthlyBudgetTemplate => 'Monthly Budget Template';

  @override
  String get saveTemplate => 'Save Template';

  @override
  String templateSaved(String name) {
    return '✅ \"$name\" saved as template!';
  }

  @override
  String get transactionHistory => 'Transaction History';

  @override
  String get addCategoryFirst =>
      'Add at least one category before saving a template.';

  @override
  String defaultTemplateName(String monthName) {
    return '$monthName Template';
  }

  @override
  String templateSummary(String count, String total) {
    return '$count categories · \$$total total';
  }

  @override
  String get noTemplatesHint =>
      'Save your current budget setup as a template to reuse it next month.';

  @override
  String templateApplied(String name) {
    return '✅ \"$name\" applied! Adjust amounts as needed.';
  }

  @override
  String get failedToLoadCategories => 'Failed to load categories';

  @override
  String noBudgetForMonth(Object monthName) {
    return 'No budget for $monthName';
  }

  @override
  String get budgetSetupDescription =>
      'Set a total amount, then divide it into categories.';

  @override
  String get addCategoryBeforeTemplate =>
      'Add at least one category before saving a template.';

  @override
  String get use => 'Use';

  @override
  String get edit => 'Edit';

  @override
  String get setupMonthTemplate =>
      'Set up a month and tap \"Save as Template\".';

  @override
  String get add => 'Add';

  @override
  String get resetPassword => 'Reset Password';

  @override
  String get resetPasswordDescription =>
      'Enter your email address and we\'ll send you a link to reset your password.';

  @override
  String get resetPasswordEmailSentDescription =>
      'Check your email for a link to reset your password.';

  @override
  String get pleaseEnterEmail => 'Please enter your email';

  @override
  String get pleaseEnterValidEmail => 'Please enter a valid email address';

  @override
  String get sendResetLink => 'Send Reset Link';

  @override
  String get backToLogin => 'Back to Login';

  @override
  String get passwordResetEmailSent =>
      'Password reset email sent successfully!';

  @override
  String get choosePhotoSource => 'Choose Photo Source';

  @override
  String get takePhoto => 'Take Photo';

  @override
  String get chooseFromGallery => 'Choose from Gallery';

  @override
  String get uploadingPhoto => 'Uploading photo...';

  @override
  String get profileUpdated => 'Profile picture updated!';

  @override
  String get uploadFailed => 'Failed to upload photo';

  @override
  String get account => 'Account';

  @override
  String get membership => 'Membership';

  @override
  String get settings => 'Settings';

  @override
  String get currentPlan => 'CURRENT PLAN';

  @override
  String get privacySecurity => 'Privacy & Security';

  @override
  String get logout => 'Logout';

  @override
  String get logoutConfirmTitle => 'Log Out';

  @override
  String get logoutConfirmMessage => 'Are you sure you want to log out?';

  @override
  String get cancel => 'Cancel';

  @override
  String get editName => 'Edit Name';

  @override
  String get save => 'Save';

  @override
  String get appVersion => 'App Version 1.0.0';

  @override
  String get recurring => 'Recurring';

  @override
  String get noRecurringTitle => 'No recurring transactions';

  @override
  String get noRecurringSubtitle =>
      'When you add or spend money, check \"Make recurring\" to set it on repeat.';

  @override
  String get deleteRecurringTitle => 'Delete recurring transaction?';

  @override
  String deleteRecurringMessage(Object note) {
    return '\"$note\" will no longer be applied automatically.';
  }

  @override
  String get delete => 'Delete';

  @override
  String get next => 'Next';

  @override
  String get monthJan => 'Jan';

  @override
  String get monthFeb => 'Feb';

  @override
  String get monthMar => 'Mar';

  @override
  String get monthApr => 'Apr';

  @override
  String get monthMay => 'May';

  @override
  String get monthJun => 'Jun';

  @override
  String get monthJul => 'Jul';

  @override
  String get monthAug => 'Aug';

  @override
  String get monthSep => 'Sep';

  @override
  String get monthOct => 'Oct';

  @override
  String get monthNov => 'Nov';

  @override
  String get monthDec => 'Dec';

  @override
  String nextDue(Object date) {
    return 'Next: $date';
  }

  @override
  String get transactions => 'Transactions';

  @override
  String get searchHint => 'Search by note or category…';

  @override
  String get newest => 'Newest';

  @override
  String get largest => 'Largest';

  @override
  String get all => 'All';

  @override
  String get expenses => 'Expenses';

  @override
  String get income => 'Income';

  @override
  String get allCategories => 'All categories';

  @override
  String get today => 'Today';

  @override
  String get yesterday => 'Yesterday';

  @override
  String get noResults => 'No results found';

  @override
  String get noTransactions => 'No transactions yet';

  @override
  String get noResultsHint => 'Try adjusting your search or filters.';

  @override
  String get noTransactionsHint =>
      'Your deposits and spending will appear here.';

  @override
  String get clearFilters => 'Clear all filters';

  @override
  String get auto => 'Auto';

  @override
  String transactionsCount(String count) {
    return '$count transactions';
  }

  @override
  String get autoPrefix => '[Auto] ';

  @override
  String get autoLabel => 'Auto';

  @override
  String get am => 'AM';

  @override
  String get pm => 'PM';

  @override
  String get privacyAndSecurity => 'Privacy & Security';

  @override
  String get securitySettings => 'Security Settings';

  @override
  String get googleAccountManaged => 'Your account is managed via Google.';

  @override
  String get keepAccountSecure =>
      'Keep your account secure by updating your password regularly.';

  @override
  String get signedInWithGoogle => 'Signed in with Google';

  @override
  String get googlePasswordInfo =>
      'Because you use Google Sign-In, you can manage your password directly in your Google Account settings.';

  @override
  String get currentPassword => 'Current Password';

  @override
  String get newPassword => 'New Password';

  @override
  String get confirmNewPassword => 'Confirm New Password';

  @override
  String get updatePassword => 'Update Password';

  @override
  String get fieldRequired => 'Field required';

  @override
  String get passwordsDoNotMatch => 'Passwords do not match';

  @override
  String get passwordTooShort => 'Must be at least 6 characters';

  @override
  String get passwordUpdatedSuccess => 'Password updated successfully!';

  @override
  String get spendingInsights => 'Spending Insights';

  @override
  String daysLeft(int days) {
    return '$days days left this month';
  }

  @override
  String onTrack(int count) {
    return '$count on track';
  }

  @override
  String overBudget(int count) {
    return '$count over budget';
  }

  @override
  String get addBudgetCategoriesInsights =>
      'Add budget categories to see insights.';

  @override
  String overBudgetInsight(Object amount) {
    return 'Over budget by $amount. Consider cutting back.';
  }

  @override
  String nearlyAtLimitInsight(Object amount) {
    return 'Only $amount left — nearly at your limit!';
  }

  @override
  String usedPercentInsight(Object percent, Object days) {
    return 'You\'ve used $percent% with $days days to go.';
  }

  @override
  String halfwayBudgetInsight(Object amount) {
    return 'Halfway through budget. $amount remaining — stay consistent.';
  }

  @override
  String savedThisMonthInsight(Object amount) {
    return 'Great discipline! You saved $amount this month.';
  }

  @override
  String noSpendingInsight(Object amount) {
    return 'No spending yet. $amount is ready to use.';
  }

  @override
  String onTrackInsight(Object amount) {
    return 'On track — $amount left for the rest of the month.';
  }

  @override
  String budgetFullyUsedInsight(Object days) {
    return 'You\'ve used the entire budget with $days days remaining.';
  }

  @override
  String get spendingReport => 'Spending Report';

  @override
  String get breakdown => 'Breakdown';

  @override
  String get byCategory => 'By Category';

  @override
  String get allocated => 'Allocated';

  @override
  String get spendingReportSpent => 'Spent';

  @override
  String get spendingReportRemaining => 'Remaining';

  @override
  String get used => 'Used';

  @override
  String get noBudgetData => 'No budget data to display.';

  @override
  String get aiInsightLabel => 'AI Financial Insight';

  @override
  String get aiInsightRefreshTooltip => 'Refresh';

  @override
  String get aiInsightJustNow => 'Just now';

  @override
  String aiInsightMinutesAgo(int n) {
    return '$n min ago';
  }

  @override
  String aiInsightHoursAgo(int n) {
    return '${n}h ago';
  }

  @override
  String get aiInsightErrorMsg => 'Could not load AI insight.';

  @override
  String get aiInsightRetryBtn => 'Retry';

  @override
  String get budgetsScreenTitle => 'Budgets';

  @override
  String get reportsTitle => 'Reports';

  @override
  String get localInsightsSectionTitle => 'Quick Insights';

  @override
  String insightHighestSpending(String category, String percent) {
    return '$category is your biggest expense at $percent of its budget.';
  }

  @override
  String insightOverBudget(String categories) {
    return 'You\'ve exceeded your budget in: $categories.';
  }

  @override
  String insightWarningTotal(String percent) {
    return 'You\'ve used $percent of your total monthly budget — slow down!';
  }

  @override
  String insightGreatProgress(String percent) {
    return 'Great discipline! Only $percent of your budget spent so far.';
  }

  @override
  String insightUnderUtilized(String categories) {
    return 'Low spend in $categories — consider reallocating the surplus.';
  }

  @override
  String insightNearLimit(String category, String percent) {
    return '$category is almost at its limit ($percent).';
  }

  @override
  String get cloudinaryUploadFailed => 'Cloudinary upload failed';

  @override
  String get failedToUpload => 'Failed to upload';

  @override
  String get category_groceries => 'Groceries';

  @override
  String get category_travel => 'Travel';

  @override
  String get category_entertainment => 'Entertainment';

  @override
  String get category_food => 'Food & Dining';

  @override
  String get category_shopping => 'Shopping';

  @override
  String get category_custom => 'Custom';

  @override
  String get deposit => 'Deposit';

  @override
  String get withdraw => 'Withdraw';

  @override
  String failedToSave(Object error) {
    return 'Failed to save: $error';
  }

  @override
  String get replaceCurrentCategories => 'Replace Current Categories?';

  @override
  String get replaceCategoriesWarning =>
      'Applying this template will remove your current category budgets and replace them with the template categories.';

  @override
  String get replace => 'Replace';

  @override
  String overBy(Object amount) {
    return '⚠️ Over by $amount';
  }

  @override
  String get offlineBanner =>
      'You\'re offline — changes will sync when reconnected';

  @override
  String get backendErrorTitle => 'Server Connection Error';

  @override
  String get backendErrorSubtitle =>
      'We couldn\'t retrieve your transaction history. Please check your internet connection or try again later.';

  @override
  String get photoUploadFailed => 'Failed to upload photo';

  @override
  String get error => 'Error';

  @override
  String buyActionAmount(Object amount, Object assetName) {
    return '🛒 Buy $amount of $assetName';
  }

  @override
  String sellActionPercent(Object percent, Object assetName) {
    return '💰 Sell $percent% of $assetName';
  }

  @override
  String currentPriceLabel(Object price) {
    return '$price current price';
  }

  @override
  String alpacaSymbolLabel(Object symbol) {
    return 'Alpaca symbol: $symbol';
  }

  @override
  String dashboardBuySuccess(Object amount, Object assetName) {
    return '✅ Bought $amount of $assetName';
  }

  @override
  String orderSubmittedSuccess(Object actionType) {
    return '✅ $actionType — order submitted to Alpaca';
  }

  @override
  String get boughtLabel => 'Bought';

  @override
  String get soldLabel => 'Sold';

  @override
  String suggestedLabel(Object amount, Object horizon) {
    return '$amount suggested • $horizon';
  }

  @override
  String tradeBuyLabel(Object amount, Object assetName) {
    return 'Trade: BUY $amount of $assetName';
  }

  @override
  String tradeSellLabel(Object percent, Object assetName) {
    return 'Trade: SELL $percent% of $assetName';
  }

  @override
  String unrealizedPnlLabel(Object amount) {
    return '$amount unrealized P&L';
  }

  @override
  String cashLabel(Object amount) {
    return 'Cash: $amount';
  }

  @override
  String buyingPowerLabel(Object amount) {
    return 'Buying power: $amount';
  }

  @override
  String unitsLabel(Object count) {
    return '$count units';
  }

  @override
  String valueLabel(Object amount) {
    return 'Value: $amount';
  }

  @override
  String pnlLabel(Object amount) {
    return 'P&L: $amount';
  }

  @override
  String get closePositionBtn => 'Close Position';

  @override
  String closedSuccess(Object assetName) {
    return '✅ Closed $assetName — order submitted';
  }

  @override
  String get passwordUpdatedSuccessfully => 'Password updated successfully!';

  @override
  String get emailAlreadyInUse => 'This email is already in use.';

  @override
  String get weakPassword => 'Password must be at least 6 characters.';

  @override
  String get invalidEmail => 'Please enter a valid email.';

  @override
  String get registrationFailed => 'Registration failed';

  @override
  String get unexpectedError =>
      'An unexpected error occurred. Please try again.';

  @override
  String get userNotFound => 'No account found with this email.';

  @override
  String get wrongPassword => 'Incorrect password.';

  @override
  String get loginFailed => 'Login failed';

  @override
  String get googleSignInCancelled => 'Google sign in was cancelled.';

  @override
  String get googleSignInFailed => 'Google sign in failed. Please try again.';

  @override
  String get passwordResetFailed => 'Failed to send password reset email';

  @override
  String get changePasswordUserNotFound => 'User not found.';

  @override
  String get changePasswordWrongPassword =>
      'The old password you entered is incorrect.';

  @override
  String get errorNoMarketData => '⚠️ No market data — skipping cycle.';

  @override
  String get errorAnalysisFailed => '❌ Analysis failed — API error.';

  @override
  String errorParsePositions(Object error) {
    return '⚠️ Could not parse position decisions: $error';
  }

  @override
  String errorParseBuyOpps(Object error) {
    return '⚠️ Could not parse buy opportunities: $error';
  }

  @override
  String errorCycle(Object error) {
    return '❌ Cycle error: $error';
  }

  @override
  String get alpaca_not_configured_settings =>
      'Alpaca API not configured. Add your API keys in Settings.';

  @override
  String get alpaca_not_configured => 'Alpaca not configured.';

  @override
  String get order_failed => 'Order failed.';

  @override
  String close_failed(String error) {
    return 'Close failed ($error).';
  }

  @override
  String sell_failed(String error) {
    return 'Sell failed ($error).';
  }

  @override
  String alpaca_api_error(String message) {
    return 'Alpaca error: $message';
  }

  @override
  String alpaca_exception(String exception) {
    return 'An unexpected error occurred: $exception';
  }

  @override
  String registration_failed(String message) {
    return 'Registration failed: $message';
  }

  @override
  String login_failed(String message) {
    return 'Login failed: $message';
  }

  @override
  String password_reset_failed(String message) {
    return 'Password reset failed: $message';
  }

  @override
  String auth_generic_message(String message) {
    return 'Authentication error: $message';
  }

  @override
  String auto_trade_enabled(String interval) {
    return '🤖 Auto-trade enabled. Cycle every $interval.';
  }

  @override
  String get auto_trade_disabled => '⏸ Auto-trade disabled.';

  @override
  String get cycle_started_gathering =>
      '📡 Cycle started — gathering live market data...';

  @override
  String get no_market_data => '⚠️ No market data — skipping cycle.';

  @override
  String data_ready(Object assets, Object news, Object positions, Object cash) {
    return '✅ Data ready: $assets assets, $news headlines, $positions open positions, \$$cash cash';
  }

  @override
  String get step_analyzing_sentiment =>
      '🔍 Step 1/3 — Analyzing market sentiment & news...';

  @override
  String get analysis_failed => '❌ Analysis failed — API error.';

  @override
  String sentiment_preview(Object preview) {
    return '📊 Sentiment: $preview...';
  }

  @override
  String get step_evaluating_positions =>
      '⚖️ Step 2/3 — Evaluating each open position...';

  @override
  String position_hold(Object name, Object reason) {
    return '✅ HOLD $name: $reason';
  }

  @override
  String position_action(Object action, Object name, Object reason) {
    return '⚡ $action $name: $reason';
  }

  @override
  String position_closed(Object name) {
    return '✅ $name closed at market price';
  }

  @override
  String parse_positions_error(Object error) {
    return '⚠️ Could not parse position decisions: $error';
  }

  @override
  String get no_open_positions => '📂 No open positions to evaluate.';

  @override
  String get step_scanning_buy_opps =>
      '🔎 Step 3/3 — Scanning for new buy opportunities...';

  @override
  String parse_buy_opps_error(Object error) {
    return '⚠️ Could not parse buy opportunities: $error';
  }

  @override
  String buy_opportunities_found(Object count) {
    return '💡 Found $count buy opportunities — awaiting your approval.';
  }

  @override
  String get no_buy_opportunities =>
      '📉 No strong buy opportunities found. Cash held for next cycle.';

  @override
  String cycle_complete_with_sells(Object count, Object nextRun) {
    return '✅ Cycle complete. $count sell(s) executed. Next run: $nextRun';
  }

  @override
  String cycle_complete_no_sells(Object nextRun) {
    return '✅ Cycle complete. Next run: $nextRun';
  }

  @override
  String cycle_error(Object error) {
    return '❌ Cycle error: $error';
  }

  @override
  String get budget_warning_title => 'Budget Warning';

  @override
  String budget_warning_body(Object category, Object percentUsed) {
    return 'You have used $percentUsed% of your $category budget.';
  }

  @override
  String get category_transport => 'Transportation';

  @override
  String get category_bills => 'Bills & Utilities';

  @override
  String recurring_fallback(String title) {
    return '$title (recurring)';
  }

  @override
  String auto_prefix(String note) {
    return '[Auto] $note';
  }

  @override
  String get cloudinary_upload_failed =>
      'Cloudinary upload failed. Please try again.';

  @override
  String get failed_to_upload =>
      'Failed to upload image due to a network or system error.';

  @override
  String notifBudgetExceededTitle(Object title) {
    return '🚨 Budget Exceeded: $title';
  }

  @override
  String notifBudgetExceededBody(Object title) {
    return 'You have gone over your $title budget!';
  }

  @override
  String notifBudgetWarningTitle(Object title) {
    return '⚠️ Budget Alert: $title';
  }

  @override
  String notifBudgetWarningBody(Object days, Object percent, Object title) {
    return 'You\'ve used $percent% of your $title budget with $days days left.';
  }

  @override
  String get notifSavingsTitle => '🎉 Savings Goal Progress';

  @override
  String notifSavingsBody(Object percent) {
    return 'You\'re $percent% of the way to your monthly savings goal!';
  }

  @override
  String get notifWeeklyTitle => 'Your Weekly Spending Recap 📊';

  @override
  String notifWeeklyBody(Object category, Object percent) {
    return 'You used $percent% of your budget. Most spent: $category.';
  }

  @override
  String get removePhoto => 'Remove Photo';

  @override
  String get removePhotoConfirm =>
      'Are you sure you want to remove your profile picture?';

  @override
  String get remove => 'Remove';

  @override
  String get removingPhoto => 'Removing photo...';

  @override
  String get photoRemoved => 'Profile picture removed';

  @override
  String get photoRemoveFailed => 'Failed to remove photo';
}
