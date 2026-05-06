import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_kn.dart';
import 'app_localizations_ta.dart';
import 'app_localizations_te.dart';

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
    Locale('hi'),
    Locale('kn'),
    Locale('ta'),
    Locale('te')
  ];

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTitle;

  /// No description provided for @contactInfo.
  ///
  /// In en, this message translates to:
  /// **'Contact Info'**
  String get contactInfo;

  /// No description provided for @healthDetails.
  ///
  /// In en, this message translates to:
  /// **'Health Details'**
  String get healthDetails;

  /// No description provided for @familyManagement.
  ///
  /// In en, this message translates to:
  /// **'Family Management'**
  String get familyManagement;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @mobileNumber.
  ///
  /// In en, this message translates to:
  /// **'Mobile Number'**
  String get mobileNumber;

  /// No description provided for @notSet.
  ///
  /// In en, this message translates to:
  /// **'Not Set'**
  String get notSet;

  /// No description provided for @emailAddress.
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get emailAddress;

  /// No description provided for @bloodGroup.
  ///
  /// In en, this message translates to:
  /// **'Blood Group'**
  String get bloodGroup;

  /// No description provided for @unknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknown;

  /// No description provided for @weight.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get weight;

  /// No description provided for @height.
  ///
  /// In en, this message translates to:
  /// **'Height'**
  String get height;

  /// No description provided for @dataPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Data & Privacy'**
  String get dataPrivacy;

  /// No description provided for @deviceSecurity.
  ///
  /// In en, this message translates to:
  /// **'Device Access & Security'**
  String get deviceSecurity;

  /// No description provided for @managePermissions.
  ///
  /// In en, this message translates to:
  /// **'Manage Permissions'**
  String get managePermissions;

  /// No description provided for @appSettings.
  ///
  /// In en, this message translates to:
  /// **'App Settings'**
  String get appSettings;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @membershipPlan.
  ///
  /// In en, this message translates to:
  /// **'Membership Plan'**
  String get membershipPlan;

  /// No description provided for @free.
  ///
  /// In en, this message translates to:
  /// **'Free'**
  String get free;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @user.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get user;

  /// No description provided for @member.
  ///
  /// In en, this message translates to:
  /// **'Member'**
  String get member;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'WELCOME BACK'**
  String get welcomeBack;

  /// No description provided for @totalReports.
  ///
  /// In en, this message translates to:
  /// **'TOTAL REPORTS'**
  String get totalReports;

  /// No description provided for @lastVitals.
  ///
  /// In en, this message translates to:
  /// **'LAST VITALS'**
  String get lastVitals;

  /// No description provided for @noVitals.
  ///
  /// In en, this message translates to:
  /// **'No vitals logged'**
  String get noVitals;

  /// No description provided for @todaySnapshot.
  ///
  /// In en, this message translates to:
  /// **'TODAY\'S SNAPSHOT'**
  String get todaySnapshot;

  /// No description provided for @allTasksDone.
  ///
  /// In en, this message translates to:
  /// **'All tasks completed today'**
  String get allTasksDone;

  /// No description provided for @recentActivity.
  ///
  /// In en, this message translates to:
  /// **'Recent Activity'**
  String get recentActivity;

  /// No description provided for @noReports.
  ///
  /// In en, this message translates to:
  /// **'No reports'**
  String get noReports;

  /// No description provided for @emergency.
  ///
  /// In en, this message translates to:
  /// **'Emergency'**
  String get emergency;

  /// No description provided for @lifeSavingAccess.
  ///
  /// In en, this message translates to:
  /// **'Life-saving Access'**
  String get lifeSavingAccess;

  /// No description provided for @vault.
  ///
  /// In en, this message translates to:
  /// **'Vault'**
  String get vault;

  /// No description provided for @policiesAndClaims.
  ///
  /// In en, this message translates to:
  /// **'Policies & Claims'**
  String get policiesAndClaims;

  /// No description provided for @me.
  ///
  /// In en, this message translates to:
  /// **'Me'**
  String get me;

  /// No description provided for @report.
  ///
  /// In en, this message translates to:
  /// **'REPORT'**
  String get report;

  /// No description provided for @healthTimeline.
  ///
  /// In en, this message translates to:
  /// **'Health Timeline'**
  String get healthTimeline;

  /// No description provided for @timelineSubtitle.
  ///
  /// In en, this message translates to:
  /// **'A chronological map of this member\'s health history.'**
  String get timelineSubtitle;

  /// No description provided for @searchReports.
  ///
  /// In en, this message translates to:
  /// **'Search reports, prescriptions...'**
  String get searchReports;

  /// No description provided for @noReportsUploaded.
  ///
  /// In en, this message translates to:
  /// **'No reports uploaded yet'**
  String get noReportsUploaded;

  /// No description provided for @defaultReport.
  ///
  /// In en, this message translates to:
  /// **'Report'**
  String get defaultReport;

  /// No description provided for @healthAnalytics.
  ///
  /// In en, this message translates to:
  /// **'Health Analytics'**
  String get healthAnalytics;

  /// No description provided for @analyticsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Track and visualize your body metrics.'**
  String get analyticsSubtitle;

  /// No description provided for @addMetric.
  ///
  /// In en, this message translates to:
  /// **'Add Metric'**
  String get addMetric;

  /// No description provided for @noMetrics.
  ///
  /// In en, this message translates to:
  /// **'No metrics yet'**
  String get noMetrics;

  /// No description provided for @addFirstMetric.
  ///
  /// In en, this message translates to:
  /// **'Add your first health metric'**
  String get addFirstMetric;

  /// No description provided for @normal.
  ///
  /// In en, this message translates to:
  /// **'NORMAL'**
  String get normal;

  /// No description provided for @high.
  ///
  /// In en, this message translates to:
  /// **'HIGH'**
  String get high;

  /// No description provided for @low.
  ///
  /// In en, this message translates to:
  /// **'LOW'**
  String get low;

  /// No description provided for @smartReminders.
  ///
  /// In en, this message translates to:
  /// **'Smart Reminders'**
  String get smartReminders;

  /// No description provided for @reminderSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your health schedule in one place.'**
  String get reminderSubtitle;

  /// No description provided for @addReminder.
  ///
  /// In en, this message translates to:
  /// **'Add Reminder'**
  String get addReminder;

  /// No description provided for @scheduleFor.
  ///
  /// In en, this message translates to:
  /// **'Schedule for'**
  String get scheduleFor;

  /// No description provided for @noReminders.
  ///
  /// In en, this message translates to:
  /// **'No reminders for this day'**
  String get noReminders;

  /// No description provided for @appointment.
  ///
  /// In en, this message translates to:
  /// **'Appointment'**
  String get appointment;

  /// No description provided for @labTest.
  ///
  /// In en, this message translates to:
  /// **'Lab Test'**
  String get labTest;

  /// No description provided for @medicine.
  ///
  /// In en, this message translates to:
  /// **'Medicine'**
  String get medicine;

  /// No description provided for @healthScheduleSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your health schedule in one place.'**
  String get healthScheduleSubtitle;

  /// No description provided for @addFamilyMember.
  ///
  /// In en, this message translates to:
  /// **'Add Family Member'**
  String get addFamilyMember;

  /// No description provided for @enterPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter phone number'**
  String get enterPhoneNumber;

  /// No description provided for @noUserWithPhone.
  ///
  /// In en, this message translates to:
  /// **'No user found with this phone number'**
  String get noUserWithPhone;

  /// No description provided for @phoneNumberExisting.
  ///
  /// In en, this message translates to:
  /// **'Phone Number (existing user)'**
  String get phoneNumberExisting;

  /// No description provided for @relation.
  ///
  /// In en, this message translates to:
  /// **'Relation'**
  String get relation;

  /// No description provided for @linkMember.
  ///
  /// In en, this message translates to:
  /// **'Link Member'**
  String get linkMember;

  /// No description provided for @father.
  ///
  /// In en, this message translates to:
  /// **'Father'**
  String get father;

  /// No description provided for @mother.
  ///
  /// In en, this message translates to:
  /// **'Mother'**
  String get mother;

  /// No description provided for @spouse.
  ///
  /// In en, this message translates to:
  /// **'Spouse'**
  String get spouse;

  /// No description provided for @child.
  ///
  /// In en, this message translates to:
  /// **'Child'**
  String get child;

  /// No description provided for @saveMetric.
  ///
  /// In en, this message translates to:
  /// **'Save Metric'**
  String get saveMetric;

  /// No description provided for @profileNotReady.
  ///
  /// In en, this message translates to:
  /// **'Profile not ready'**
  String get profileNotReady;

  /// No description provided for @metricSaveError.
  ///
  /// In en, this message translates to:
  /// **'Error saving metric'**
  String get metricSaveError;

  /// No description provided for @addInsurancePolicy.
  ///
  /// In en, this message translates to:
  /// **'Add Insurance Policy'**
  String get addInsurancePolicy;

  /// No description provided for @insuranceProvider.
  ///
  /// In en, this message translates to:
  /// **'Insurance Provider'**
  String get insuranceProvider;

  /// No description provided for @planName.
  ///
  /// In en, this message translates to:
  /// **'Plan Name'**
  String get planName;

  /// No description provided for @policyNumber.
  ///
  /// In en, this message translates to:
  /// **'Policy Number'**
  String get policyNumber;

  /// No description provided for @sumInsured.
  ///
  /// In en, this message translates to:
  /// **'Sum Insured'**
  String get sumInsured;

  /// No description provided for @annualPremium.
  ///
  /// In en, this message translates to:
  /// **'Annual Premium (₹)'**
  String get annualPremium;

  /// No description provided for @selectRenewalDate.
  ///
  /// In en, this message translates to:
  /// **'Select Renewal Date'**
  String get selectRenewalDate;

  /// No description provided for @savePolicy.
  ///
  /// In en, this message translates to:
  /// **'Save Policy'**
  String get savePolicy;

  /// No description provided for @fillAllFields.
  ///
  /// In en, this message translates to:
  /// **'Please fill all fields'**
  String get fillAllFields;

  /// No description provided for @enterReminderName.
  ///
  /// In en, this message translates to:
  /// **'Enter reminder name'**
  String get enterReminderName;

  /// No description provided for @saveReminder.
  ///
  /// In en, this message translates to:
  /// **'Save Reminder'**
  String get saveReminder;

  /// No description provided for @oneTime.
  ///
  /// In en, this message translates to:
  /// **'One Time'**
  String get oneTime;

  /// No description provided for @everyday.
  ///
  /// In en, this message translates to:
  /// **'Everyday'**
  String get everyday;

  /// No description provided for @customInterval.
  ///
  /// In en, this message translates to:
  /// **'Custom Interval'**
  String get customInterval;

  /// No description provided for @reminderTitle.
  ///
  /// In en, this message translates to:
  /// **'VEDIQLOG Reminder'**
  String get reminderTitle;

  /// No description provided for @stop.
  ///
  /// In en, this message translates to:
  /// **'STOP'**
  String get stop;

  /// No description provided for @emergencyAccess.
  ///
  /// In en, this message translates to:
  /// **'Emergency Access'**
  String get emergencyAccess;

  /// No description provided for @emergencyMedicalAccess.
  ///
  /// In en, this message translates to:
  /// **'Emergency Medical Access'**
  String get emergencyMedicalAccess;

  /// No description provided for @scanHealthData.
  ///
  /// In en, this message translates to:
  /// **'Scan to access critical health data'**
  String get scanHealthData;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// No description provided for @allergies.
  ///
  /// In en, this message translates to:
  /// **'Allergies'**
  String get allergies;

  /// No description provided for @conditions.
  ///
  /// In en, this message translates to:
  /// **'Conditions'**
  String get conditions;

  /// No description provided for @medications.
  ///
  /// In en, this message translates to:
  /// **'Medications'**
  String get medications;

  /// No description provided for @emergencyContact.
  ///
  /// In en, this message translates to:
  /// **'Emergency Contact'**
  String get emergencyContact;

  /// No description provided for @noneKnown.
  ///
  /// In en, this message translates to:
  /// **'None Known'**
  String get noneKnown;

  /// No description provided for @none.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get none;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @saveQr.
  ///
  /// In en, this message translates to:
  /// **'Save QR'**
  String get saveQr;

  /// No description provided for @emergencyAutoRefresh.
  ///
  /// In en, this message translates to:
  /// **'Emergency link auto-refreshes for safety'**
  String get emergencyAutoRefresh;

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'VEDIQLOG'**
  String get appTitle;

  /// No description provided for @appTagline.
  ///
  /// In en, this message translates to:
  /// **'UNLOCK YOUR HEALTH'**
  String get appTagline;

  /// No description provided for @welcomeBackTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome Back'**
  String get welcomeBackTitle;

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to access your vault.'**
  String get loginSubtitle;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @noAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get noAccount;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUp;

  /// No description provided for @secureEncrypted.
  ///
  /// In en, this message translates to:
  /// **'SECURE & ENCRYPTED'**
  String get secureEncrypted;

  /// No description provided for @unexpectedError.
  ///
  /// In en, this message translates to:
  /// **'Unexpected error'**
  String get unexpectedError;

  /// No description provided for @unlockHealth.
  ///
  /// In en, this message translates to:
  /// **'UNLOCK YOUR HEALTH'**
  String get unlockHealth;

  /// No description provided for @signInVault.
  ///
  /// In en, this message translates to:
  /// **'Sign in to access your vault.'**
  String get signInVault;

  /// No description provided for @addReading.
  ///
  /// In en, this message translates to:
  /// **'Add Reading'**
  String get addReading;

  /// No description provided for @enterValue.
  ///
  /// In en, this message translates to:
  /// **'Enter value'**
  String get enterValue;

  /// No description provided for @change.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get change;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @lastReadingOn.
  ///
  /// In en, this message translates to:
  /// **'Last reading on'**
  String get lastReadingOn;

  /// No description provided for @history.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get history;

  /// No description provided for @addNewReading.
  ///
  /// In en, this message translates to:
  /// **'Add New Reading'**
  String get addNewReading;

  /// No description provided for @reliableReminders.
  ///
  /// In en, this message translates to:
  /// **'Reliable Reminders'**
  String get reliableReminders;

  /// No description provided for @neverMissMedicines.
  ///
  /// In en, this message translates to:
  /// **'Never miss medicines'**
  String get neverMissMedicines;

  /// No description provided for @batteryOptimizationInfo.
  ///
  /// In en, this message translates to:
  /// **'Some phones delay alarms to save battery. Allow VEDIQLOG to run without restrictions so reminders always ring on time.'**
  String get batteryOptimizationInfo;

  /// No description provided for @thisEnsures.
  ///
  /// In en, this message translates to:
  /// **'This ensures:'**
  String get thisEnsures;

  /// No description provided for @remindersOnTime.
  ///
  /// In en, this message translates to:
  /// **'✓ Reminders ring on time'**
  String get remindersOnTime;

  /// No description provided for @medicinesNotMissed.
  ///
  /// In en, this message translates to:
  /// **'✓ Medicines are not missed'**
  String get medicinesNotMissed;

  /// No description provided for @healthSchedulesReliable.
  ///
  /// In en, this message translates to:
  /// **'✓ Health schedules stay reliable'**
  String get healthSchedulesReliable;

  /// No description provided for @continueSetup.
  ///
  /// In en, this message translates to:
  /// **'Continue Setup'**
  String get continueSetup;

  /// No description provided for @doLater.
  ///
  /// In en, this message translates to:
  /// **'Do this later'**
  String get doLater;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// No description provided for @joinVediqlog.
  ///
  /// In en, this message translates to:
  /// **'Join VEDIQLOG'**
  String get joinVediqlog;

  /// No description provided for @secureHealthRecords.
  ///
  /// In en, this message translates to:
  /// **'Secure health records for life'**
  String get secureHealthRecords;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNumber;

  /// No description provided for @alreadyAccountLogin.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? Login'**
  String get alreadyAccountLogin;

  /// No description provided for @allFieldsRequired.
  ///
  /// In en, this message translates to:
  /// **'All fields are required'**
  String get allFieldsRequired;

  /// No description provided for @signupFailed.
  ///
  /// In en, this message translates to:
  /// **'Signup failed'**
  String get signupFailed;

  /// No description provided for @uploadReport.
  ///
  /// In en, this message translates to:
  /// **'Upload Report'**
  String get uploadReport;

  /// No description provided for @uploadMedicalReport.
  ///
  /// In en, this message translates to:
  /// **'Upload Medical Report'**
  String get uploadMedicalReport;

  /// No description provided for @uploadFormats.
  ///
  /// In en, this message translates to:
  /// **'PDF, Images, Lab Reports, Prescriptions'**
  String get uploadFormats;

  /// No description provided for @pickUpload.
  ///
  /// In en, this message translates to:
  /// **'Pick File & Upload'**
  String get pickUpload;

  /// No description provided for @reportUploadedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Report uploaded successfully'**
  String get reportUploadedSuccess;

  /// No description provided for @uploadFailed.
  ///
  /// In en, this message translates to:
  /// **'Upload failed'**
  String get uploadFailed;

  /// No description provided for @fileReadFailed.
  ///
  /// In en, this message translates to:
  /// **'File read failed'**
  String get fileReadFailed;

  /// No description provided for @noActiveProfile.
  ///
  /// In en, this message translates to:
  /// **'No active profile selected'**
  String get noActiveProfile;

  /// No description provided for @uploadInfo.
  ///
  /// In en, this message translates to:
  /// **'Uploaded reports appear automatically in Timeline & Analytics.'**
  String get uploadInfo;

  /// No description provided for @secureVault.
  ///
  /// In en, this message translates to:
  /// **'Secure Vault'**
  String get secureVault;

  /// No description provided for @addPolicy.
  ///
  /// In en, this message translates to:
  /// **'Add Policy'**
  String get addPolicy;

  /// No description provided for @noPoliciesFound.
  ///
  /// In en, this message translates to:
  /// **'No Policies Found'**
  String get noPoliciesFound;

  /// No description provided for @storePoliciesSecure.
  ///
  /// In en, this message translates to:
  /// **'Store your insurance policies securely in your vault.'**
  String get storePoliciesSecure;

  /// No description provided for @addFirstPolicy.
  ///
  /// In en, this message translates to:
  /// **'Add First Policy'**
  String get addFirstPolicy;

  /// No description provided for @policyNo.
  ///
  /// In en, this message translates to:
  /// **'Policy No'**
  String get policyNo;

  /// No description provided for @premium.
  ///
  /// In en, this message translates to:
  /// **'Premium'**
  String get premium;

  /// No description provided for @renewal.
  ///
  /// In en, this message translates to:
  /// **'Renewal'**
  String get renewal;

  /// No description provided for @bloodSugar.
  ///
  /// In en, this message translates to:
  /// **'Blood Sugar'**
  String get bloodSugar;

  /// No description provided for @bloodPressure.
  ///
  /// In en, this message translates to:
  /// **'Blood Pressure'**
  String get bloodPressure;

  /// No description provided for @hemoglobin.
  ///
  /// In en, this message translates to:
  /// **'Hemoglobin'**
  String get hemoglobin;

  /// No description provided for @thyroid.
  ///
  /// In en, this message translates to:
  /// **'Thyroid (TSH)'**
  String get thyroid;

  /// No description provided for @activateMembership.
  ///
  /// In en, this message translates to:
  /// **'Activate Gold Membership'**
  String get activateMembership;

  /// No description provided for @upgradeMessage.
  ///
  /// In en, this message translates to:
  /// **'Tap to upgrade & unlock family features'**
  String get upgradeMessage;

  /// No description provided for @tapToEditProfile.
  ///
  /// In en, this message translates to:
  /// **'Tap to edit profile'**
  String get tapToEditProfile;

  /// No description provided for @accountSecurity.
  ///
  /// In en, this message translates to:
  /// **'Account & Security'**
  String get accountSecurity;

  /// No description provided for @legalPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Legal & Privacy'**
  String get legalPrivacy;

  /// No description provided for @helpSupport.
  ///
  /// In en, this message translates to:
  /// **'Help & Support'**
  String get helpSupport;

  /// No description provided for @dataManagement.
  ///
  /// In en, this message translates to:
  /// **'Data Management'**
  String get dataManagement;

  /// No description provided for @clearCache.
  ///
  /// In en, this message translates to:
  /// **'Clear Cache'**
  String get clearCache;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// No description provided for @selectDob.
  ///
  /// In en, this message translates to:
  /// **'Select DOB'**
  String get selectDob;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phone;

  /// No description provided for @heightCm.
  ///
  /// In en, this message translates to:
  /// **'Height (cm)'**
  String get heightCm;

  /// No description provided for @weightKg.
  ///
  /// In en, this message translates to:
  /// **'Weight (kg)'**
  String get weightKg;

  /// No description provided for @diabetic.
  ///
  /// In en, this message translates to:
  /// **'Diabetic'**
  String get diabetic;

  /// No description provided for @emergencyInformation.
  ///
  /// In en, this message translates to:
  /// **'Emergency Information'**
  String get emergencyInformation;

  /// No description provided for @medicalConditions.
  ///
  /// In en, this message translates to:
  /// **'Medical Conditions'**
  String get medicalConditions;

  /// No description provided for @emergencyContactNumber.
  ///
  /// In en, this message translates to:
  /// **'Emergency Contact Number'**
  String get emergencyContactNumber;

  /// No description provided for @saveProfile.
  ///
  /// In en, this message translates to:
  /// **'Save Profile'**
  String get saveProfile;

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

  /// No description provided for @gender.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get gender;

  /// No description provided for @logoutAllDevices.
  ///
  /// In en, this message translates to:
  /// **'Logout from all devices'**
  String get logoutAllDevices;

  /// No description provided for @logoutEverywhere.
  ///
  /// In en, this message translates to:
  /// **'Logout Everywhere'**
  String get logoutEverywhere;

  /// No description provided for @logoutAllDevicesMessage.
  ///
  /// In en, this message translates to:
  /// **'This will logout your account from all devices.'**
  String get logoutAllDevicesMessage;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @termsConditions.
  ///
  /// In en, this message translates to:
  /// **'Terms & Conditions'**
  String get termsConditions;

  /// No description provided for @dataUsagePolicy.
  ///
  /// In en, this message translates to:
  /// **'Data Usage Policy'**
  String get dataUsagePolicy;

  /// No description provided for @faqs.
  ///
  /// In en, this message translates to:
  /// **'FAQs'**
  String get faqs;

  /// No description provided for @faqUploadQuestion.
  ///
  /// In en, this message translates to:
  /// **'How do I upload reports?'**
  String get faqUploadQuestion;

  /// No description provided for @faqUploadAnswer.
  ///
  /// In en, this message translates to:
  /// **'Go to Reports tab and tap Upload.'**
  String get faqUploadAnswer;

  /// No description provided for @faqFamilyQuestion.
  ///
  /// In en, this message translates to:
  /// **'How do I add family members?'**
  String get faqFamilyQuestion;

  /// No description provided for @faqFamilyAnswer.
  ///
  /// In en, this message translates to:
  /// **'Open Profile → Family Management → Add member.'**
  String get faqFamilyAnswer;

  /// No description provided for @faqSecurityQuestion.
  ///
  /// In en, this message translates to:
  /// **'Is my data secure?'**
  String get faqSecurityQuestion;

  /// No description provided for @faqSecurityAnswer.
  ///
  /// In en, this message translates to:
  /// **'Yes, your data is securely stored.'**
  String get faqSecurityAnswer;

  /// No description provided for @contactSupport.
  ///
  /// In en, this message translates to:
  /// **'Contact Support'**
  String get contactSupport;

  /// No description provided for @needHelp.
  ///
  /// In en, this message translates to:
  /// **'Need help?'**
  String get needHelp;

  /// No description provided for @emailSupport.
  ///
  /// In en, this message translates to:
  /// **'Email us at: support@vediqlog.com'**
  String get emailSupport;

  /// No description provided for @responseTime.
  ///
  /// In en, this message translates to:
  /// **'Response time: within 24 hours'**
  String get responseTime;

  /// No description provided for @cacheCleared.
  ///
  /// In en, this message translates to:
  /// **'Cache cleared successfully'**
  String get cacheCleared;

  /// No description provided for @cacheDescription.
  ///
  /// In en, this message translates to:
  /// **'Clearing cache removes temporary stored data and may free storage space.'**
  String get cacheDescription;

  /// No description provided for @goldMember.
  ///
  /// In en, this message translates to:
  /// **'GOLD MEMBER'**
  String get goldMember;

  /// No description provided for @membershipId.
  ///
  /// In en, this message translates to:
  /// **'Membership ID'**
  String get membershipId;

  /// No description provided for @notActivated.
  ///
  /// In en, this message translates to:
  /// **'Not Activated'**
  String get notActivated;

  /// No description provided for @validTill.
  ///
  /// In en, this message translates to:
  /// **'Valid till'**
  String get validTill;

  /// No description provided for @ourServices.
  ///
  /// In en, this message translates to:
  /// **'Our Services'**
  String get ourServices;

  /// No description provided for @familyVault.
  ///
  /// In en, this message translates to:
  /// **'Family Vault'**
  String get familyVault;

  /// No description provided for @familyVaultDesc.
  ///
  /// In en, this message translates to:
  /// **'Manage up to 6 family members'**
  String get familyVaultDesc;

  /// No description provided for @emergencyGps.
  ///
  /// In en, this message translates to:
  /// **'Emergency GPS'**
  String get emergencyGps;

  /// No description provided for @emergencyGpsDesc.
  ///
  /// In en, this message translates to:
  /// **'Instant alerts during emergencies'**
  String get emergencyGpsDesc;

  /// No description provided for @aiInsights.
  ///
  /// In en, this message translates to:
  /// **'AI Health Insights'**
  String get aiInsights;

  /// No description provided for @aiInsightsDesc.
  ///
  /// In en, this message translates to:
  /// **'Unlimited report analysis'**
  String get aiInsightsDesc;

  /// No description provided for @monthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get monthly;

  /// No description provided for @yearly.
  ///
  /// In en, this message translates to:
  /// **'Yearly'**
  String get yearly;

  /// No description provided for @save15.
  ///
  /// In en, this message translates to:
  /// **'Save 15%'**
  String get save15;

  /// No description provided for @membershipActive.
  ///
  /// In en, this message translates to:
  /// **'Membership Active'**
  String get membershipActive;

  /// No description provided for @bestValue.
  ///
  /// In en, this message translates to:
  /// **'BEST VALUE'**
  String get bestValue;

  /// No description provided for @medicationReminders.
  ///
  /// In en, this message translates to:
  /// **'Medication reminders'**
  String get medicationReminders;

  /// No description provided for @appointments.
  ///
  /// In en, this message translates to:
  /// **'Appointments'**
  String get appointments;

  /// No description provided for @reportUpdates.
  ///
  /// In en, this message translates to:
  /// **'Reports updates'**
  String get reportUpdates;

  /// No description provided for @emergencyAlerts.
  ///
  /// In en, this message translates to:
  /// **'Emergency alerts'**
  String get emergencyAlerts;

  /// No description provided for @offersMarketing.
  ///
  /// In en, this message translates to:
  /// **'Offers & marketing'**
  String get offersMarketing;
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
      <String>['en', 'hi', 'kn', 'ta', 'te'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'hi':
      return AppLocalizationsHi();
    case 'kn':
      return AppLocalizationsKn();
    case 'ta':
      return AppLocalizationsTa();
    case 'te':
      return AppLocalizationsTe();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
