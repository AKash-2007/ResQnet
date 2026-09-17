// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Tamil (`ta`).
class AppLocalizationsTa extends AppLocalizations {
  AppLocalizationsTa([String locale = 'ta']) : super(locale);

  @override
  String get appName => 'ResQnet';

  @override
  String get appTagline => 'சமூக அவசர உதவி நெட்வொர்க்';

  @override
  String get medicalEmergency => 'மருத்துவ அவசரம்';

  @override
  String get fireEmergency => 'தீ விபத்து அவசரம்';

  @override
  String get accidentEmergency => 'விபத்து அவசரம்';

  @override
  String get nearbySafety => 'அருகிலுள்ள பாதுகாப்பு';

  @override
  String get sos => 'SOS';

  @override
  String get pressAndHoldSos => 'SOS க்காக அழுத்திப் பிடிக்கவும்';

  @override
  String get confirmMedicalTitle => 'மருத்துவ அவசர எச்சரிக்கையை அனுப்பவா?';

  @override
  String get confirmFireTitle => 'தீ விபத்து அவசர எச்சரிக்கையை அனுப்பவா?';

  @override
  String get confirmAccidentTitle => 'விபத்து அவசர எச்சரிக்கையை அனுப்பவா?';

  @override
  String get confirmSosTitle => 'SOS அவசர எச்சரிக்கையை அனுப்பவா?';

  @override
  String get confirmEmergencyMessage =>
      'இது உங்கள் இருப்பிடத்திலிருந்து 1 கிமீ சுற்றளவில் உள்ள தகுதியான ResQnet உதவியாளர்களுக்கு தெரிவிக்கும்.';

  @override
  String get cancel => 'ரத்து செய்';

  @override
  String get sendAlert => 'எச்சரிக்கை அனுப்பு';

  @override
  String get medicalEmergencyActive => 'மருத்துவ அவசரம் செயலில் உள்ளது';

  @override
  String get fireEmergencyActive => 'தீ விபத்து அவசரம் செயலில் உள்ளது';

  @override
  String get accidentEmergencyActive => 'விபத்து அவசரம் செயலில் உள்ளது';

  @override
  String get sosActive => 'SOS செயலில் உள்ளது';

  @override
  String get currentLocation => 'தற்போதைய இருப்பிடம்';

  @override
  String get timeElapsed => 'கடந்த நேரம்';

  @override
  String get helpersNotified => 'அறிவிக்கப்பட்ட உதவியாளர்கள்';

  @override
  String get helpersResponding => 'பதிலளிக்கும் உதவியாளர்கள்';

  @override
  String helpersCountResponding(int count) {
    return '$count உதவியாளர்(கள்) பதிலளிக்கிறார்கள்';
  }

  @override
  String get updateLocation => 'இருப்பிடத்தை புதுப்பி';

  @override
  String get markAsSafe => 'நான் பாதுகாப்பாக இருக்கிறேன்';

  @override
  String get cancelAlert => 'எச்சரிக்கையை ரத்து செய்';

  @override
  String get cancelSos => 'SOS ரத்து செய்';

  @override
  String get imComing => 'நான் வருகிறேன்';

  @override
  String get openDirections => 'வழிகளைத் திற';

  @override
  String get cantHelp => 'உதவ முடியாது';

  @override
  String distanceAway(int distance) {
    return 'தோராயமாக $distance மீ தொலைவில்';
  }

  @override
  String reportedAgo(int minutes) {
    return '$minutes நிமிடங்களுக்கு முன்பு பதிவு செய்யப்பட்டது';
  }

  @override
  String get peopleNearby => 'அருகிலுள்ள நபர்கள்';

  @override
  String get male => 'ஆண்கள்';

  @override
  String get female => 'பெண்கள்';

  @override
  String get other => 'மற்றவர்கள்';

  @override
  String get totalResqnetUsers => 'மொத்த ResQnet பயனர்கள்';

  @override
  String get radius500m => '500 மீட்டர்கள்';

  @override
  String get radius1km => '1 கிலோமீட்டர்';

  @override
  String get availableToHelp => 'உதவ தயாராக உள்ளேன்';

  @override
  String get availableToHelpDesc =>
      'அவசர காலத்தில் அருகிலுள்ள சமூக உறுப்பினர்கள் உங்களுக்கு தெரிவிக்க அனுமதிக்கவும்.';

  @override
  String get locationStatus => 'இருப்பிடம்';

  @override
  String get notificationStatus => 'அறிவிப்புகள்';

  @override
  String get enabled => 'இயக்கப்பட்டது';

  @override
  String get disabled => 'முடக்கப்பட்டது';

  @override
  String get navHome => 'முகப்பு';

  @override
  String get navActivity => 'செயல்பாடுகள்';

  @override
  String get navMap => 'வரைபடம்';

  @override
  String get navProfile => 'சுயவிவரம்';

  @override
  String get login => 'உள்நுழைக';

  @override
  String get signUp => 'பதிவு செய்க';

  @override
  String get fullName => 'முழு பெயர்';

  @override
  String get email => 'மின்னஞ்சல்';

  @override
  String get password => 'கடவுச்சொல்';

  @override
  String get confirmPassword => 'கடவுச்சொல்லை உறுதிப்படுத்தவும்';

  @override
  String get gender => 'பாலினம்';

  @override
  String get forgotPassword => 'கடவுச்சொல்லை மறந்துவிட்டீர்களா?';

  @override
  String get createAccount => 'கணக்கை உருவாக்கவும்';

  @override
  String get alreadyHaveAccount => 'ஏற்கனவே கணக்கு உள்ளதா? உள்நுழைக';

  @override
  String get dontHaveAccount => 'கணக்கு இல்லையா? பதிவு செய்க';

  @override
  String get agreeTerms => 'விதிமுறைகள் மற்றும் தனியுரிமைக் கொள்கையை ஏற்கிறேன்';

  @override
  String get communityNotice =>
      'ResQnet என்பது அருகிலுள்ள குடிமக்களை இணைக்கும் ஒரு சமூக உதவி தளம். இது அதிகாரப்பூர்வ அவசர சேவைகளை மாற்றாது.';

  @override
  String get callOfficialServices => 'அதிகாரப்பூர்வ சேவைகளை அழைக்கவும் (112)';

  @override
  String get privacyAssurance =>
      'உங்கள் துல்லியமான இருப்பிடமும் அடையாளமும் பகிரப்படாது. கூட்டுத் தரவு மட்டுமே.';

  @override
  String get demoMode => 'டெமோ முறை';

  @override
  String get demoModeActive => 'டெமோ முறை செயலில் உள்ளது';

  @override
  String get logout => 'வெளியேறு';

  @override
  String get deleteAccount => 'கணக்கை நீக்கு';

  @override
  String get theme => 'தீம்';

  @override
  String get language => 'மொழி';

  @override
  String get english => 'English';

  @override
  String get tamil => 'தமிழ்';

  @override
  String get noInternet => 'இணைய இணைப்பு இல்லை. நெட்வொர்க்கை சரிபார்க்கவும்.';

  @override
  String get locationPermissionRequired =>
      'அவசர உதவிக்கு இருப்பிட அனுமதி தேவை.';

  @override
  String get notificationPermissionRequired =>
      'உதவி எச்சரிக்கைகளைப் பெற அறிவிப்பு அனுமதி தேவை.';

  @override
  String get noHelpersNearby =>
      'அருகில் தற்போது உதவியாளர்கள் இல்லை. அதிகாரப்பூர்வ அவசர சேவைகளை அழைக்கவும்.';
}
