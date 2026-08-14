// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Smart Cart';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get save => 'Save';

  @override
  String get language => 'Language';

  @override
  String get darkTheme => 'Dark Theme';

  @override
  String get languageSystem => 'System';

  @override
  String get languageTurkish => 'Turkish';

  @override
  String get languageEnglish => 'English';

  @override
  String get cancel => 'Cancel';

  @override
  String get ok => 'OK';

  @override
  String get profileTitle => 'Profile';

  @override
  String get nameUpdated => 'Your name has been updated.';

  @override
  String get profileUpdated => 'Your profile has been updated.';

  @override
  String get sessionNotFound => 'Session not found. Please sign in again.';

  @override
  String get profileLoadFailed =>
      'Could not load your profile. Please try again.';

  @override
  String get profileSaveFailed =>
      'Could not save your profile. Please try again.';

  @override
  String get nameSaveFailed => 'Could not save your name. Please try again.';

  @override
  String get countrySaveFailed =>
      'Could not save your country. Please try again.';

  @override
  String get photoUploadFailed =>
      'Could not upload the photo. Please try again.';

  @override
  String get nameDialogTitle => 'Your name';

  @override
  String get nameDialogHint => 'Enter your name';

  @override
  String get changePhotoLabel => 'Change profile photo';

  @override
  String get addNamePrompt => 'Add your name';

  @override
  String get emailNotFound => 'Email not found';

  @override
  String customAllergenConsultPrompt(String value) {
    return '\'$value\' is a custom allergen. Would you like to consult the chatbot to make sure it\'s understood correctly?';
  }

  @override
  String get consultNotNeeded => 'No need';

  @override
  String get consultAskChatbot => 'Ask the chatbot';

  @override
  String customAllergenChatbotPrefill(String value) {
    return 'I added \'$value\' as an allergen to my profile but I\'m not entirely sure — could you help me clarify it?';
  }

  @override
  String get close => 'Close';

  @override
  String get understood => 'Got it';

  @override
  String get update => 'Update';

  @override
  String get settingsSectionAccount => 'ACCOUNT & PROFILE';

  @override
  String get settingsSectionApp => 'APP & LEGAL';

  @override
  String get settingsSectionSession => 'SESSION';

  @override
  String get activeSession => 'Active session';

  @override
  String get registeredEmail => 'Registered email';

  @override
  String get editProfileInfo => 'Edit profile information';

  @override
  String get changePassword => 'Change password';

  @override
  String get countrySelection => 'Country';

  @override
  String get notSelected => 'Not selected';

  @override
  String get countryUpdated => 'Country updated.';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get about => 'About';

  @override
  String get signOut => 'Sign out';

  @override
  String get signOutFailed => 'Could not sign out. Please try again.';

  @override
  String get deleteAccount => 'Delete account';

  @override
  String get premiumExit => 'Leave Premium';

  @override
  String get premiumGo => 'Go Premium';

  @override
  String get premiumActive => 'Active';

  @override
  String get premiumTest => 'For testing';

  @override
  String get premiumEnabled => 'Premium enabled!';

  @override
  String get premiumDisabled => 'Premium disabled.';

  @override
  String get premiumUpdateFailed => 'Could not update premium status.';

  @override
  String get aboutVersion => 'Smart Cart — Version 1.0.0';

  @override
  String get aboutBody1 =>
      'Developed as part of the ULUTEK internship project, it is a barcode-scanning, AI-powered smart product analysis assistant.';

  @override
  String get aboutBody2 =>
      'It automatically evaluates product contents against users\' allergy, diet and specific health preferences and provides personalized warnings.';

  @override
  String get privacyHeading => 'Data Privacy and Security';

  @override
  String get privacyBody1 =>
      'Smart Cart stores the diet, allergy and health data you select securely in a Supabase database, solely to provide product analysis tailored to you.';

  @override
  String get privacyBody2 =>
      'Your personal data is never shared with third parties under any circumstances. You can update your information from your profile at any time.';

  @override
  String get passwordHint =>
      'Enter your new password. It must be at least 6 characters.';

  @override
  String get newPassword => 'New password';

  @override
  String get newPasswordRepeat => 'New password (again)';

  @override
  String get passwordTooShort => 'Password must be at least 6 characters.';

  @override
  String get passwordsDoNotMatch => 'Passwords do not match.';

  @override
  String get passwordUpdated => 'Your password has been updated.';

  @override
  String passwordUpdateFailed(String error) {
    return 'Could not update password: $error';
  }

  @override
  String get deleteAccountConfirmQuestion =>
      'Are you sure you want to delete your account?';

  @override
  String get deleteAccountConfirmBody =>
      'This action cannot be undone. All your saved allergies, diet preferences and history data will be permanently deleted.';

  @override
  String get deleteAccountConfirm => 'Yes, delete my account';

  @override
  String get deleteAccountFinalTitle => 'One last time';

  @override
  String get deleteAccountFinalBody =>
      'This is the final confirmation. If you confirm, your account and all your data will be permanently deleted.';

  @override
  String get deleteAccountFinalConfirm => 'Yes, I\'m sure — Delete';

  @override
  String get accountDeleted => 'Your account has been deleted.';

  @override
  String get deleteAccountFailed => 'Could not delete the account.';

  @override
  String get statScannedProducts => 'Scanned products';

  @override
  String get statAvoidedAllergens => 'Avoided allergens';

  @override
  String get statMemberDays => 'Member days';

  @override
  String get signUp => 'Sign up';

  @override
  String get signIn => 'Sign in';

  @override
  String get authWelcome => 'Welcome to Smart Cart';

  @override
  String get authTagline => 'Your personalized shopping assistant';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get termsLink => 'Terms and Privacy Agreement';

  @override
  String get termsAcceptSuffix => ' — I have read and accept it.';

  @override
  String get termsRequiredWarning =>
      'Please accept the Terms and Privacy Agreement to continue.';

  @override
  String get emailAlreadyRegistered =>
      'This email is already registered. Please sign in.';

  @override
  String get emailConfirmationNotice =>
      'We sent a verification link to your email. You can\'t sign in until you click the link and verify your account.';

  @override
  String get toggleToSignIn => 'Already have an account? Sign in';

  @override
  String get toggleToSignUp => 'Don\'t have an account? Sign up';

  @override
  String get orSeparator => 'or';

  @override
  String get googleSignIn => 'Sign in with Google';

  @override
  String get continueAsGuest => 'Continue as guest';

  @override
  String get signUpFailed => 'Sign-up failed. Please try again.';

  @override
  String get signInFailed => 'Sign-in failed. Please try again.';

  @override
  String get guestSignInFailed => 'Guest sign-in failed. Please try again.';

  @override
  String get googleSignInFailed => 'Google sign-in failed. Please try again.';

  @override
  String get termsIntro =>
      'Please read the following terms of use and privacy principles carefully before using the Smart Cart app.';

  @override
  String get termsSection1Title => '1. Parties and Purpose';

  @override
  String get termsSection1Body =>
      'This agreement is made between the Smart Cart app (the \"App\") and the person using the App (the \"User\"). The App\'s purpose is to let users scan product barcodes, view product contents and receive AI-assisted guidance based on their personal allergy/diet preferences.';

  @override
  String get termsSection2Title =>
      '2. Scope of Service and Disclaimer (Important Notice)';

  @override
  String get termsSection2Body =>
      'The content analyses, allergen warnings and product assessments provided by the App are for information and guidance only. The data in the App is compiled from official packaging information and open-source databases. The App in no way constitutes medical advice, diagnosis or treatment. Final responsibility for the User\'s health, diet preferences and product consumption rests entirely with the User.';

  @override
  String get termsSection3Title => '3. Personal Data and KVKK Notice';

  @override
  String get termsSection3Body =>
      'Smart Cart stores the allergy, diet and health data the user specifies, along with their email address, in secure databases in order to provide the service. Your personal data is protected in line with the principles of Turkish Data Protection Law No. 6698 (KVKK) and is not shared commercially with third-party institutions or organizations.';

  @override
  String get termsSection4Title => '4. User Obligations';

  @override
  String get termsSection4Body =>
      'The User agrees to provide accurate and up-to-date information when registering and to protect account security and password confidentiality. Any detected unauthorized account use must be reported to the app administrators immediately.';

  @override
  String get termsSection5Title =>
      '5. Termination and Changes to the Agreement';

  @override
  String get termsSection5Body =>
      'The app administration reserves the right to update the terms of use without prior notice. The current terms take effect on the date they are published within the App. The User may terminate the agreement at any time by deleting their account.';

  @override
  String get termsLastUpdated => 'Last updated: 11 August 2026';

  @override
  String get termsClose => 'I understand and close';

  @override
  String get homeGreeting => 'Hello,';

  @override
  String get userFallback => 'User';

  @override
  String get scanButton => 'Scan';

  @override
  String get scanTagline =>
      'Scan a product\'s barcode to see its contents\nand whether it suits you';

  @override
  String get recentScansTitle => 'Your recent scans';

  @override
  String get noScansYet => 'You haven\'t scanned any products yet.';

  @override
  String get contentAnalysis => 'Content analysis';

  @override
  String barcodeLabel(String barcode) {
    return 'Barcode: $barcode';
  }

  @override
  String get seeAllHistory => 'See all history';

  @override
  String get allMyScans => 'All my scans';

  @override
  String get historyNotFound => 'No history found.';

  @override
  String get searchNoResults => 'No results found.';

  @override
  String get searchError =>
      'Something went wrong during the search. Please try again.';

  @override
  String get adArea => 'AD SPACE';

  @override
  String get sponsored => 'Sponsored';

  @override
  String get adPlaceholderBody =>
      'Sponsored product announcements or dynamic ads will appear here.';

  @override
  String get adRemovePremiumNote =>
      'You can remove ads by upgrading to Premium in Settings.';

  @override
  String get scanTitle => 'Scan barcode';

  @override
  String get scanFrameHint =>
      'Align the barcode within the frame,\nit will be read automatically';

  @override
  String get enterBarcodeManually => 'Enter barcode manually';

  @override
  String get enterBarcode => 'Enter barcode';

  @override
  String get barcodeHintExample => 'e.g. 8690504112233';

  @override
  String get searchAction => 'Search';

  @override
  String get chatbotTitle => 'Smart Assistant';

  @override
  String chatbotGreeting(String name) {
    return 'How can I help you, $name?';
  }

  @override
  String get aiSuggestion => 'AI Suggestion';

  @override
  String get suggestionFallback =>
      'Would you like me to add a new feature to your profile?';

  @override
  String get no => 'No';

  @override
  String get yesAdd => 'Yes, add';

  @override
  String get assistantTyping => 'Assistant is typing...';

  @override
  String get askSomething => 'Ask something...';

  @override
  String get newChat => 'Start new chat';

  @override
  String get premiumFeature => 'Premium feature';

  @override
  String get chatbotPaywallBody =>
      'To use the chat assistant and receive AI advice tailored to your profile, you need to be a Premium member.';

  @override
  String get goToSettings => 'Go to Settings';

  @override
  String get chatError => 'An error occurred. Please try again.';

  @override
  String get addedToProfile => 'Added to your profile';

  @override
  String addedToProfileSnack(String value) {
    return '$value added to your profile!';
  }

  @override
  String get reportProductTitle => 'Product not found — Report';

  @override
  String get reportReceivedTitle => 'Report received';

  @override
  String get reportReceivedBody =>
      'Your product report and photos have been saved successfully. Thank you for your contribution!';

  @override
  String get reportIntro =>
      'Help us add this product to our database. You can improve accuracy by uploading photos.';

  @override
  String get productInfo => 'Product information';

  @override
  String get barcodeNumberLabel => 'Barcode number *';

  @override
  String get productNameBrandLabel => 'Product name & brand';

  @override
  String get productNameHintExample => 'e.g. Ülker Chocolate Wafer';

  @override
  String get ingredientsTextOptionalLabel => 'Ingredients text (optional)';

  @override
  String get ingredientsAutofillHint =>
      'When you take a photo, AI fills this in automatically. You can edit it manually if needed.';

  @override
  String get productPhotos => 'Product photos';

  @override
  String get productPhotosNote =>
      'Take or select the product\'s front, ingredients section and nutrition table.';

  @override
  String get photoFront => 'Front';

  @override
  String get photoIngredients => 'Ingredients';

  @override
  String get photoNutrition => 'Nutrition';

  @override
  String get submitting => 'Submitting...';

  @override
  String get reportProduct => 'Report product';

  @override
  String get takePhoto => 'Take a photo';

  @override
  String get pickFromGallery => 'Choose from gallery';

  @override
  String get invalidBarcode => 'Please enter a valid barcode.';

  @override
  String get submitFailed => 'Submission failed.';

  @override
  String get productDetailTitle => 'Product details';

  @override
  String get loadingProductAnalysis =>
      'Loading product info and AI analysis...';

  @override
  String get dietType => 'Diet type';

  @override
  String get noDietPreference => 'You have no saved diet preference.';

  @override
  String get healthConditionTitle => 'Health condition';

  @override
  String get noHealthCondition => 'You have no saved health condition.';

  @override
  String get reportToUs => 'Report this product';

  @override
  String get errorOccurred => 'An error occurred';

  @override
  String get productDetailServerError =>
      'Could not reach the server while loading product details.';

  @override
  String get goBack => 'Go back';

  @override
  String get tryAgain => 'Try again';

  @override
  String get productNotFoundTitle =>
      'We couldn\'t find this\nproduct in our database';

  @override
  String get productNotFoundBody =>
      'We\'d rather be honest than give wrong information. You can enter the barcode manually or help us by reporting the product.';

  @override
  String get sampleProductDemo => 'Show sample product (Demo)';

  @override
  String get allergiesTitle => 'Allergies';

  @override
  String get insufficientAllergenInfo =>
      'Ingredient info is missing; allergen check could not be performed.';

  @override
  String warningsCount(int count) {
    return '$count warning(s)';
  }

  @override
  String get noProfileAllergens =>
      'None of your profile allergens are in this product.';

  @override
  String get conflictsWithAllergies => 'Conflicts with your profile allergies';

  @override
  String get otherAllergensTitle => 'Other allergens';

  @override
  String get notInYourProfile => 'not in your profile';

  @override
  String get ingredientsTitle => 'Ingredients';

  @override
  String get noIngredientsInfo => 'No ingredient information for this product.';

  @override
  String get showLess => 'Show less';

  @override
  String get showAllText => 'Show all';

  @override
  String get nutrimentsTitle => 'Nutrition facts';

  @override
  String get per100g => 'per 100 g';

  @override
  String get noInfo => 'No info';

  @override
  String get unverified => 'Unverified';

  @override
  String get insufficientContentInfo =>
      'This product\'s content information is incomplete.';

  @override
  String get recommendationsTitle => 'Recommendations';

  @override
  String get seeAll => 'See all';

  @override
  String get recommendationsNeutralityNote =>
      'Our choices are impartial: no brand pays to appear here.';

  @override
  String get nutrientEnergy => 'Energy';

  @override
  String get nutrientSugar => 'Sugar';

  @override
  String get nutrientFat => 'Fat';

  @override
  String get nutrientProtein => 'Protein';

  @override
  String get energyLow => 'Low calorie';

  @override
  String get energyMedium => 'Medium calorie';

  @override
  String get energyHigh => 'High calorie';

  @override
  String get sugarLow => 'Low sugar';

  @override
  String get sugarMedium => 'Moderate sugar';

  @override
  String get sugarHigh => 'High sugar';

  @override
  String get fatLow => 'Low fat';

  @override
  String get fatMedium => 'Moderate fat';

  @override
  String get fatHigh => 'High fat';

  @override
  String get proteinHigh => 'Rich in protein';

  @override
  String get proteinMedium => 'Some protein';

  @override
  String get proteinLow => 'Very little protein';

  @override
  String get checkNotEvaluated => 'Could not be evaluated for this product';

  @override
  String get dietIncompatibleNote =>
      'This product contains unsuitable ingredients';

  @override
  String get dietCompatibleNote => 'This product matches your preference';

  @override
  String get healthConflictNote =>
      'This product contains ingredients risky for your condition';

  @override
  String get healthOkNote => 'No specific warning for this product';

  @override
  String get reasonAllergenIntro => 'It contains ';

  @override
  String get reasonAllergenOutro => ', which you react to. ';

  @override
  String get reasonAnd => ' and ';

  @override
  String get reasonDietOutro => ' doesn\'t fit your diet. ';

  @override
  String get reasonHealthIntro => 'For ';

  @override
  String get reasonHealthMid => ': ';

  @override
  String get reasonAllergenLineIntro => 'Contains ';

  @override
  String get reasonAllergenLineOutro => '.';

  @override
  String get reasonDietLineOutro => ' doesn\'t fit your diet.';

  @override
  String get reasonHealthLineOutro => ' isn\'t suitable for your condition.';

  @override
  String get verdictSuitable => 'Suitable';

  @override
  String get verdictCaution => 'Be careful';

  @override
  String get verdictUnsuitable => 'Not suitable!';

  @override
  String get verdictInsufficient => 'Insufficient data';

  @override
  String get allergenUnknown => 'Unknown allergen';

  @override
  String get allergenGluten => 'Gluten';

  @override
  String get allergenMilk => 'Milk / Lactose';

  @override
  String get allergenEggs => 'Eggs';

  @override
  String get allergenSoy => 'Soy';

  @override
  String get allergenPeanuts => 'Peanuts';

  @override
  String get allergenNuts => 'Tree nuts';

  @override
  String get allergenSesame => 'Sesame';

  @override
  String get allergenFish => 'Fish';

  @override
  String get allergenCrustaceans => 'Crustaceans';

  @override
  String get allergenMolluscs => 'Molluscs';

  @override
  String get allergenCelery => 'Celery';

  @override
  String get allergenMustard => 'Mustard';

  @override
  String get allergenLupin => 'Lupin';

  @override
  String get allergenSulphites => 'Sulphites';

  @override
  String get navHome => 'Home';

  @override
  String get navChatbot => 'Chatbot';

  @override
  String get searchProductHint => 'Search products';

  @override
  String get addOption => 'Add option';

  @override
  String get addAction => 'Add';

  @override
  String get countryDialogTitle => 'Country selection';

  @override
  String get countryDialogHint => 'Enter a country name (e.g. Türkiye)';

  @override
  String get quickSelect => 'Quick select';

  @override
  String get profileLoadRetry =>
      'Could not load your profile. Check your connection and try again.';

  @override
  String get relativeJustNow => 'Just now';

  @override
  String relativeMinutesAgo(int count) {
    return '$count min ago';
  }

  @override
  String relativeHoursAgo(int count) {
    return '$count h ago';
  }

  @override
  String get relativeYesterday => 'Yesterday';

  @override
  String relativeDaysAgo(int count) {
    return '$count days ago';
  }

  @override
  String get profileSectionAllergies => 'My allergies';

  @override
  String get profileSectionDiet => 'My diet';

  @override
  String get profileSectionHealth => 'My health';

  @override
  String get shoppingListsTitle => 'My shopping lists';

  @override
  String get seeAllUpper => 'See all';

  @override
  String get noShoppingListsTitle => 'No lists yet';

  @override
  String get noShoppingListsPrompt => 'Tap to create your first shopping list';

  @override
  String get createListTitle => 'Create new list';

  @override
  String get listNameHint => 'List name (e.g. Weekend market)';

  @override
  String get createAction => 'Create';

  @override
  String listCreated(String name) {
    return 'List \"$name\" created.';
  }

  @override
  String get newListTooltip => 'New list';

  @override
  String get noShoppingListsScreenTitle =>
      'You don\'t have any shopping lists yet';

  @override
  String get noShoppingListsScreenBody =>
      'Create a new list to easily plan your grocery or market shopping.';

  @override
  String listItemsSummary(int total, int bought) {
    return '$total items • $bought bought';
  }

  @override
  String get deleteListTitle => 'Delete list';

  @override
  String get deleteListConfirm =>
      'Are you sure you want to delete this shopping list and all its items?';

  @override
  String get deleteConfirmAction => 'Yes, delete';

  @override
  String get listDeleted => 'List deleted.';

  @override
  String get listDetailTitle => 'List details';

  @override
  String get shoppingProgress => 'Shopping progress';

  @override
  String progressBought(int bought, int total) {
    return '$bought / $total bought';
  }

  @override
  String get noItemsTitle => 'No items in this list yet';

  @override
  String get noItemsBody =>
      'Tap the \"Add product\" button below to add items from your recent scans or via search.';

  @override
  String get addProduct => 'Add product';

  @override
  String itemAdded(String name) {
    return '\"$name\" added to the list.';
  }

  @override
  String get itemAddFailed => 'Something went wrong while adding the product.';

  @override
  String get addProductToList => 'Add product to list';

  @override
  String get tabRecentScans => 'Recent scans';

  @override
  String get tabSearchManual => 'Search & add manually';

  @override
  String get noRecentScansTitle => 'No scanned products yet.';

  @override
  String get noRecentScansBody =>
      'When you scan a barcode to review a product, suggestions will appear here.';

  @override
  String get manualAddTitle => 'Enter product name manually';

  @override
  String get manualNameHint => 'e.g. Milk, Apple, Oats...';

  @override
  String get searchByNameTitle => 'Search by product name';

  @override
  String get searchByNameHint => 'Search by brand or product name...';

  @override
  String get medicalDisclaimerShort =>
      'This information is not medical advice.';

  @override
  String get optNutsPeanuts => 'Nuts / Peanuts';

  @override
  String get optVegan => 'Vegan';

  @override
  String get optVegetarian => 'Vegetarian';

  @override
  String get optDiabeticFriendly => 'Diabetic-friendly';

  @override
  String get optAthleteHighProtein => 'Athlete / High protein';

  @override
  String get optLowCarb => 'Low carb';

  @override
  String get optGlutenFreeLifestyle => 'Gluten-free lifestyle';

  @override
  String get optKetogenic => 'Ketogenic';

  @override
  String get optBloodPressure => 'Blood pressure';

  @override
  String get optCeliac => 'Celiac';

  @override
  String get optHighCholesterol => 'High cholesterol';

  @override
  String get optKidneyDisease => 'Kidney disease';

  @override
  String get optDiabetesDisease => 'Diabetes';

  @override
  String get optHeartCondition => 'Heart condition';
}
