import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_mr.dart';

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
    Locale('mr')
  ];

  /// The name of the application
  ///
  /// In en, this message translates to:
  /// **'Mahakhanij'**
  String get appName;

  /// Label for language selection
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// Label for settings
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// Label for Home screen
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// Label for Profile screen
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// Welcome message
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get welcome;

  /// No description provided for @digitpDeliveries.
  ///
  /// In en, this message translates to:
  /// **'DigiTP\nDeliveries'**
  String get digitpDeliveries;

  /// No description provided for @receivedMaterial.
  ///
  /// In en, this message translates to:
  /// **'Received\nMaterial'**
  String get receivedMaterial;

  /// No description provided for @inTransitVehicles.
  ///
  /// In en, this message translates to:
  /// **'In Transit\nVehicles'**
  String get inTransitVehicles;

  /// No description provided for @coreServices.
  ///
  /// In en, this message translates to:
  /// **'CORE SERVICES'**
  String get coreServices;

  /// No description provided for @digitpPasses.
  ///
  /// In en, this message translates to:
  /// **'DigiTP\nPasses'**
  String get digitpPasses;

  /// No description provided for @receiveMaterialAction.
  ///
  /// In en, this message translates to:
  /// **'Receive\nMaterial'**
  String get receiveMaterialAction;

  /// No description provided for @trackVehicle.
  ///
  /// In en, this message translates to:
  /// **'Track\nVehicle'**
  String get trackVehicle;

  /// No description provided for @recentDeliveriesHeader.
  ///
  /// In en, this message translates to:
  /// **'DIGITP & MINERAL DELIVERIES'**
  String get recentDeliveriesHeader;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get viewAll;

  /// No description provided for @noRecentDeliveries.
  ///
  /// In en, this message translates to:
  /// **'No recent DigiTP deliveries found.'**
  String get noRecentDeliveries;

  /// No description provided for @receiveMaterial.
  ///
  /// In en, this message translates to:
  /// **'Receive Material'**
  String get receiveMaterial;

  /// No description provided for @receiveMaterialError.
  ///
  /// In en, this message translates to:
  /// **'Receive Material Error'**
  String get receiveMaterialError;

  /// No description provided for @scanDigiTp.
  ///
  /// In en, this message translates to:
  /// **'Scan DigiTP QR / Barcode'**
  String get scanDigiTp;

  /// No description provided for @pointCameraDescription.
  ///
  /// In en, this message translates to:
  /// **'Point camera at the driver\'s QR code or barcode to extract permit details and confirm material receipt.'**
  String get pointCameraDescription;

  /// No description provided for @openCameraScanner.
  ///
  /// In en, this message translates to:
  /// **'Open Camera Scanner'**
  String get openCameraScanner;

  /// No description provided for @enterInvoiceManually.
  ///
  /// In en, this message translates to:
  /// **'Enter Invoice Number Manually'**
  String get enterInvoiceManually;

  /// No description provided for @processingScan.
  ///
  /// In en, this message translates to:
  /// **'Processing Scan & Fetching Details...'**
  String get processingScan;

  /// No description provided for @decodingPermit.
  ///
  /// In en, this message translates to:
  /// **'Decoding permit payload and verifying with Mahakhanij Server'**
  String get decodingPermit;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @eTransitPassDetails.
  ///
  /// In en, this message translates to:
  /// **'E-TRANSIT PASS DETAILS'**
  String get eTransitPassDetails;

  /// No description provided for @invoiceHash.
  ///
  /// In en, this message translates to:
  /// **'Invoice #'**
  String get invoiceHash;

  /// No description provided for @vehicleNumber.
  ///
  /// In en, this message translates to:
  /// **'Vehicle Number'**
  String get vehicleNumber;

  /// No description provided for @ownerName.
  ///
  /// In en, this message translates to:
  /// **'Owner Name'**
  String get ownerName;

  /// No description provided for @ownerMobile.
  ///
  /// In en, this message translates to:
  /// **'Owner Mobile'**
  String get ownerMobile;

  /// No description provided for @driverDetails.
  ///
  /// In en, this message translates to:
  /// **'Driver Details'**
  String get driverDetails;

  /// No description provided for @materialAndQuantity.
  ///
  /// In en, this message translates to:
  /// **'Material & Quantity'**
  String get materialAndQuantity;

  /// No description provided for @destination.
  ///
  /// In en, this message translates to:
  /// **'Destination'**
  String get destination;

  /// No description provided for @distanceKm.
  ///
  /// In en, this message translates to:
  /// **'Distance (Km)'**
  String get distanceKm;

  /// No description provided for @validityFrom.
  ///
  /// In en, this message translates to:
  /// **'Validity From'**
  String get validityFrom;

  /// No description provided for @validityUpto.
  ///
  /// In en, this message translates to:
  /// **'Validity Upto'**
  String get validityUpto;

  /// No description provided for @confirmingReceipt.
  ///
  /// In en, this message translates to:
  /// **'Confirming Receipt...'**
  String get confirmingReceipt;

  /// No description provided for @confirmAndReceiveMaterial.
  ///
  /// In en, this message translates to:
  /// **'Confirm & Receive Material'**
  String get confirmAndReceiveMaterial;

  /// No description provided for @track.
  ///
  /// In en, this message translates to:
  /// **'Track'**
  String get track;

  /// No description provided for @fetchingLiveGpsLocation.
  ///
  /// In en, this message translates to:
  /// **'Fetching live GPS location for {vehicleNo}...'**
  String fetchingLiveGpsLocation(String vehicleNo);

  /// No description provided for @connectingToMahakhanij.
  ///
  /// In en, this message translates to:
  /// **'Connecting to Mahakhanij GPS Tracking Service'**
  String get connectingToMahakhanij;

  /// No description provided for @trackingDataUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Tracking Data Unavailable'**
  String get trackingDataUnavailable;

  /// No description provided for @retryFetching.
  ///
  /// In en, this message translates to:
  /// **'Retry Fetching'**
  String get retryFetching;

  /// No description provided for @tryDemoVehicle.
  ///
  /// In en, this message translates to:
  /// **'Try Demo Vehicle'**
  String get tryDemoVehicle;

  /// No description provided for @noLocationDataFor.
  ///
  /// In en, this message translates to:
  /// **'No Location Data for {vehicleNo}'**
  String noLocationDataFor(String vehicleNo);

  /// No description provided for @refreshLocation.
  ///
  /// In en, this message translates to:
  /// **'Refresh Location'**
  String get refreshLocation;

  /// No description provided for @inTransit.
  ///
  /// In en, this message translates to:
  /// **'In Transit'**
  String get inTransit;

  /// No description provided for @delivered.
  ///
  /// In en, this message translates to:
  /// **'Delivered'**
  String get delivered;

  /// No description provided for @enquiries.
  ///
  /// In en, this message translates to:
  /// **'Enquiries'**
  String get enquiries;

  /// No description provided for @noActiveDeliveries.
  ///
  /// In en, this message translates to:
  /// **'No Active Deliveries'**
  String get noActiveDeliveries;

  /// No description provided for @noDeliveriesInTransitDesc.
  ///
  /// In en, this message translates to:
  /// **'There are currently no deliveries in transit.'**
  String get noDeliveriesInTransitDesc;

  /// No description provided for @noDeliveredItems.
  ///
  /// In en, this message translates to:
  /// **'No Delivered Items'**
  String get noDeliveredItems;

  /// No description provided for @noDeliveriesReceivedDesc.
  ///
  /// In en, this message translates to:
  /// **'You have not received any deliveries yet.'**
  String get noDeliveriesReceivedDesc;

  /// No description provided for @noActiveEnquiries.
  ///
  /// In en, this message translates to:
  /// **'No Active Enquiries'**
  String get noActiveEnquiries;

  /// No description provided for @noActiveEnquiriesDesc.
  ///
  /// In en, this message translates to:
  /// **'There are currently no active enquiries.'**
  String get noActiveEnquiriesDesc;

  /// No description provided for @source.
  ///
  /// In en, this message translates to:
  /// **'Source'**
  String get source;

  /// No description provided for @validity.
  ///
  /// In en, this message translates to:
  /// **'Validity'**
  String get validity;

  /// No description provided for @viewDigiTp.
  ///
  /// In en, this message translates to:
  /// **'View DigiTP'**
  String get viewDigiTp;

  /// No description provided for @cancelEnquiry.
  ///
  /// In en, this message translates to:
  /// **'Cancel Enquiry'**
  String get cancelEnquiry;

  /// No description provided for @cancelling.
  ///
  /// In en, this message translates to:
  /// **'Cancelling...'**
  String get cancelling;

  /// No description provided for @activityTab.
  ///
  /// In en, this message translates to:
  /// **'DigiTP'**
  String get activityTab;

  /// No description provided for @mineral.
  ///
  /// In en, this message translates to:
  /// **'Mineral'**
  String get mineral;

  /// No description provided for @qty.
  ///
  /// In en, this message translates to:
  /// **'Qty'**
  String get qty;

  /// No description provided for @vehicle.
  ///
  /// In en, this message translates to:
  /// **'Vehicle'**
  String get vehicle;

  /// No description provided for @driver.
  ///
  /// In en, this message translates to:
  /// **'Driver'**
  String get driver;

  /// No description provided for @quarrySeller.
  ///
  /// In en, this message translates to:
  /// **'Quarry / Seller'**
  String get quarrySeller;

  /// No description provided for @digiTpNo.
  ///
  /// In en, this message translates to:
  /// **'DigiTP No'**
  String get digiTpNo;

  /// No description provided for @vehicleDriverName.
  ///
  /// In en, this message translates to:
  /// **'Vehicle Driver Name'**
  String get vehicleDriverName;

  /// No description provided for @driverMobileNumber.
  ///
  /// In en, this message translates to:
  /// **'Driver Mobile Number'**
  String get driverMobileNumber;

  /// No description provided for @ownerMobileNumber.
  ///
  /// In en, this message translates to:
  /// **'Owner Mobile Number'**
  String get ownerMobileNumber;

  /// No description provided for @plotProjectName.
  ///
  /// In en, this message translates to:
  /// **'Plot / Project Name'**
  String get plotProjectName;

  /// No description provided for @invoiceStatus.
  ///
  /// In en, this message translates to:
  /// **'Invoice Status'**
  String get invoiceStatus;

  /// No description provided for @createdDateAndTimeOfDigiTp.
  ///
  /// In en, this message translates to:
  /// **'Created date and time of DigiTP'**
  String get createdDateAndTimeOfDigiTp;

  /// No description provided for @digiTpValidityDateAndTime.
  ///
  /// In en, this message translates to:
  /// **'DigiTP validity date and time'**
  String get digiTpValidityDateAndTime;

  /// No description provided for @profileName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get profileName;

  /// No description provided for @profileMobile.
  ///
  /// In en, this message translates to:
  /// **'Mobile No.'**
  String get profileMobile;

  /// No description provided for @profileEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get profileEmail;

  /// No description provided for @profileAddress.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get profileAddress;

  /// No description provided for @profileDistrict.
  ///
  /// In en, this message translates to:
  /// **'District'**
  String get profileDistrict;

  /// No description provided for @profileTaluka.
  ///
  /// In en, this message translates to:
  /// **'Taluka'**
  String get profileTaluka;

  /// No description provided for @profileCityVillage.
  ///
  /// In en, this message translates to:
  /// **'City / Village'**
  String get profileCityVillage;

  /// No description provided for @profilePincode.
  ///
  /// In en, this message translates to:
  /// **'Pincode'**
  String get profilePincode;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get saveChanges;

  /// No description provided for @aadhaarKyc.
  ///
  /// In en, this message translates to:
  /// **'Aadhaar KYC'**
  String get aadhaarKyc;

  /// No description provided for @verifyAadhaar.
  ///
  /// In en, this message translates to:
  /// **'Verify Aadhaar'**
  String get verifyAadhaar;

  /// No description provided for @uploadDocument.
  ///
  /// In en, this message translates to:
  /// **'Upload Document'**
  String get uploadDocument;

  /// No description provided for @viewDocument.
  ///
  /// In en, this message translates to:
  /// **'View Document'**
  String get viewDocument;

  /// No description provided for @aadhaarVerified.
  ///
  /// In en, this message translates to:
  /// **'Verified'**
  String get aadhaarVerified;

  /// No description provided for @aadhaarPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get aadhaarPending;

  /// No description provided for @rural.
  ///
  /// In en, this message translates to:
  /// **'Rural'**
  String get rural;

  /// No description provided for @urban.
  ///
  /// In en, this message translates to:
  /// **'Urban'**
  String get urban;

  /// No description provided for @residentialDetails.
  ///
  /// In en, this message translates to:
  /// **'Residential Details'**
  String get residentialDetails;

  /// No description provided for @personalDetails.
  ///
  /// In en, this message translates to:
  /// **'Personal Details'**
  String get personalDetails;

  /// No description provided for @liveVehicleTracking.
  ///
  /// In en, this message translates to:
  /// **'Live Vehicle Tracking'**
  String get liveVehicleTracking;

  /// No description provided for @liveGps.
  ///
  /// In en, this message translates to:
  /// **'Live GPS'**
  String get liveGps;

  /// No description provided for @currentGpsLocation.
  ///
  /// In en, this message translates to:
  /// **'CURRENT GPS LOCATION'**
  String get currentGpsLocation;

  /// No description provided for @trackingLiveGps.
  ///
  /// In en, this message translates to:
  /// **'Tracking Live GPS'**
  String get trackingLiveGps;

  /// No description provided for @speed.
  ///
  /// In en, this message translates to:
  /// **'Speed'**
  String get speed;

  /// No description provided for @lastUpdated.
  ///
  /// In en, this message translates to:
  /// **'Last updated'**
  String get lastUpdated;

  /// No description provided for @tripDetails.
  ///
  /// In en, this message translates to:
  /// **'Trip Details'**
  String get tripDetails;

  /// No description provided for @tripId.
  ///
  /// In en, this message translates to:
  /// **'Trip ID'**
  String get tripId;

  /// No description provided for @originQuarryPlot.
  ///
  /// In en, this message translates to:
  /// **'Origin / Quarry Plot'**
  String get originQuarryPlot;

  /// No description provided for @destinationSite.
  ///
  /// In en, this message translates to:
  /// **'Destination Site'**
  String get destinationSite;

  /// No description provided for @totalDistance.
  ///
  /// In en, this message translates to:
  /// **'Total Distance'**
  String get totalDistance;

  /// No description provided for @validFrom.
  ///
  /// In en, this message translates to:
  /// **'Valid From'**
  String get validFrom;

  /// No description provided for @validUpto.
  ///
  /// In en, this message translates to:
  /// **'Valid Upto'**
  String get validUpto;

  /// No description provided for @noActiveDigiTpTripDetails.
  ///
  /// In en, this message translates to:
  /// **'No active DigiTP trip details associated with this vehicle at the moment.'**
  String get noActiveDigiTpTripDetails;

  /// No description provided for @mobileNumberUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Mobile number unavailable'**
  String get mobileNumberUnavailable;

  /// No description provided for @enterVehicleNo.
  ///
  /// In en, this message translates to:
  /// **'Enter Vehicle No'**
  String get enterVehicleNo;

  /// No description provided for @enterDigiTpNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter DigiTP Number'**
  String get enterDigiTpNumber;

  /// No description provided for @enterDigiTpNumberHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. 491 or 0436610'**
  String get enterDigiTpNumberHint;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @fetchDetails.
  ///
  /// In en, this message translates to:
  /// **'Fetch Details'**
  String get fetchDetails;

  /// No description provided for @scanAnotherCode.
  ///
  /// In en, this message translates to:
  /// **'Scan Another Code'**
  String get scanAnotherCode;

  /// No description provided for @viewAllReceivedDeliveries.
  ///
  /// In en, this message translates to:
  /// **'View All Received Deliveries'**
  String get viewAllReceivedDeliveries;

  /// No description provided for @materialReceivedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Material Received Successfully!'**
  String get materialReceivedSuccess;

  /// No description provided for @revenueDeptMsg.
  ///
  /// In en, this message translates to:
  /// **'Revenue Department, Government of Maharashtra'**
  String get revenueDeptMsg;

  /// No description provided for @welcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Mineral, from source to site'**
  String get welcomeTitle;

  /// No description provided for @welcomeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Find a mineral place, raise an enquiry, track the vehicle, verify what arrives, and manage what you use.'**
  String get welcomeSubtitle;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signIn;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get createAccount;

  /// No description provided for @loginHeading.
  ///
  /// In en, this message translates to:
  /// **'LOGIN'**
  String get loginHeading;

  /// No description provided for @mobileNumberHint.
  ///
  /// In en, this message translates to:
  /// **'Mobile Number'**
  String get mobileNumberHint;

  /// No description provided for @waitSeconds.
  ///
  /// In en, this message translates to:
  /// **'Please wait {seconds} Seconds'**
  String waitSeconds(String seconds);

  /// No description provided for @resendOtp.
  ///
  /// In en, this message translates to:
  /// **'Resend OTP'**
  String get resendOtp;

  /// No description provided for @invalidMobileError.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid 10-digit Indian mobile number.'**
  String get invalidMobileError;

  /// No description provided for @invalidOtpError.
  ///
  /// In en, this message translates to:
  /// **'Please enter complete 5-digit OTP.'**
  String get invalidOtpError;

  /// No description provided for @getOtpBtn.
  ///
  /// In en, this message translates to:
  /// **'Get OTP'**
  String get getOtpBtn;

  /// No description provided for @loginBtn.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get loginBtn;

  /// No description provided for @newMemberMsg.
  ///
  /// In en, this message translates to:
  /// **'New Member? '**
  String get newMemberMsg;

  /// No description provided for @signUpLink.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUpLink;

  /// No description provided for @chooseAccountType.
  ///
  /// In en, this message translates to:
  /// **'Choose Account Type'**
  String get chooseAccountType;

  /// No description provided for @howWillYouUse.
  ///
  /// In en, this message translates to:
  /// **'How will you use Mahakhanij?'**
  String get howWillYouUse;

  /// No description provided for @chooseAccountDesc.
  ///
  /// In en, this message translates to:
  /// **'This decides what the app shows you. It cannot be changed later.'**
  String get chooseAccountDesc;

  /// No description provided for @individual.
  ///
  /// In en, this message translates to:
  /// **'Individual'**
  String get individual;

  /// No description provided for @individualDesc.
  ///
  /// In en, this message translates to:
  /// **'For an individual buying mineral for personal use.'**
  String get individualDesc;

  /// No description provided for @organization.
  ///
  /// In en, this message translates to:
  /// **'Organization'**
  String get organization;

  /// No description provided for @organizationDesc.
  ///
  /// In en, this message translates to:
  /// **'For a builder, contractor, government body or any other organization working across projects and packages.'**
  String get organizationDesc;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? '**
  String get alreadyHaveAccount;

  /// No description provided for @basicAndAddressDetails.
  ///
  /// In en, this message translates to:
  /// **'Basic & Address details'**
  String get basicAndAddressDetails;

  /// No description provided for @enterPersonalContact.
  ///
  /// In en, this message translates to:
  /// **'Enter your personal contact and delivery destination details.'**
  String get enterPersonalContact;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get fullName;

  /// No description provided for @mobileNumber.
  ///
  /// In en, this message translates to:
  /// **'Mobile number'**
  String get mobileNumber;

  /// No description provided for @tenDigitNumber.
  ///
  /// In en, this message translates to:
  /// **'10-digit number'**
  String get tenDigitNumber;

  /// No description provided for @weWillSendVerification.
  ///
  /// In en, this message translates to:
  /// **'We will send a 5-digit verification code to this number.'**
  String get weWillSendVerification;

  /// No description provided for @orgNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Organization name'**
  String get orgNameLabel;

  /// No description provided for @orgTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Organization type'**
  String get orgTypeLabel;

  /// No description provided for @gstinLabel.
  ///
  /// In en, this message translates to:
  /// **'GSTIN'**
  String get gstinLabel;

  /// No description provided for @continueBtn.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueBtn;

  /// No description provided for @continueToKyc.
  ///
  /// In en, this message translates to:
  /// **'Continue to KYC Verification'**
  String get continueToKyc;

  /// No description provided for @completeRegistration.
  ///
  /// In en, this message translates to:
  /// **'Complete Registration'**
  String get completeRegistration;

  /// No description provided for @skipAadhaar.
  ///
  /// In en, this message translates to:
  /// **'Skip Aadhaar Verification & Complete Signup'**
  String get skipAadhaar;

  /// No description provided for @stepOf.
  ///
  /// In en, this message translates to:
  /// **'Step {step} of {total}'**
  String stepOf(int step, int total);

  /// No description provided for @personaIndividualDesc.
  ///
  /// In en, this message translates to:
  /// **'Personal & Home Construction'**
  String get personaIndividualDesc;

  /// No description provided for @personaOrganizationDesc.
  ///
  /// In en, this message translates to:
  /// **'Infrastructure & Commercial Projects'**
  String get personaOrganizationDesc;

  /// No description provided for @whereDeliverMineral.
  ///
  /// In en, this message translates to:
  /// **'WHERE SHOULD MINERAL BE DELIVERED?'**
  String get whereDeliverMineral;

  /// No description provided for @areaClassificationLabel.
  ///
  /// In en, this message translates to:
  /// **'Area Classification'**
  String get areaClassificationLabel;

  /// No description provided for @urbanCity.
  ///
  /// In en, this message translates to:
  /// **'Urban (City)'**
  String get urbanCity;

  /// No description provided for @ruralVillage.
  ///
  /// In en, this message translates to:
  /// **'Rural (Village)'**
  String get ruralVillage;

  /// No description provided for @districtLabel.
  ///
  /// In en, this message translates to:
  /// **'District *'**
  String get districtLabel;

  /// No description provided for @selectDistrictHint.
  ///
  /// In en, this message translates to:
  /// **'Select District'**
  String get selectDistrictHint;

  /// No description provided for @loadingDistricts.
  ///
  /// In en, this message translates to:
  /// **'Loading Districts...'**
  String get loadingDistricts;

  /// No description provided for @talukaLabel.
  ///
  /// In en, this message translates to:
  /// **'Taluka *'**
  String get talukaLabel;

  /// No description provided for @talukaHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Haveli'**
  String get talukaHint;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @cityCorporationLabel.
  ///
  /// In en, this message translates to:
  /// **'City / Corporation'**
  String get cityCorporationLabel;

  /// No description provided for @villageRuralLabel.
  ///
  /// In en, this message translates to:
  /// **'Village / Rural Area'**
  String get villageRuralLabel;

  /// No description provided for @cityCorporationHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Pune City (PMC)'**
  String get cityCorporationHint;

  /// No description provided for @villageRuralHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Narayangaon'**
  String get villageRuralHint;

  /// No description provided for @addressLabel.
  ///
  /// In en, this message translates to:
  /// **'Address (House / Flat / Street / Area)'**
  String get addressLabel;

  /// No description provided for @addressHint.
  ///
  /// In en, this message translates to:
  /// **'Plot / House No., Building, Area / Road'**
  String get addressHint;

  /// No description provided for @pincodeLabel.
  ///
  /// In en, this message translates to:
  /// **'PIN code'**
  String get pincodeLabel;

  /// No description provided for @pincodeHint.
  ///
  /// In en, this message translates to:
  /// **'6-digit PIN code'**
  String get pincodeHint;

  /// No description provided for @profileScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Consumer Profile & KYC'**
  String get profileScreenTitle;

  /// No description provided for @settingsScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsScreenTitle;
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
      <String>['en', 'hi', 'mr'].contains(locale.languageCode);

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
    case 'mr':
      return AppLocalizationsMr();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
