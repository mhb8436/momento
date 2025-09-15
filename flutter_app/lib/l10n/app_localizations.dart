import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_ko.dart';

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

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
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
    Locale('en'),
    Locale('es'),
    Locale('ja'),
    Locale('ko')
  ];

  /// The title of the application
  ///
  /// In en, this message translates to:
  /// **'MOMENTO'**
  String get appTitle;

  /// App subtitle for onboarding
  ///
  /// In en, this message translates to:
  /// **'Capture Mom\'s Recipes with Voice & AI'**
  String get appSubtitle;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @signup.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signup;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// No description provided for @loginButton.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get loginButton;

  /// No description provided for @signupButton.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get signupButton;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get alreadyHaveAccount;

  /// No description provided for @dontHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get dontHaveAccount;

  /// No description provided for @enterEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email address'**
  String get enterEmail;

  /// No description provided for @enterPassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter your password'**
  String get enterPassword;

  /// No description provided for @invalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email address'**
  String get invalidEmail;

  /// No description provided for @passwordTooShort.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get passwordTooShort;

  /// No description provided for @passwordsNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsNotMatch;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @recipes.
  ///
  /// In en, this message translates to:
  /// **'Recipes'**
  String get recipes;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @createRecipe.
  ///
  /// In en, this message translates to:
  /// **'Create Recipe'**
  String get createRecipe;

  /// No description provided for @recordVoice.
  ///
  /// In en, this message translates to:
  /// **'Record with Voice'**
  String get recordVoice;

  /// No description provided for @recordVoiceSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Tell us about your cooking process\nand AI will organize it into a structured recipe'**
  String get recordVoiceSubtitle;

  /// No description provided for @scanImage.
  ///
  /// In en, this message translates to:
  /// **'Scan Image'**
  String get scanImage;

  /// No description provided for @scanImageSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Extract text\nfrom photo'**
  String get scanImageSubtitle;

  /// No description provided for @textInput.
  ///
  /// In en, this message translates to:
  /// **'Text Input'**
  String get textInput;

  /// No description provided for @textInputSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter notes/messages\ndirectly'**
  String get textInputSubtitle;

  /// No description provided for @urlInput.
  ///
  /// In en, this message translates to:
  /// **'URL Input'**
  String get urlInput;

  /// No description provided for @urlInputSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Extract from YouTube\n/blog links'**
  String get urlInputSubtitle;

  /// No description provided for @startRecording.
  ///
  /// In en, this message translates to:
  /// **'Start Recording'**
  String get startRecording;

  /// No description provided for @stopRecording.
  ///
  /// In en, this message translates to:
  /// **'Stop Recording'**
  String get stopRecording;

  /// No description provided for @processing.
  ///
  /// In en, this message translates to:
  /// **'Processing...'**
  String get processing;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @voiceRecognition.
  ///
  /// In en, this message translates to:
  /// **'Voice Recognition'**
  String get voiceRecognition;

  /// No description provided for @listening.
  ///
  /// In en, this message translates to:
  /// **'Listening to voice...'**
  String get listening;

  /// No description provided for @waitingForVoice.
  ///
  /// In en, this message translates to:
  /// **'Waiting for voice input'**
  String get waitingForVoice;

  /// No description provided for @tapToStartRecording.
  ///
  /// In en, this message translates to:
  /// **'Tap the microphone button to start'**
  String get tapToStartRecording;

  /// No description provided for @speakCookingInstructions.
  ///
  /// In en, this message translates to:
  /// **'Please speak your cooking instructions clearly'**
  String get speakCookingInstructions;

  /// No description provided for @includeIngredientsAndSteps.
  ///
  /// In en, this message translates to:
  /// **'Include ingredients, cooking steps, and tips'**
  String get includeIngredientsAndSteps;

  /// No description provided for @credits.
  ///
  /// In en, this message translates to:
  /// **'Credits'**
  String get credits;

  /// No description provided for @creditsRequired.
  ///
  /// In en, this message translates to:
  /// **'Credits Required'**
  String get creditsRequired;

  /// No description provided for @creditsRequiredMessage.
  ///
  /// In en, this message translates to:
  /// **'{action} requires 1 credit.'**
  String creditsRequiredMessage(String action);

  /// No description provided for @currentCredits.
  ///
  /// In en, this message translates to:
  /// **'Current Credits'**
  String get currentCredits;

  /// No description provided for @insufficientCredits.
  ///
  /// In en, this message translates to:
  /// **'Insufficient Credits'**
  String get insufficientCredits;

  /// No description provided for @creditShortage.
  ///
  /// In en, this message translates to:
  /// **'Not enough credits. Please purchase credits or wait for daily free credits.'**
  String get creditShortage;

  /// No description provided for @freeCreditsRemaining.
  ///
  /// In en, this message translates to:
  /// **'{count} free credits remaining (today)'**
  String freeCreditsRemaining(int count);

  /// No description provided for @creditStore.
  ///
  /// In en, this message translates to:
  /// **'Credit Store'**
  String get creditStore;

  /// No description provided for @purchaseCredits.
  ///
  /// In en, this message translates to:
  /// **'Purchase Credits'**
  String get purchaseCredits;

  /// No description provided for @creditPackages.
  ///
  /// In en, this message translates to:
  /// **'Credit Packages'**
  String get creditPackages;

  /// No description provided for @autoRechargeSubscriptions.
  ///
  /// In en, this message translates to:
  /// **'Auto-recharge Subscriptions'**
  String get autoRechargeSubscriptions;

  /// No description provided for @starterPackage.
  ///
  /// In en, this message translates to:
  /// **'Starter Package'**
  String get starterPackage;

  /// No description provided for @familyPackage.
  ///
  /// In en, this message translates to:
  /// **'Family Package'**
  String get familyPackage;

  /// No description provided for @premiumPackage.
  ///
  /// In en, this message translates to:
  /// **'Premium Package'**
  String get premiumPackage;

  /// No description provided for @monthlyAutoRecharge.
  ///
  /// In en, this message translates to:
  /// **'Monthly Auto-recharge'**
  String get monthlyAutoRecharge;

  /// No description provided for @yearlyAutoRecharge.
  ///
  /// In en, this message translates to:
  /// **'Yearly Auto-recharge'**
  String get yearlyAutoRecharge;

  /// No description provided for @creditsAmount.
  ///
  /// In en, this message translates to:
  /// **'{count} credits'**
  String creditsAmount(int count);

  /// No description provided for @price.
  ///
  /// In en, this message translates to:
  /// **'{amount}'**
  String price(String amount);

  /// No description provided for @creditStoreInfo.
  ///
  /// In en, this message translates to:
  /// **'Credit Store Guide'**
  String get creditStoreInfo;

  /// No description provided for @creditStoreDescription.
  ///
  /// In en, this message translates to:
  /// **'Use credits to access AI recipe generation service.\n\n📝 Usage Fees:\n• Recipe generation: {recipeGenCost} credit\n• Recipe improvement: {recipeImproveCost} credit\n\n🎁 Free Benefits:\n• New signup: {initialCredits} credits\n• Daily {dailyCredits} free credits\n\n⭐ Auto-recharge Service:\n• Monthly 50 credits auto-recharge: ₩9,900 (month)\n• Yearly 100 credits auto-recharge: ₩99,900 (year)\n• Convenient auto-recharge usage'**
  String creditStoreDescription(int recipeGenCost, int recipeImproveCost,
      int initialCredits, int dailyCredits);

  /// No description provided for @autoRechargeEnabled.
  ///
  /// In en, this message translates to:
  /// **'Auto-recharge enabled'**
  String get autoRechargeEnabled;

  /// No description provided for @useCredit.
  ///
  /// In en, this message translates to:
  /// **'Use Credit'**
  String get useCredit;

  /// No description provided for @useFreeCredit.
  ///
  /// In en, this message translates to:
  /// **'Use free credit ({count} remaining today)'**
  String useFreeCredit(int count);

  /// No description provided for @usePaidCredit.
  ///
  /// In en, this message translates to:
  /// **'Use paid credit'**
  String get usePaidCredit;

  /// No description provided for @balanceAfterUse.
  ///
  /// In en, this message translates to:
  /// **'Balance after use: {balance} credits'**
  String balanceAfterUse(int balance);

  /// No description provided for @recipeCreated.
  ///
  /// In en, this message translates to:
  /// **'🎉 Recipe created successfully!'**
  String get recipeCreated;

  /// No description provided for @processingTranscript.
  ///
  /// In en, this message translates to:
  /// **'Analyzing voice and generating recipe...'**
  String get processingTranscript;

  /// No description provided for @processingCharacters.
  ///
  /// In en, this message translates to:
  /// **'Processing {count} characters of content.'**
  String processingCharacters(int count);

  /// No description provided for @offlineMode.
  ///
  /// In en, this message translates to:
  /// **'Offline mode'**
  String get offlineMode;

  /// No description provided for @offlineRecipeCreation.
  ///
  /// In en, this message translates to:
  /// **'Cannot create new recipes while offline.'**
  String get offlineRecipeCreation;

  /// No description provided for @offlineVoiceRecognition.
  ///
  /// In en, this message translates to:
  /// **'Voice recognition is only available online.'**
  String get offlineVoiceRecognition;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @success.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get success;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @recipeTitle.
  ///
  /// In en, this message translates to:
  /// **'Recipe Title'**
  String get recipeTitle;

  /// No description provided for @ingredients.
  ///
  /// In en, this message translates to:
  /// **'Ingredients'**
  String get ingredients;

  /// No description provided for @instructions.
  ///
  /// In en, this message translates to:
  /// **'Instructions'**
  String get instructions;

  /// No description provided for @cookingTime.
  ///
  /// In en, this message translates to:
  /// **'Cooking Time'**
  String get cookingTime;

  /// No description provided for @servings.
  ///
  /// In en, this message translates to:
  /// **'Servings'**
  String get servings;

  /// No description provided for @difficulty.
  ///
  /// In en, this message translates to:
  /// **'Difficulty'**
  String get difficulty;

  /// No description provided for @tags.
  ///
  /// In en, this message translates to:
  /// **'Tags'**
  String get tags;

  /// No description provided for @tips.
  ///
  /// In en, this message translates to:
  /// **'Tips'**
  String get tips;

  /// No description provided for @easy.
  ///
  /// In en, this message translates to:
  /// **'Easy'**
  String get easy;

  /// No description provided for @medium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get medium;

  /// No description provided for @hard.
  ///
  /// In en, this message translates to:
  /// **'Hard'**
  String get hard;

  /// No description provided for @minutes.
  ///
  /// In en, this message translates to:
  /// **'minutes'**
  String get minutes;

  /// No description provided for @hours.
  ///
  /// In en, this message translates to:
  /// **'hours'**
  String get hours;

  /// No description provided for @servingsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} servings'**
  String servingsCount(int count);

  /// No description provided for @greetingWithName.
  ///
  /// In en, this message translates to:
  /// **'Hello, {name}!'**
  String greetingWithName(String name);

  /// No description provided for @greetingDefault.
  ///
  /// In en, this message translates to:
  /// **'Hello!'**
  String get greetingDefault;

  /// No description provided for @todayQuestion.
  ///
  /// In en, this message translates to:
  /// **'What dish would you like to record today?'**
  String get todayQuestion;

  /// No description provided for @offline.
  ///
  /// In en, this message translates to:
  /// **'Offline'**
  String get offline;

  /// No description provided for @quickStart.
  ///
  /// In en, this message translates to:
  /// **'Quick Start'**
  String get quickStart;

  /// No description provided for @voiceRecording.
  ///
  /// In en, this message translates to:
  /// **'Voice Recording'**
  String get voiceRecording;

  /// No description provided for @newRecipeVoice.
  ///
  /// In en, this message translates to:
  /// **'Record a new recipe with voice'**
  String get newRecipeVoice;

  /// No description provided for @ocrScan.
  ///
  /// In en, this message translates to:
  /// **'OCR Scan'**
  String get ocrScan;

  /// No description provided for @extractFromImage.
  ///
  /// In en, this message translates to:
  /// **'Extract recipe from image'**
  String get extractFromImage;

  /// No description provided for @myRecipes.
  ///
  /// In en, this message translates to:
  /// **'My Recipes'**
  String get myRecipes;

  /// No description provided for @viewSavedRecipes.
  ///
  /// In en, this message translates to:
  /// **'View saved recipes'**
  String get viewSavedRecipes;

  /// No description provided for @recentRecipes.
  ///
  /// In en, this message translates to:
  /// **'Recent Recipes'**
  String get recentRecipes;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get viewAll;

  /// No description provided for @noRecipesYet.
  ///
  /// In en, this message translates to:
  /// **'No recipes yet'**
  String get noRecipesYet;

  /// No description provided for @recordFirstRecipe.
  ///
  /// In en, this message translates to:
  /// **'Record your first cooking recipe!'**
  String get recordFirstRecipe;

  /// No description provided for @myCookingRecord.
  ///
  /// In en, this message translates to:
  /// **'My Cooking Record'**
  String get myCookingRecord;

  /// No description provided for @totalRecipes.
  ///
  /// In en, this message translates to:
  /// **'Total Recipes'**
  String get totalRecipes;

  /// No description provided for @recordingFiles.
  ///
  /// In en, this message translates to:
  /// **'Recording Files'**
  String get recordingFiles;

  /// No description provided for @favorites.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get favorites;

  /// No description provided for @community.
  ///
  /// In en, this message translates to:
  /// **'Community'**
  String get community;

  /// No description provided for @help.
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get help;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @logoutConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to logout?'**
  String get logoutConfirm;

  /// No description provided for @logoutDialog.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logoutDialog;

  /// No description provided for @offlineRecognition.
  ///
  /// In en, this message translates to:
  /// **'You are offline. Voice recognition is only available online.'**
  String get offlineRecognition;

  /// No description provided for @recognizing.
  ///
  /// In en, this message translates to:
  /// **'Recognizing'**
  String get recognizing;

  /// No description provided for @waiting.
  ///
  /// In en, this message translates to:
  /// **'Waiting'**
  String get waiting;

  /// No description provided for @accumulatedContent.
  ///
  /// In en, this message translates to:
  /// **'Accumulated content ({count} characters)'**
  String accumulatedContent(int count);

  /// No description provided for @initialize.
  ///
  /// In en, this message translates to:
  /// **'Initialize'**
  String get initialize;

  /// No description provided for @currentlyRecognizing.
  ///
  /// In en, this message translates to:
  /// **'Currently recognizing'**
  String get currentlyRecognizing;

  /// No description provided for @listeningToVoice.
  ///
  /// In en, this message translates to:
  /// **'Listening to voice...'**
  String get listeningToVoice;

  /// No description provided for @startVoiceRecognition.
  ///
  /// In en, this message translates to:
  /// **'Press the voice recognition button to start'**
  String get startVoiceRecognition;

  /// No description provided for @speakRecipeDetails.
  ///
  /// In en, this message translates to:
  /// **'Please speak your recipe details'**
  String get speakRecipeDetails;

  /// No description provided for @startVoiceRecognitionPrompt.
  ///
  /// In en, this message translates to:
  /// **'Start voice recognition'**
  String get startVoiceRecognitionPrompt;

  /// No description provided for @includeIngredientsAndStepsLong.
  ///
  /// In en, this message translates to:
  /// **'Please include ingredients, cooking steps, tips, etc.'**
  String get includeIngredientsAndStepsLong;

  /// No description provided for @allowMicrophonePermission.
  ///
  /// In en, this message translates to:
  /// **'Please allow microphone permission and press the recognition button'**
  String get allowMicrophonePermission;

  /// No description provided for @createRecipeButton.
  ///
  /// In en, this message translates to:
  /// **'Create\nRecipe'**
  String get createRecipeButton;

  /// No description provided for @moreInstructionsVoice.
  ///
  /// In en, this message translates to:
  /// **'Press voice recognition button to add more, or create recipe button to finish'**
  String get moreInstructionsVoice;

  /// No description provided for @moreInstructionsVoiceAgain.
  ///
  /// In en, this message translates to:
  /// **'Press voice recognition button again to add more'**
  String get moreInstructionsVoiceAgain;

  /// No description provided for @processingAndGenerating.
  ///
  /// In en, this message translates to:
  /// **'Analyzing voice and generating recipe...'**
  String get processingAndGenerating;

  /// No description provided for @processingCharactersCount.
  ///
  /// In en, this message translates to:
  /// **'Processing {count} characters of content.'**
  String processingCharactersCount(int count);

  /// No description provided for @creatingAccount.
  ///
  /// In en, this message translates to:
  /// **'Creating account...'**
  String get creatingAccount;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// No description provided for @signupSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Record and share precious recipes with MOMENTO'**
  String get signupSubtitle;

  /// No description provided for @nameOptional.
  ///
  /// In en, this message translates to:
  /// **'Name (Optional)'**
  String get nameOptional;

  /// No description provided for @enterName.
  ///
  /// In en, this message translates to:
  /// **'Please enter your name'**
  String get enterName;

  /// No description provided for @nameTooShort.
  ///
  /// In en, this message translates to:
  /// **'Name must be at least 2 characters'**
  String get nameTooShort;

  /// No description provided for @signupSuccess.
  ///
  /// In en, this message translates to:
  /// **'Account created successfully!'**
  String get signupSuccess;

  /// No description provided for @signupFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to create account.'**
  String get signupFailed;

  /// No description provided for @termsAndPrivacy.
  ///
  /// In en, this message translates to:
  /// **'By signing up, you agree to our Terms of Service and\nPrivacy Policy.'**
  String get termsAndPrivacy;
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
      <String>['en', 'es', 'ja', 'ko'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'ja':
      return AppLocalizationsJa();
    case 'ko':
      return AppLocalizationsKo();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
