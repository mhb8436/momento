// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'MOMENTO';

  @override
  String get appSubtitle => 'Capture Mom\'s Recipes with Voice & AI';

  @override
  String get login => 'Login';

  @override
  String get signup => 'Sign Up';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get confirmPassword => 'Confirm Password';

  @override
  String get forgotPassword => 'Forgot Password?';

  @override
  String get loginButton => 'Sign In';

  @override
  String get signupButton => 'Create Account';

  @override
  String get alreadyHaveAccount => 'Already have an account?';

  @override
  String get dontHaveAccount => 'Don\'t have an account?';

  @override
  String get enterEmail => 'Please enter your email address';

  @override
  String get enterPassword => 'Please enter your password';

  @override
  String get invalidEmail => 'Please enter a valid email address';

  @override
  String get passwordTooShort => 'Password must be at least 6 characters';

  @override
  String get passwordsNotMatch => 'Passwords do not match';

  @override
  String get home => 'Home';

  @override
  String get recipes => 'Recipes';

  @override
  String get profile => 'Profile';

  @override
  String get settings => 'Settings';

  @override
  String get createRecipe => 'Create Recipe';

  @override
  String get recordVoice => 'Record with Voice';

  @override
  String get recordVoiceSubtitle =>
      'Tell us about your cooking process\nand AI will organize it into a structured recipe';

  @override
  String get scanImage => 'Scan Image';

  @override
  String get scanImageSubtitle => 'Extract text\nfrom photo';

  @override
  String get textInput => 'Text Input';

  @override
  String get textInputSubtitle => 'Enter notes/messages\ndirectly';

  @override
  String get urlInput => 'URL Input';

  @override
  String get urlInputSubtitle => 'Extract from YouTube\n/blog links';

  @override
  String get startRecording => 'Start Recording';

  @override
  String get stopRecording => 'Stop Recording';

  @override
  String get processing => 'Processing...';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get delete => 'Delete';

  @override
  String get edit => 'Edit';

  @override
  String get share => 'Share';

  @override
  String get voiceRecognition => 'Voice Recognition';

  @override
  String get listening => 'Listening to voice...';

  @override
  String get waitingForVoice => 'Waiting for voice input';

  @override
  String get tapToStartRecording => 'Tap the microphone button to start';

  @override
  String get speakCookingInstructions =>
      'Please speak your cooking instructions clearly';

  @override
  String get includeIngredientsAndSteps =>
      'Include ingredients, cooking steps, and tips';

  @override
  String get credits => 'Credits';

  @override
  String get creditsRequired => 'Credits Required';

  @override
  String creditsRequiredMessage(String action) {
    return '$action requires 1 credit.';
  }

  @override
  String get currentCredits => 'Current Credits';

  @override
  String get insufficientCredits => 'Insufficient Credits';

  @override
  String get creditShortage =>
      'Not enough credits. Please purchase credits or wait for daily free credits.';

  @override
  String freeCreditsRemaining(int count) {
    return '$count free credits remaining (today)';
  }

  @override
  String get creditStore => 'Credit Store';

  @override
  String get purchaseCredits => 'Purchase Credits';

  @override
  String get creditPackages => 'Credit Packages';

  @override
  String get autoRechargeSubscriptions => 'Auto-recharge Subscriptions';

  @override
  String get starterPackage => 'Starter Package';

  @override
  String get familyPackage => 'Family Package';

  @override
  String get premiumPackage => 'Premium Package';

  @override
  String get monthlyAutoRecharge => 'Monthly Auto-recharge';

  @override
  String get yearlyAutoRecharge => 'Yearly Auto-recharge';

  @override
  String creditsAmount(int count) {
    return '$count credits';
  }

  @override
  String price(String amount) {
    return '$amount';
  }

  @override
  String get creditStoreInfo => 'Credit Store Guide';

  @override
  String creditStoreDescription(int recipeGenCost, int recipeImproveCost,
      int initialCredits, int dailyCredits) {
    return 'Use credits to access AI recipe generation service.\n\n📝 Usage Fees:\n• Recipe generation: $recipeGenCost credit\n• Recipe improvement: $recipeImproveCost credit\n\n🎁 Free Benefits:\n• New signup: $initialCredits credits\n• Daily $dailyCredits free credits\n\n⭐ Auto-recharge Service:\n• Monthly 50 credits auto-recharge: ₩9,900 (month)\n• Yearly 100 credits auto-recharge: ₩99,900 (year)\n• Convenient auto-recharge usage';
  }

  @override
  String get autoRechargeEnabled => 'Auto-recharge enabled';

  @override
  String get useCredit => 'Use Credit';

  @override
  String useFreeCredit(int count) {
    return 'Use free credit ($count remaining today)';
  }

  @override
  String get usePaidCredit => 'Use paid credit';

  @override
  String balanceAfterUse(int balance) {
    return 'Balance after use: $balance credits';
  }

  @override
  String get recipeCreated => '🎉 Recipe created successfully!';

  @override
  String get processingTranscript => 'Analyzing voice and generating recipe...';

  @override
  String processingCharacters(int count) {
    return 'Processing $count characters of content.';
  }

  @override
  String get offlineMode => 'Offline mode';

  @override
  String get offlineRecipeCreation =>
      'Cannot create new recipes while offline.';

  @override
  String get offlineVoiceRecognition =>
      'Voice recognition is only available online.';

  @override
  String get error => 'Error';

  @override
  String get success => 'Success';

  @override
  String get loading => 'Loading...';

  @override
  String get retry => 'Retry';

  @override
  String get confirm => 'Confirm';

  @override
  String get close => 'Close';

  @override
  String get recipeTitle => 'Recipe Title';

  @override
  String get ingredients => 'Ingredients';

  @override
  String get instructions => 'Instructions';

  @override
  String get cookingTime => 'Cooking Time';

  @override
  String get servings => 'Servings';

  @override
  String get difficulty => 'Difficulty';

  @override
  String get tags => 'Tags';

  @override
  String get tips => 'Tips';

  @override
  String get easy => 'Easy';

  @override
  String get medium => 'Medium';

  @override
  String get hard => 'Hard';

  @override
  String get minutes => 'minutes';

  @override
  String get hours => 'hours';

  @override
  String servingsCount(int count) {
    return '$count servings';
  }

  @override
  String greetingWithName(String name) {
    return 'Hello, $name!';
  }

  @override
  String get greetingDefault => 'Hello!';

  @override
  String get todayQuestion => 'What dish would you like to record today?';

  @override
  String get offline => 'Offline';

  @override
  String get quickStart => 'Quick Start';

  @override
  String get voiceRecording => 'Voice Recording';

  @override
  String get newRecipeVoice => 'Record a new recipe with voice';

  @override
  String get ocrScan => 'OCR Scan';

  @override
  String get extractFromImage => 'Extract recipe from image';

  @override
  String get myRecipes => 'My Recipes';

  @override
  String get viewSavedRecipes => 'View saved recipes';

  @override
  String get recentRecipes => 'Recent Recipes';

  @override
  String get viewAll => 'View All';

  @override
  String get noRecipesYet => 'No recipes yet';

  @override
  String get recordFirstRecipe => 'Record your first cooking recipe!';

  @override
  String get myCookingRecord => 'My Cooking Record';

  @override
  String get totalRecipes => 'Total Recipes';

  @override
  String get recordingFiles => 'Recording Files';

  @override
  String get favorites => 'Favorites';

  @override
  String get community => 'Community';

  @override
  String get help => 'Help';

  @override
  String get logout => 'Logout';

  @override
  String get logoutConfirm => 'Are you sure you want to logout?';

  @override
  String get logoutDialog => 'Logout';

  @override
  String get offlineRecognition =>
      'You are offline. Voice recognition is only available online.';

  @override
  String get recognizing => 'Recognizing';

  @override
  String get waiting => 'Waiting';

  @override
  String accumulatedContent(int count) {
    return 'Accumulated content ($count characters)';
  }

  @override
  String get initialize => 'Initialize';

  @override
  String get currentlyRecognizing => 'Currently recognizing';

  @override
  String get listeningToVoice => 'Listening to voice...';

  @override
  String get startVoiceRecognition =>
      'Press the voice recognition button to start';

  @override
  String get speakRecipeDetails => 'Please speak your recipe details';

  @override
  String get startVoiceRecognitionPrompt => 'Start voice recognition';

  @override
  String get includeIngredientsAndStepsLong =>
      'Please include ingredients, cooking steps, tips, etc.';

  @override
  String get allowMicrophonePermission =>
      'Please allow microphone permission and press the recognition button';

  @override
  String get createRecipeButton => 'Create\nRecipe';

  @override
  String get moreInstructionsVoice =>
      'Press voice recognition button to add more, or create recipe button to finish';

  @override
  String get moreInstructionsVoiceAgain =>
      'Press voice recognition button again to add more';

  @override
  String get processingAndGenerating =>
      'Analyzing voice and generating recipe...';

  @override
  String processingCharactersCount(int count) {
    return 'Processing $count characters of content.';
  }

  @override
  String get creatingAccount => 'Creating account...';

  @override
  String get createAccount => 'Create Account';

  @override
  String get signupSubtitle => 'Record and share precious recipes with MOMENTO';

  @override
  String get nameOptional => 'Name (Optional)';

  @override
  String get enterName => 'Please enter your name';

  @override
  String get nameTooShort => 'Name must be at least 2 characters';

  @override
  String get signupSuccess => 'Account created successfully!';

  @override
  String get signupFailed => 'Failed to create account.';

  @override
  String get termsAndPrivacy =>
      'By signing up, you agree to our Terms of Service and\nPrivacy Policy.';
}
