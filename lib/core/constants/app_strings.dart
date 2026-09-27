/// Application string constants
class AppStrings {
  AppStrings._();

  // App
  static const String appName = 'Expense Tracker';
  static const String appTagline = 'Smart spending, smarter saving';

  // Auth
  static const String signIn = 'Sign In';
  static const String signUp = 'Sign Up';
  static const String signOut = 'Sign Out';
  static const String email = 'Email Address';
  static const String password = 'Password';
  static const String confirmPassword = 'Confirm Password';
  static const String fullName = 'Full Name';
  static const String forgotPassword = 'Forgot Password?';
  static const String dontHaveAccount = "Don't have an account?";
  static const String alreadyHaveAccount = 'Already have an account?';
  static const String welcomeBack = 'Welcome back';
  static const String createAccount = 'Create Account';
  static const String secureCloudLedger = 'Secure Cloud Ledger';
  static const String securedByFirebase =
      'Secured by Firebase Authentication & 256-bit encryption';

  // Home
  static const String dashboard = 'Dashboard';
  static const String hello = 'Hello';
  static const String monthlyOverview = "Here is your monthly financial overview";
  static const String thisMonthTotal = 'This Month Total Expenses';
  static const String categoriesBreakdown = 'Categories Breakdown';
  static const String recentExpenses = 'Recent Expenses';
  static const String viewAll = 'View All';
  static const String thisMonth = 'This Month';
  static const String lastMonth = 'Last Month';
  static const String customRange = 'Custom Range';
  static const String budgetUsed = 'used';
  static const String remaining = 'remaining';
  static const String daysLeft = 'days left';

  // Expenses
  static const String expenses = 'Expenses';
  static const String addExpense = 'Add Expense';
  static const String editExpense = 'Edit Expense';
  static const String deleteExpense = 'Delete Expense';
  static const String expenseTitle = 'Title';
  static const String expenseAmount = 'Amount';
  static const String expenseCategory = 'Category';
  static const String expenseDate = 'Date';
  static const String expenseNote = 'Note (Optional)';
  static const String saveExpense = 'Save Expense';
  static const String updateExpense = 'Update Expense';
  static const String deleteConfirm = 'Are you sure you want to delete this expense?';
  static const String cancel = 'Cancel';
  static const String delete = 'Delete';

  // History
  static const String history = 'Expense History';
  static const String search = 'Search expenses...';
  static const String filterBy = 'Filter';
  static const String allCategories = 'All Categories';
  static const String allDates = 'All Dates';
  static const String noExpenses = 'No expenses yet';
  static const String noExpensesSubtitle = 'Add your first expense by tapping the + button';
  static const String noResults = 'No results found';
  static const String noResultsSubtitle = 'Try adjusting your search or filters';

  // Categories
  static const String categories = 'Categories';
  static const String categoryAnalytics = 'Category Analytics';
  static const String categoryFood = 'Food & Dining';
  static const String categoryTransport = 'Transport';
  static const String categoryShopping = 'Shopping';
  static const String categoryBills = 'Bills & Utilities';
  static const String categoryEntertainment = 'Entertainment';
  static const String categoryHealth = 'Health & Wellness';
  static const String categoryEducation = 'Education';
  static const String categoryOther = 'Other';

  // Settings
  static const String settings = 'Settings & Profile';
  static const String darkMode = 'Dark Mode';
  static const String notifications = 'Notifications';
  static const String currency = 'Currency';
  static const String language = 'Language';
  static const String profile = 'Profile';
  static const String account = 'Account';
  static const String preferences = 'Preferences';
  static const String about = 'About';
  static const String version = 'Version';
  static const String privacyPolicy = 'Privacy Policy';
  static const String termsOfService = 'Terms of Service';

  // States
  static const String loading = 'Loading...';
  static const String error = 'Something went wrong';
  static const String retry = 'Retry';
  static const String networkError = 'Network error. Check your connection.';

  // Validation
  static const String fieldRequired = 'This field is required';
  static const String invalidEmail = 'Please enter a valid email address';
  static const String passwordTooShort = 'Password must be at least 6 characters';
  static const String passwordsDoNotMatch = 'Passwords do not match';
  static const String invalidAmount = 'Please enter a valid amount';
  static const String amountMustBePositive = 'Amount must be greater than 0';
}
