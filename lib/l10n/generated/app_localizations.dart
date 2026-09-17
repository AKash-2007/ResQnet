import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ta.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
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
    Locale('ta'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'ResQnet'**
  String get appName;

  /// No description provided for @appTagline.
  ///
  /// In en, this message translates to:
  /// **'Community Emergency Assistance Network'**
  String get appTagline;

  /// No description provided for @medicalEmergency.
  ///
  /// In en, this message translates to:
  /// **'Medical Emergency'**
  String get medicalEmergency;

  /// No description provided for @fireEmergency.
  ///
  /// In en, this message translates to:
  /// **'Fire Emergency'**
  String get fireEmergency;

  /// No description provided for @accidentEmergency.
  ///
  /// In en, this message translates to:
  /// **'Accident Emergency'**
  String get accidentEmergency;

  /// No description provided for @nearbySafety.
  ///
  /// In en, this message translates to:
  /// **'Nearby Safety'**
  String get nearbySafety;

  /// No description provided for @sos.
  ///
  /// In en, this message translates to:
  /// **'SOS'**
  String get sos;

  /// No description provided for @pressAndHoldSos.
  ///
  /// In en, this message translates to:
  /// **'PRESS AND HOLD FOR SOS'**
  String get pressAndHoldSos;

  /// No description provided for @confirmMedicalTitle.
  ///
  /// In en, this message translates to:
  /// **'Send Medical Emergency Alert?'**
  String get confirmMedicalTitle;

  /// No description provided for @confirmFireTitle.
  ///
  /// In en, this message translates to:
  /// **'Send Fire Emergency Alert?'**
  String get confirmFireTitle;

  /// No description provided for @confirmAccidentTitle.
  ///
  /// In en, this message translates to:
  /// **'Send Accident Emergency Alert?'**
  String get confirmAccidentTitle;

  /// No description provided for @confirmSosTitle.
  ///
  /// In en, this message translates to:
  /// **'Trigger SOS Emergency Alert?'**
  String get confirmSosTitle;

  /// No description provided for @confirmEmergencyMessage.
  ///
  /// In en, this message translates to:
  /// **'This will notify eligible ResQnet helpers within 1 km of your location.'**
  String get confirmEmergencyMessage;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @sendAlert.
  ///
  /// In en, this message translates to:
  /// **'Send Alert'**
  String get sendAlert;

  /// No description provided for @medicalEmergencyActive.
  ///
  /// In en, this message translates to:
  /// **'MEDICAL EMERGENCY ACTIVE'**
  String get medicalEmergencyActive;

  /// No description provided for @fireEmergencyActive.
  ///
  /// In en, this message translates to:
  /// **'FIRE EMERGENCY ACTIVE'**
  String get fireEmergencyActive;

  /// No description provided for @accidentEmergencyActive.
  ///
  /// In en, this message translates to:
  /// **'ACCIDENT EMERGENCY ACTIVE'**
  String get accidentEmergencyActive;

  /// No description provided for @sosActive.
  ///
  /// In en, this message translates to:
  /// **'SOS ACTIVE'**
  String get sosActive;

  /// No description provided for @currentLocation.
  ///
  /// In en, this message translates to:
  /// **'Current Location'**
  String get currentLocation;

  /// No description provided for @timeElapsed.
  ///
  /// In en, this message translates to:
  /// **'Time Elapsed'**
  String get timeElapsed;

  /// No description provided for @helpersNotified.
  ///
  /// In en, this message translates to:
  /// **'Helpers Notified'**
  String get helpersNotified;

  /// No description provided for @helpersResponding.
  ///
  /// In en, this message translates to:
  /// **'Helpers Responding'**
  String get helpersResponding;

  /// No description provided for @helpersCountResponding.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 helper responding} other{{count} helpers responding}}'**
  String helpersCountResponding(int count);

  /// No description provided for @updateLocation.
  ///
  /// In en, this message translates to:
  /// **'UPDATE LOCATION'**
  String get updateLocation;

  /// No description provided for @markAsSafe.
  ///
  /// In en, this message translates to:
  /// **'MARK AS SAFE'**
  String get markAsSafe;

  /// No description provided for @cancelAlert.
  ///
  /// In en, this message translates to:
  /// **'CANCEL ALERT'**
  String get cancelAlert;

  /// No description provided for @cancelSos.
  ///
  /// In en, this message translates to:
  /// **'CANCEL SOS'**
  String get cancelSos;

  /// No description provided for @imComing.
  ///
  /// In en, this message translates to:
  /// **'I\'M COMING'**
  String get imComing;

  /// No description provided for @openDirections.
  ///
  /// In en, this message translates to:
  /// **'OPEN DIRECTIONS'**
  String get openDirections;

  /// No description provided for @cantHelp.
  ///
  /// In en, this message translates to:
  /// **'CAN\'T HELP'**
  String get cantHelp;

  /// No description provided for @distanceAway.
  ///
  /// In en, this message translates to:
  /// **'Approximately {distance} m away'**
  String distanceAway(int distance);

  /// No description provided for @reportedAgo.
  ///
  /// In en, this message translates to:
  /// **'Reported {minutes} minutes ago'**
  String reportedAgo(int minutes);

  /// No description provided for @peopleNearby.
  ///
  /// In en, this message translates to:
  /// **'PEOPLE NEARBY'**
  String get peopleNearby;

  /// No description provided for @male.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get male;

  /// No description provided for @female.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get female;

  /// No description provided for @other.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get other;

  /// No description provided for @totalResqnetUsers.
  ///
  /// In en, this message translates to:
  /// **'Total ResQnet Users'**
  String get totalResqnetUsers;

  /// No description provided for @radius500m.
  ///
  /// In en, this message translates to:
  /// **'500 metres'**
  String get radius500m;

  /// No description provided for @radius1km.
  ///
  /// In en, this message translates to:
  /// **'1 kilometre'**
  String get radius1km;

  /// No description provided for @availableToHelp.
  ///
  /// In en, this message translates to:
  /// **'Available to Help'**
  String get availableToHelp;

  /// No description provided for @availableToHelpDesc.
  ///
  /// In en, this message translates to:
  /// **'Allow nearby community members to notify you in an emergency.'**
  String get availableToHelpDesc;

  /// No description provided for @locationStatus.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get locationStatus;

  /// No description provided for @notificationStatus.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationStatus;

  /// No description provided for @enabled.
  ///
  /// In en, this message translates to:
  /// **'Enabled'**
  String get enabled;

  /// No description provided for @disabled.
  ///
  /// In en, this message translates to:
  /// **'Disabled'**
  String get disabled;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'HOME'**
  String get navHome;

  /// No description provided for @navActivity.
  ///
  /// In en, this message translates to:
  /// **'ACTIVITY'**
  String get navActivity;

  /// No description provided for @navMap.
  ///
  /// In en, this message translates to:
  /// **'MAP'**
  String get navMap;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'PROFILE'**
  String get navProfile;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUp;

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

  /// No description provided for @gender.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get gender;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? Login'**
  String get alreadyHaveAccount;

  /// No description provided for @dontHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? Sign Up'**
  String get dontHaveAccount;

  /// No description provided for @agreeTerms.
  ///
  /// In en, this message translates to:
  /// **'I agree to the Terms of Service & Privacy Policy'**
  String get agreeTerms;

  /// No description provided for @communityNotice.
  ///
  /// In en, this message translates to:
  /// **'ResQnet is a community assistance platform connecting nearby citizens. It does not replace official emergency services.'**
  String get communityNotice;

  /// No description provided for @callOfficialServices.
  ///
  /// In en, this message translates to:
  /// **'Call Official Services (112)'**
  String get callOfficialServices;

  /// No description provided for @privacyAssurance.
  ///
  /// In en, this message translates to:
  /// **'Your exact location and identity are never publicly broadcast. Aggregate data only.'**
  String get privacyAssurance;

  /// No description provided for @demoMode.
  ///
  /// In en, this message translates to:
  /// **'Demo / Simulation Mode'**
  String get demoMode;

  /// No description provided for @demoModeActive.
  ///
  /// In en, this message translates to:
  /// **'DEMO MODE ACTIVE - Data is simulated'**
  String get demoModeActive;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @deleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get deleteAccount;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @tamil.
  ///
  /// In en, this message translates to:
  /// **'தமிழ்'**
  String get tamil;

  /// No description provided for @noInternet.
  ///
  /// In en, this message translates to:
  /// **'No internet connection. Please check your network.'**
  String get noInternet;

  /// No description provided for @locationPermissionRequired.
  ///
  /// In en, this message translates to:
  /// **'Location permission is required for emergency dispatch.'**
  String get locationPermissionRequired;

  /// No description provided for @notificationPermissionRequired.
  ///
  /// In en, this message translates to:
  /// **'Notification permission is needed to receive emergency alerts.'**
  String get notificationPermissionRequired;

  /// No description provided for @noHelpersNearby.
  ///
  /// In en, this message translates to:
  /// **'No helpers are currently available nearby. Consider contacting official emergency services.'**
  String get noHelpersNearby;
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
      <String>['en', 'ta'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ta':
      return AppLocalizationsTa();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
