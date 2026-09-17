// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'ResQnet';

  @override
  String get appTagline => 'Community Emergency Assistance Network';

  @override
  String get medicalEmergency => 'Medical Emergency';

  @override
  String get fireEmergency => 'Fire Emergency';

  @override
  String get accidentEmergency => 'Accident Emergency';

  @override
  String get nearbySafety => 'Nearby Safety';

  @override
  String get sos => 'SOS';

  @override
  String get pressAndHoldSos => 'PRESS AND HOLD FOR SOS';

  @override
  String get confirmMedicalTitle => 'Send Medical Emergency Alert?';

  @override
  String get confirmFireTitle => 'Send Fire Emergency Alert?';

  @override
  String get confirmAccidentTitle => 'Send Accident Emergency Alert?';

  @override
  String get confirmSosTitle => 'Trigger SOS Emergency Alert?';

  @override
  String get confirmEmergencyMessage =>
      'This will notify eligible ResQnet helpers within 1 km of your location.';

  @override
  String get cancel => 'Cancel';

  @override
  String get sendAlert => 'Send Alert';

  @override
  String get medicalEmergencyActive => 'MEDICAL EMERGENCY ACTIVE';

  @override
  String get fireEmergencyActive => 'FIRE EMERGENCY ACTIVE';

  @override
  String get accidentEmergencyActive => 'ACCIDENT EMERGENCY ACTIVE';

  @override
  String get sosActive => 'SOS ACTIVE';

  @override
  String get currentLocation => 'Current Location';

  @override
  String get timeElapsed => 'Time Elapsed';

  @override
  String get helpersNotified => 'Helpers Notified';

  @override
  String get helpersResponding => 'Helpers Responding';

  @override
  String helpersCountResponding(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count helpers responding',
      one: '1 helper responding',
    );
    return '$_temp0';
  }

  @override
  String get updateLocation => 'UPDATE LOCATION';

  @override
  String get markAsSafe => 'MARK AS SAFE';

  @override
  String get cancelAlert => 'CANCEL ALERT';

  @override
  String get cancelSos => 'CANCEL SOS';

  @override
  String get imComing => 'I\'M COMING';

  @override
  String get openDirections => 'OPEN DIRECTIONS';

  @override
  String get cantHelp => 'CAN\'T HELP';

  @override
  String distanceAway(int distance) {
    return 'Approximately $distance m away';
  }

  @override
  String reportedAgo(int minutes) {
    return 'Reported $minutes minutes ago';
  }

  @override
  String get peopleNearby => 'PEOPLE NEARBY';

  @override
  String get male => 'Male';

  @override
  String get female => 'Female';

  @override
  String get other => 'Other';

  @override
  String get totalResqnetUsers => 'Total ResQnet Users';

  @override
  String get radius500m => '500 metres';

  @override
  String get radius1km => '1 kilometre';

  @override
  String get availableToHelp => 'Available to Help';

  @override
  String get availableToHelpDesc =>
      'Allow nearby community members to notify you in an emergency.';

  @override
  String get locationStatus => 'Location';

  @override
  String get notificationStatus => 'Notifications';

  @override
  String get enabled => 'Enabled';

  @override
  String get disabled => 'Disabled';

  @override
  String get navHome => 'HOME';

  @override
  String get navActivity => 'ACTIVITY';

  @override
  String get navMap => 'MAP';

  @override
  String get navProfile => 'PROFILE';

  @override
  String get login => 'Login';

  @override
  String get signUp => 'Sign Up';

  @override
  String get fullName => 'Full Name';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get confirmPassword => 'Confirm Password';

  @override
  String get gender => 'Gender';

  @override
  String get forgotPassword => 'Forgot Password?';

  @override
  String get createAccount => 'Create Account';

  @override
  String get alreadyHaveAccount => 'Already have an account? Login';

  @override
  String get dontHaveAccount => 'Don\'t have an account? Sign Up';

  @override
  String get agreeTerms => 'I agree to the Terms of Service & Privacy Policy';

  @override
  String get communityNotice =>
      'ResQnet is a community assistance platform connecting nearby citizens. It does not replace official emergency services.';

  @override
  String get callOfficialServices => 'Call Official Services (112)';

  @override
  String get privacyAssurance =>
      'Your exact location and identity are never publicly broadcast. Aggregate data only.';

  @override
  String get demoMode => 'Demo / Simulation Mode';

  @override
  String get demoModeActive => 'DEMO MODE ACTIVE - Data is simulated';

  @override
  String get logout => 'Logout';

  @override
  String get deleteAccount => 'Delete Account';

  @override
  String get theme => 'Theme';

  @override
  String get language => 'Language';

  @override
  String get english => 'English';

  @override
  String get tamil => 'தமிழ்';

  @override
  String get noInternet => 'No internet connection. Please check your network.';

  @override
  String get locationPermissionRequired =>
      'Location permission is required for emergency dispatch.';

  @override
  String get notificationPermissionRequired =>
      'Notification permission is needed to receive emergency alerts.';

  @override
  String get noHelpersNearby =>
      'No helpers are currently available nearby. Consider contacting official emergency services.';
}
