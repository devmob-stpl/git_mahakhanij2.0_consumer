// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Mahakhanij';

  @override
  String get language => 'Language';

  @override
  String get settings => 'Settings';

  @override
  String get home => 'Home';

  @override
  String get profile => 'Profile';

  @override
  String get welcome => 'Welcome';

  @override
  String get digitpDeliveries => 'DigiTPs\nIssued';

  @override
  String get receivedMaterial => 'DigiTPs\nReceived';

  @override
  String get inTransitVehicles => 'Vehicles\nIn Transit';

  @override
  String get coreServices => 'CORE SERVICES';

  @override
  String get digitpPasses => 'DigiTP\nPasses';

  @override
  String get receiveMaterialAction => 'Receive\nMaterial';

  @override
  String get trackVehicle => 'Track\nVehicle';

  @override
  String get recentDeliveriesHeader => 'DIGITP & MINERAL DELIVERIES';

  @override
  String get viewAll => 'View All';

  @override
  String get noRecentDeliveries => 'No recent DigiTP deliveries found.';

  @override
  String get receiveMaterial => 'Receive Material';

  @override
  String get receiveMaterialError => 'Receive Material Error';

  @override
  String get scanDigiTp => 'Scan DigiTP QR / Barcode';

  @override
  String get pointCameraDescription =>
      'Point camera at the driver\'s QR code or barcode to extract permit details and confirm material receipt.';

  @override
  String get openCameraScanner => 'Open Camera Scanner';

  @override
  String get enterInvoiceManually => 'Enter Invoice Number Manually';

  @override
  String get processingScan => 'Processing Scan & Fetching Details...';

  @override
  String get decodingPermit =>
      'Decoding permit payload and verifying with Mahakhanij Server';

  @override
  String get ok => 'OK';

  @override
  String get eTransitPassDetails => 'E-TRANSIT PASS DETAILS';

  @override
  String get invoiceHash => 'Invoice #';

  @override
  String get vehicleNumber => 'Vehicle Number';

  @override
  String get ownerName => 'Owner Name';

  @override
  String get ownerMobile => 'Owner Mobile';

  @override
  String get driverDetails => 'Driver Details';

  @override
  String get materialAndQuantity => 'Material & Quantity';

  @override
  String get destination => 'Destination';

  @override
  String get distanceKm => 'Distance (Km)';

  @override
  String get validityFrom => 'Validity From';

  @override
  String get validityUpto => 'Validity Upto';

  @override
  String get confirmingReceipt => 'Confirming Receipt...';

  @override
  String get confirmAndReceiveMaterial => 'Confirm & Receive Material';

  @override
  String get track => 'Track';

  @override
  String fetchingLiveGpsLocation(String vehicleNo) {
    return 'Fetching live GPS location for $vehicleNo...';
  }

  @override
  String get connectingToMahakhanij =>
      'Connecting to Mahakhanij GPS Tracking Service';

  @override
  String get trackingDataUnavailable => 'Tracking Data Unavailable';

  @override
  String get retryFetching => 'Retry Fetching';

  @override
  String get tryDemoVehicle => 'Try Demo Vehicle';

  @override
  String noLocationDataFor(String vehicleNo) {
    return 'No Location Data for $vehicleNo';
  }

  @override
  String get refreshLocation => 'Refresh Location';

  @override
  String get inTransit => 'In Transit';

  @override
  String get delivered => 'Delivered';

  @override
  String get enquiries => 'Enquiries';

  @override
  String get noActiveDeliveries => 'No Active Deliveries';

  @override
  String get noDeliveriesInTransitDesc =>
      'There are currently no deliveries in transit.';

  @override
  String get noDeliveredItems => 'No Delivered Items';

  @override
  String get noDeliveriesReceivedDesc =>
      'You have not received any deliveries yet.';

  @override
  String get noActiveEnquiries => 'No Active Enquiries';

  @override
  String get noActiveEnquiriesDesc =>
      'There are currently no active enquiries.';

  @override
  String get source => 'Source';

  @override
  String get validity => 'Validity';

  @override
  String get viewDigiTp => 'View DigiTP';

  @override
  String get cancelEnquiry => 'Cancel Enquiry';

  @override
  String get cancelling => 'Cancelling...';

  @override
  String get activityTab => 'DigiTP';

  @override
  String get mineral => 'Mineral';

  @override
  String get qty => 'Qty';

  @override
  String get vehicle => 'Vehicle';

  @override
  String get driver => 'Driver';

  @override
  String get quarrySeller => 'Quarry / Seller';

  @override
  String get digiTpNo => 'DigiTP No';

  @override
  String get vehicleDriverName => 'Vehicle Driver Name';

  @override
  String get driverMobileNumber => 'Driver Mobile Number';

  @override
  String get ownerMobileNumber => 'Owner Mobile Number';

  @override
  String get plotProjectName => 'Plot / Project Name';

  @override
  String get invoiceStatus => 'Invoice Status';

  @override
  String get createdDateAndTimeOfDigiTp => 'Created date and time of DigiTP';

  @override
  String get digiTpValidityDateAndTime => 'DigiTP validity date and time';

  @override
  String get profileName => 'Name';

  @override
  String get profileMobile => 'Mobile No.';

  @override
  String get profileEmail => 'Email';

  @override
  String get profileAddress => 'Address';

  @override
  String get profileDistrict => 'District';

  @override
  String get profileTaluka => 'Taluka';

  @override
  String get profileCityVillage => 'City / Village';

  @override
  String get profilePincode => 'Pincode';

  @override
  String get saveChanges => 'Save Changes';

  @override
  String get aadhaarKyc => 'Aadhaar KYC';

  @override
  String get verifyAadhaar => 'Verify Aadhaar';

  @override
  String get uploadDocument => 'Upload Document';

  @override
  String get viewDocument => 'View Document';

  @override
  String get aadhaarVerified => 'Verified';

  @override
  String get aadhaarPending => 'Pending';

  @override
  String get rural => 'Rural';

  @override
  String get urban => 'Urban';

  @override
  String get residentialDetails => 'Residential Details';

  @override
  String get personalDetails => 'Personal Details';

  @override
  String get liveVehicleTracking => 'Live Vehicle Tracking';

  @override
  String get liveGps => 'Live GPS';

  @override
  String get currentGpsLocation => 'CURRENT GPS LOCATION';

  @override
  String get trackingLiveGps => 'Tracking Live GPS';

  @override
  String get speed => 'Speed';

  @override
  String get lastUpdated => 'Last updated';

  @override
  String get tripDetails => 'Trip Details';

  @override
  String get tripId => 'Trip ID';

  @override
  String get originQuarryPlot => 'Origin / Quarry Plot';

  @override
  String get destinationSite => 'Destination Site';

  @override
  String get totalDistance => 'Total Distance';

  @override
  String get validFrom => 'Valid From';

  @override
  String get validUpto => 'Valid Upto';

  @override
  String get noActiveDigiTpTripDetails =>
      'No active DigiTP trip details associated with this vehicle at the moment.';

  @override
  String get mobileNumberUnavailable => 'Mobile number unavailable';

  @override
  String get enterVehicleNo => 'Enter Vehicle No';

  @override
  String get enterDigiTpNumber => 'Enter DigiTP Number';

  @override
  String get enterDigiTpNumberHint => 'e.g. 491 or 0436610';

  @override
  String get cancel => 'Cancel';

  @override
  String get fetchDetails => 'Fetch Details';

  @override
  String get scanAnotherCode => 'Scan Another Code';

  @override
  String get viewAllReceivedDeliveries => 'View All Received Deliveries';

  @override
  String get materialReceivedSuccess => 'Material Received Successfully!';

  @override
  String get revenueDeptMsg => 'Revenue Department, Government of Maharashtra';

  @override
  String get welcomeTitle => 'Mineral, from source to site';

  @override
  String get welcomeSubtitle =>
      'Find a mineral place, raise an enquiry, track the vehicle, verify what arrives, and manage what you use.';

  @override
  String get signIn => 'Sign in';

  @override
  String get createAccount => 'Create account';

  @override
  String get loginHeading => 'LOGIN';

  @override
  String get mobileNumberHint => 'Mobile Number';

  @override
  String waitSeconds(String seconds) {
    return 'Please wait $seconds Seconds';
  }

  @override
  String get resendOtp => 'Resend OTP';

  @override
  String get invalidMobileError =>
      'Enter a valid 10-digit Indian mobile number.';

  @override
  String get invalidOtpError => 'Please enter complete 5-digit OTP.';

  @override
  String get getOtpBtn => 'Get OTP';

  @override
  String get loginBtn => 'Login';

  @override
  String get newMemberMsg => 'New Member? ';

  @override
  String get signUpLink => 'Sign Up';

  @override
  String get chooseAccountType => 'Choose Account Type';

  @override
  String get howWillYouUse => 'How will you use Mahakhanij?';

  @override
  String get chooseAccountDesc =>
      'This decides what the app shows you. It cannot be changed later.';

  @override
  String get individual => 'Individual';

  @override
  String get individualDesc =>
      'For an individual buying mineral for personal use.';

  @override
  String get organization => 'Organization';

  @override
  String get organizationDesc =>
      'For a builder, contractor, government body or any other organization working across projects and packages.';

  @override
  String get alreadyHaveAccount => 'Already have an account? ';

  @override
  String get basicAndAddressDetails => 'Basic & Address details';

  @override
  String get enterPersonalContact =>
      'Enter your personal contact and delivery destination details.';

  @override
  String get fullName => 'Full name';

  @override
  String get mobileNumber => 'Mobile number';

  @override
  String get tenDigitNumber => '10-digit number';

  @override
  String get weWillSendVerification =>
      'We will send a 5-digit verification code to this number.';

  @override
  String get orgNameLabel => 'Organization name';

  @override
  String get orgTypeLabel => 'Organization type';

  @override
  String get gstinLabel => 'GSTIN';

  @override
  String get continueBtn => 'Continue';

  @override
  String get continueToKyc => 'Continue to KYC Verification';

  @override
  String get completeRegistration => 'Complete Registration';

  @override
  String get skipAadhaar => 'Skip Aadhaar Verification & Complete Signup';

  @override
  String stepOf(int step, int total) {
    return 'Step $step of $total';
  }

  @override
  String get personaIndividualDesc => 'Personal & Home Construction';

  @override
  String get personaOrganizationDesc => 'Infrastructure & Commercial Projects';

  @override
  String get whereDeliverMineral => 'WHERE SHOULD MINERAL BE DELIVERED?';

  @override
  String get areaClassificationLabel => 'Area Classification';

  @override
  String get urbanCity => 'Urban (City)';

  @override
  String get ruralVillage => 'Rural (Village)';

  @override
  String get districtLabel => 'District *';

  @override
  String get selectDistrictHint => 'Select District';

  @override
  String get loadingDistricts => 'Loading Districts...';

  @override
  String get talukaLabel => 'Taluka *';

  @override
  String get talukaHint => 'e.g. Haveli';

  @override
  String get loading => 'Loading...';

  @override
  String get cityCorporationLabel => 'City / Corporation';

  @override
  String get villageRuralLabel => 'Village / Rural Area';

  @override
  String get cityCorporationHint => 'e.g. Pune City (PMC)';

  @override
  String get villageRuralHint => 'e.g. Narayangaon';

  @override
  String get addressLabel => 'Address (House / Flat / Street / Area)';

  @override
  String get addressHint => 'Plot / House No., Building, Area / Road';

  @override
  String get pincodeLabel => 'PIN code';

  @override
  String get pincodeHint => '6-digit PIN code';

  @override
  String get profileScreenTitle => 'Consumer Profile & KYC';

  @override
  String get settingsScreenTitle => 'Settings';

  @override
  String get cameraBtn => 'Camera';

  @override
  String get galleryBtn => 'Gallery';

  @override
  String get fileDocumentBtn => 'File Document';

  @override
  String get aadhaarEkycInfoTitle => 'Aadhaar e-KYC Information';

  @override
  String get aadhaarNumberLabel => 'Aadhaar Number';

  @override
  String get aadhaarVerificationLabel => 'Aadhaar Verification';

  @override
  String get aadhaarDocumentUrlLabel => 'Aadhaar Document URL';

  @override
  String get closeBtn => 'Close';

  @override
  String get verifyAadhaarBtn => 'Verify Aadhaar';

  @override
  String get aadhaarIdentityVerificationTitle =>
      'Aadhaar Identity Verification';

  @override
  String get aadhaarIdentityVerificationDesc =>
      'Verify your Aadhaar OTP or upload document photo';

  @override
  String get method1LiveOtp => 'Method 1: Live OTP Verification';

  @override
  String get twelveDigitAadhaarNumber => '12-Digit Aadhaar Number *';

  @override
  String get enterTwelveDigitAadhaar => 'Enter 12 digit Aadhaar';

  @override
  String get sendOtpBtn => 'Send OTP';

  @override
  String get sixDigitAadhaarOtp => '6-Digit Aadhaar OTP *';

  @override
  String get enterSixDigitOtp => 'Enter 6 digit OTP';

  @override
  String get verifyOtpBtn => 'Verify OTP';

  @override
  String get method2UploadAadhaar =>
      'Method 2: Upload Aadhaar Card Document (PDF / Image)';

  @override
  String get uploadAadhaarDesc =>
      'Select document file to upload via Mahakhanij document server';

  @override
  String get chooseAadhaarPdfOrImage => 'Choose Aadhaar PDF or Image';

  @override
  String get uploadingToMahakhanijServer => 'Uploading to Mahakhanij server...';

  @override
  String get replaceBtn => 'Replace';

  @override
  String get uploadBtn => 'Upload';

  @override
  String get retryBtn => 'Retry';

  @override
  String get aadhaarVerificationCompleted => 'Aadhaar Verification Completed!';

  @override
  String get aadhaarVerificationSuccessDesc =>
      'Aadhaar credentials verified successfully with Government of Maharashtra.';

  @override
  String get doneBtn => 'Done';

  @override
  String get reports => 'Reports';

  @override
  String get last30Days => 'Last 30 Days';

  @override
  String get quarterly => 'Quarterly';

  @override
  String get fy2425 => 'FY 24-25';

  @override
  String get filterByQuarry => 'FILTER BY QUARRY (PARTY)';

  @override
  String get allQuarries => 'All Quarries';

  @override
  String get errorLoadingPlots => 'Error loading plots';

  @override
  String get noDataAvailable => 'No data available';

  @override
  String get totalReceived => 'Total Received';

  @override
  String get digitpsReceived => 'DigiTPs Received';

  @override
  String get passes => 'Passes';

  @override
  String get mineralProcurementBreakdown => 'MINERAL PROCUREMENT BREAKDOWN';

  @override
  String get byVolume => 'By volume';

  @override
  String get noMaterialsFound => 'No materials found';

  @override
  String get errorLoadingReport => 'Error loading report: ';

  @override
  String get units => 'Units';

  @override
  String get notReceived => 'Not Received';

  @override
  String get all => 'All';

  @override
  String get noDeliveriesFound => 'No Deliveries Found';

  @override
  String get noDeliveriesFoundDesc => 'You do not have any DigiTP passes.';

  @override
  String get fetchingConsumerDigiTpRecords =>
      'Fetching Consumer DigiTP records...';

  @override
  String get failedToLoadDigiTpList => 'Failed to load DigiTP list';
}
