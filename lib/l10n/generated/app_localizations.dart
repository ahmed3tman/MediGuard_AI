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

  /// Application title
  ///
  /// In en, this message translates to:
  /// **'Spider Doctor'**
  String get appTitle;

  /// Real time monitoring title
  ///
  /// In en, this message translates to:
  /// **'Real Time Monitoring'**
  String get realTimeMonitoring;

  /// Real time monitoring system title
  ///
  /// In en, this message translates to:
  /// **'Real Time Monitoring System'**
  String get realTimeMonitoringSystem;

  /// Message shown when waiting for device data
  ///
  /// In en, this message translates to:
  /// **'Waiting for device data...'**
  String get waitingForDeviceData;

  /// Temperature label
  ///
  /// In en, this message translates to:
  /// **'Temperature'**
  String get temperature;

  /// Placeholder text for question input
  ///
  /// In en, this message translates to:
  /// **'Tell me your question...'**
  String get tellMeYourQuestion;

  /// Home navigation label
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// Profile navigation label
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// Settings navigation label
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// Login button text
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// Email input label
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// Password input label
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// Sign in button text
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// Logout button text
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// Language setting label
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// English language option
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// Arabic language option
  ///
  /// In en, this message translates to:
  /// **'Arabic'**
  String get arabic;

  /// Select language dialog title
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// Manage profile button text
  ///
  /// In en, this message translates to:
  /// **'Manage Profile'**
  String get manageProfile;

  /// Continue to home button text
  ///
  /// In en, this message translates to:
  /// **'Continue to Home'**
  String get continueToHome;

  /// Loading message
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// Error message
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// Devices navigation label
  ///
  /// In en, this message translates to:
  /// **'Devices'**
  String get devices;

  /// Critical cases navigation label
  ///
  /// In en, this message translates to:
  /// **'Critical Cases'**
  String get criticalCases;

  /// Device status label
  ///
  /// In en, this message translates to:
  /// **'Device Status'**
  String get deviceStatus;

  /// Heart rate label
  ///
  /// In en, this message translates to:
  /// **'Heart Rate'**
  String get heartRate;

  /// Blood pressure label
  ///
  /// In en, this message translates to:
  /// **'Blood Pressure'**
  String get bloodPressure;

  /// Oxygen saturation label
  ///
  /// In en, this message translates to:
  /// **'SpO₂'**
  String get oxygenSaturation;

  /// Normal status
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get normal;

  /// Abnormal status
  ///
  /// In en, this message translates to:
  /// **'Abnormal'**
  String get abnormal;

  /// Connected status
  ///
  /// In en, this message translates to:
  /// **'CONNECTED'**
  String get connected;

  /// Disconnected status
  ///
  /// In en, this message translates to:
  /// **'Disconnected'**
  String get disconnected;

  /// Dashboard navigation label
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// My devices menu item
  ///
  /// In en, this message translates to:
  /// **'My Devices'**
  String get myDevices;

  /// Help and support menu item
  ///
  /// In en, this message translates to:
  /// **'Help & Support'**
  String get helpSupport;

  /// Sign out menu item
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get signOut;

  /// Sign out confirmation message
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to sign out from your account?'**
  String get signOutConfirm;

  /// Cancel button
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Signing out loading message
  ///
  /// In en, this message translates to:
  /// **'Signing out...'**
  String get signingOut;

  /// Notifications setting
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// Manage notifications description
  ///
  /// In en, this message translates to:
  /// **'Manage app notifications'**
  String get manageNotifications;

  /// Dark mode setting
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// Toggle theme description
  ///
  /// In en, this message translates to:
  /// **'Toggle between light and dark theme'**
  String get toggleTheme;

  /// Privacy setting
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get privacy;

  /// Privacy settings description
  ///
  /// In en, this message translates to:
  /// **'Privacy and security settings'**
  String get privacySettings;

  /// Device settings section
  ///
  /// In en, this message translates to:
  /// **'Device Settings'**
  String get deviceSettings;

  /// Wi-Fi settings
  ///
  /// In en, this message translates to:
  /// **'Wi-Fi Settings'**
  String get wifiSettings;

  /// Manage connections description
  ///
  /// In en, this message translates to:
  /// **'Manage Wi-Fi connections'**
  String get manageConnections;

  /// Bluetooth settings
  ///
  /// In en, this message translates to:
  /// **'Bluetooth Settings'**
  String get bluetoothSettings;

  /// Manage devices description
  ///
  /// In en, this message translates to:
  /// **'Manage connected devices'**
  String get manageDevices;

  /// Support section
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get support;

  /// Get help description
  ///
  /// In en, this message translates to:
  /// **'Get help and support'**
  String get getHelp;

  /// About menu item
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// App version description
  ///
  /// In en, this message translates to:
  /// **'App version and information'**
  String get appVersion;

  /// App description
  ///
  /// In en, this message translates to:
  /// **'A comprehensive medical monitoring system for real-time health tracking and device management.'**
  String get appDescription;

  /// Coming soon message
  ///
  /// In en, this message translates to:
  /// **'Coming Soon'**
  String get comingSoon;

  /// Emergency navigation label
  ///
  /// In en, this message translates to:
  /// **'Emergency'**
  String get emergency;

  /// Account information section
  ///
  /// In en, this message translates to:
  /// **'Account Information'**
  String get accountInformation;

  /// Email address field
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get emailAddress;

  /// Full name field
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// Member since field
  ///
  /// In en, this message translates to:
  /// **'Member Since'**
  String get memberSince;

  /// Not available text
  ///
  /// In en, this message translates to:
  /// **'Not available'**
  String get notAvailable;

  /// Default text when user name is not available
  ///
  /// In en, this message translates to:
  /// **'Unknown User'**
  String get unknownUser;

  /// Guest user text
  ///
  /// In en, this message translates to:
  /// **'Guest User'**
  String get guestUser;

  /// Medical professional text
  ///
  /// In en, this message translates to:
  /// **'Medical Professional'**
  String get medicalProfessional;

  /// Account type field
  ///
  /// In en, this message translates to:
  /// **'Account Type'**
  String get accountType;

  /// Guest account type
  ///
  /// In en, this message translates to:
  /// **'Guest'**
  String get guest;

  /// Full account type
  ///
  /// In en, this message translates to:
  /// **'Full'**
  String get full;

  /// Push notifications feature
  ///
  /// In en, this message translates to:
  /// **'Push Notifications'**
  String get pushNotifications;

  /// Data export feature
  ///
  /// In en, this message translates to:
  /// **'Data Export'**
  String get dataExport;

  /// Device sharing feature
  ///
  /// In en, this message translates to:
  /// **'Device Sharing'**
  String get deviceSharing;

  /// Advanced analytics feature
  ///
  /// In en, this message translates to:
  /// **'Advanced Analytics'**
  String get advancedAnalytics;

  /// Add device button
  ///
  /// In en, this message translates to:
  /// **'Add Device'**
  String get addDevice;

  /// Add device tooltip
  ///
  /// In en, this message translates to:
  /// **'Add a new device'**
  String get addDeviceTooltip;

  /// Unknown text
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknown;

  /// Last updated label
  ///
  /// In en, this message translates to:
  /// **'Last updated'**
  String get lastUpdated;

  /// Not connected status
  ///
  /// In en, this message translates to:
  /// **'NOT CONNECTED'**
  String get notConnected;

  /// Add device screen title
  ///
  /// In en, this message translates to:
  /// **'Add Device'**
  String get addDeviceScreen;

  /// Device name field
  ///
  /// In en, this message translates to:
  /// **'Device Name'**
  String get deviceName;

  /// Enter device name hint
  ///
  /// In en, this message translates to:
  /// **'Enter device name'**
  String get enterDeviceName;

  /// Device ID field
  ///
  /// In en, this message translates to:
  /// **'Device ID'**
  String get deviceId;

  /// Enter device ID hint
  ///
  /// In en, this message translates to:
  /// **'Enter device ID'**
  String get enterDeviceId;

  /// Save button
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// Device added success message
  ///
  /// In en, this message translates to:
  /// **'Device added successfully'**
  String get deviceAddedSuccessfully;

  /// Error adding device message
  ///
  /// In en, this message translates to:
  /// **'Error adding device'**
  String get errorAddingDevice;

  /// Please enter device name validation
  ///
  /// In en, this message translates to:
  /// **'Please enter device name'**
  String get pleaseEnterDeviceName;

  /// Please enter device ID validation
  ///
  /// In en, this message translates to:
  /// **'Please enter device ID'**
  String get pleaseEnterDeviceId;

  /// Device ID minimum length validation
  ///
  /// In en, this message translates to:
  /// **'Device ID must be at least 3 characters'**
  String get deviceIdMinLength;

  /// Device name minimum length validation
  ///
  /// In en, this message translates to:
  /// **'Device name must be at least 2 characters'**
  String get deviceNameMinLength;

  /// Device information message
  ///
  /// In en, this message translates to:
  /// **'Make sure the device ID matches the physical device identifier. This will be used to receive real-time data.'**
  String get deviceInfoMessage;

  /// Error signing out message
  ///
  /// In en, this message translates to:
  /// **'Error signing out'**
  String get errorSigningOut;

  /// Settings coming soon message
  ///
  /// In en, this message translates to:
  /// **'Settings - Coming Soon'**
  String get settingsComingSoon;

  /// Help and support coming soon message
  ///
  /// In en, this message translates to:
  /// **'Help & Support - Coming Soon'**
  String get helpSupportComingSoon;

  /// Device connected status
  ///
  /// In en, this message translates to:
  /// **'Device connected - Real-time data available'**
  String get deviceConnected;

  /// ECG label
  ///
  /// In en, this message translates to:
  /// **'ECG'**
  String get ecg;

  /// SpO2 label
  ///
  /// In en, this message translates to:
  /// **'SpO2'**
  String get spo2;

  /// No devices found message
  ///
  /// In en, this message translates to:
  /// **'No devices found'**
  String get noDevicesFound;

  /// Searching for devices message
  ///
  /// In en, this message translates to:
  /// **'Searching for devices...'**
  String get searchingForDevices;

  /// Connecting to device message
  ///
  /// In en, this message translates to:
  /// **'Connecting to device...'**
  String get connectingToDevice;

  /// Device connected successfully message
  ///
  /// In en, this message translates to:
  /// **'Device connected successfully'**
  String get deviceConnectedSuccessfully;

  /// Failed to connect to device message
  ///
  /// In en, this message translates to:
  /// **'Failed to connect to device'**
  String get failedToConnectToDevice;

  /// Device disconnected message
  ///
  /// In en, this message translates to:
  /// **'Device disconnected'**
  String get deviceDisconnected;

  /// Retry button
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// Refresh button
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// Searching status
  ///
  /// In en, this message translates to:
  /// **'Searching'**
  String get searching;

  /// Connecting status
  ///
  /// In en, this message translates to:
  /// **'Connecting'**
  String get connecting;

  /// Success message
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get success;

  /// Warning message
  ///
  /// In en, this message translates to:
  /// **'Warning'**
  String get warning;

  /// Information status
  ///
  /// In en, this message translates to:
  /// **'Information'**
  String get info;

  /// Sign up button text
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUp;

  /// Create account button text
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// Already have an account text
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get alreadyHaveAccount;

  /// Don't have an account text
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get dontHaveAccount;

  /// Welcome message with user name
  ///
  /// In en, this message translates to:
  /// **'Welcome, {userName}!'**
  String welcomeUser(String userName);

  /// Account created success message
  ///
  /// In en, this message translates to:
  /// **'Your account has been created successfully'**
  String get accountCreatedSuccessfully;

  /// Features section title
  ///
  /// In en, this message translates to:
  /// **'What you can do now:'**
  String get whatYouCanDoNow;

  /// Add medical devices feature
  ///
  /// In en, this message translates to:
  /// **'Add Medical Devices'**
  String get addMedicalDevices;

  /// Add medical devices description
  ///
  /// In en, this message translates to:
  /// **'Connect and monitor your medical devices in real-time'**
  String get addMedicalDevicesDesc;

  /// View live data feature
  ///
  /// In en, this message translates to:
  /// **'View Live Data'**
  String get viewLiveData;

  /// View live data description
  ///
  /// In en, this message translates to:
  /// **'Monitor vital signs and device readings continuously'**
  String get viewLiveDataDesc;

  /// Manage profile description
  ///
  /// In en, this message translates to:
  /// **'Update your information and view account statistics'**
  String get manageProfileDesc;

  /// Name validation message
  ///
  /// In en, this message translates to:
  /// **'Please enter your full name'**
  String get pleaseEnterName;

  /// Name minimum length validation
  ///
  /// In en, this message translates to:
  /// **'Name must be at least 2 characters'**
  String get nameMinLength;

  /// Email validation message
  ///
  /// In en, this message translates to:
  /// **'Please enter your email'**
  String get pleaseEnterEmail;

  /// Valid email validation message
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email'**
  String get pleaseEnterValidEmail;

  /// Password validation message
  ///
  /// In en, this message translates to:
  /// **'Please enter your password'**
  String get pleaseEnterPassword;

  /// Password minimum length validation
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get passwordMinLength;

  /// Title shown when no devices are added
  ///
  /// In en, this message translates to:
  /// **'No Devices Added'**
  String get noDevicesAdded;

  /// Subtitle shown when no devices are added
  ///
  /// In en, this message translates to:
  /// **'Add your first medical device to start monitoring vital signs in real-time.'**
  String get addFirstMedicalDevice;

  /// Button text to add a demo device
  ///
  /// In en, this message translates to:
  /// **'Add Demo Device'**
  String get addDemoDevice;

  /// Loading message when fetching devices
  ///
  /// In en, this message translates to:
  /// **'Loading devices...'**
  String get loadingDevices;

  /// Time indicator for recent updates
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get justNow;

  /// Delete device dialog title
  ///
  /// In en, this message translates to:
  /// **'Delete Device'**
  String get deleteDevice;

  /// Delete device confirmation message
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \"{deviceName}\"?'**
  String deleteDeviceConfirm(String deviceName);

  /// Delete button text
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// Confirm button text
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// Demo label
  ///
  /// In en, this message translates to:
  /// **'Demo'**
  String get demo;

  /// Default text when email is not available
  ///
  /// In en, this message translates to:
  /// **'No email'**
  String get noEmail;

  /// Language test screen title
  ///
  /// In en, this message translates to:
  /// **'Language Test'**
  String get languageTest;

  /// Save English language button
  ///
  /// In en, this message translates to:
  /// **'Save English'**
  String get saveEnglish;

  /// Save Arabic language button
  ///
  /// In en, this message translates to:
  /// **'Save Arabic'**
  String get saveArabic;

  /// Reload language button
  ///
  /// In en, this message translates to:
  /// **'Reload Language'**
  String get reloadLanguage;

  /// Saved language label
  ///
  /// In en, this message translates to:
  /// **'Saved Language'**
  String get savedLanguage;

  /// Current language label
  ///
  /// In en, this message translates to:
  /// **'Current Language'**
  String get currentLanguage;

  /// Text when value is not set
  ///
  /// In en, this message translates to:
  /// **'Not set'**
  String get notSet;

  /// Instruction to press save arabic button
  ///
  /// In en, this message translates to:
  /// **'Press \"Save Arabic\"'**
  String get pressSaveArabic;

  /// Instruction to check if language is still arabic
  ///
  /// In en, this message translates to:
  /// **'Check if language is still \"ar\"'**
  String get checkLanguageStillAr;

  /// Patient details title
  ///
  /// In en, this message translates to:
  /// **'Patient Details'**
  String get patientDetails;

  /// Doctor tab title
  ///
  /// In en, this message translates to:
  /// **'Doctor'**
  String get doctorTab;

  /// Vital signs section title
  ///
  /// In en, this message translates to:
  /// **'Vital Signs'**
  String get vitalSigns;

  /// ECG monitor section title
  ///
  /// In en, this message translates to:
  /// **'ECG Monitor'**
  String get ecgMonitor;

  /// Message when no ECG data
  ///
  /// In en, this message translates to:
  /// **'No ECG data available'**
  String get noEcgDataAvailable;

  /// Message waiting for device
  ///
  /// In en, this message translates to:
  /// **'Waiting for device connection...'**
  String get waitingForDeviceConnection;

  /// Monitoring controls section title
  ///
  /// In en, this message translates to:
  /// **'Monitoring Controls'**
  String get monitoringControls;

  /// Refresh data button
  ///
  /// In en, this message translates to:
  /// **'Refresh Data'**
  String get refreshData;

  /// Cleanup data button
  ///
  /// In en, this message translates to:
  /// **'Cleanup Data'**
  String get cleanupData;
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
