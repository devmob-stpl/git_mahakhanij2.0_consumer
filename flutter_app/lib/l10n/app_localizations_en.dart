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
  String get saveBtn => 'Save';

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
  String get govtOfMaharashtra => 'Government of Maharashtra';

  @override
  String get revenueDepartment => 'Revenue Department';

  @override
  String get minorMineralTransportSystem => 'Minor Mineral Transport System';

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
  String get enterPersonalContact => 'Enter your personal contact details.';

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
  String get continueToKyc => 'Next';

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
  String get districtLabel => 'District';

  @override
  String get selectDistrictHint => 'Select District';

  @override
  String get loadingDistricts => 'Loading Districts...';

  @override
  String get talukaLabel => 'Taluka';

  @override
  String get talukaHint => 'e.g. Haveli';

  @override
  String get loading => 'Loading...';

  @override
  String get cityCorporationLabel => 'City / Corporation';

  @override
  String get villageRuralLabel => 'Village / Rural Area';

  @override
  String get cityCorporationHint => 'e.g. Pune City';

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

  @override
  String get orgKycVerification => 'Organization KYC Verification';

  @override
  String get optionalLabel => 'Optional';

  @override
  String get verifyIdentityOrSkip =>
      'Verify identity via Aadhaar OTP or skip to complete your registration.';

  @override
  String get aadhaarCardOtpVerification => 'Aadhaar Card OTP Verification';

  @override
  String get enterTwelveDigitAadhaarToReceiveOtp =>
      'Enter 12-digit Aadhaar to receive OTP';

  @override
  String get aadhaarCardNumberLabel => 'Aadhaar card number';

  @override
  String get twelveDigitAadhaarHint => '12-digit Aadhaar number';

  @override
  String get enterSixDigitAadhaarOtpLabel => 'Enter 6-digit Aadhaar OTP';

  @override
  String get sixDigitOtpHint => '6-digit OTP';

  @override
  String get aadhaarIdentityVerified => 'Aadhaar Identity Verified';

  @override
  String get aadhaarVerifiedNationalId =>
      'Aadhaar verified national identity card';

  @override
  String get uploadAadhaarCardOptional => 'Upload Aadhaar Card (Optional)';

  @override
  String get frontOrCombinedAadhaar =>
      'Front or combined copy of Aadhaar card (PDF / Image)';

  @override
  String get aadhaarNonMandatoryNotice =>
      'Aadhaar verification is non-mandatory. You can skip this step at any time and complete registration.';

  @override
  String get resendBtn => 'Resend';

  @override
  String get digitpsNotReceived => 'DigiTPs\nNot Received';

  @override
  String get enterFullName => 'Enter Full Name';

  @override
  String get emailOptional => 'Email (Optional)';

  @override
  String get enterEmail => 'Enter E-mail';

  @override
  String get stateLabel => 'State';

  @override
  String get loadingStates => 'Loading States...';

  @override
  String get selectStateHint => 'Select State';

  @override
  String get consumerLabel => 'Consumer';

  @override
  String get organizationLabel => 'Organization';

  @override
  String get actionRequiredLabel => 'Action Required';

  @override
  String get aadhaarAuthenticationLabel => 'Aadhaar Authentication';

  @override
  String get approvedLabel => 'Approved';

  @override
  String get invalidOtpServer => 'Invalid OTP entered. Please try again.';

  @override
  String get maharashtraState => 'Maharashtra';

  @override
  String get viewBtn => 'View';

  @override
  String get logoutBtn => 'Logout';

  @override
  String get logoutErrorMsg => 'Network/API error during logout:';

  @override
  String get logoutFailedMsg => 'Logout failed. Please try again.';

  @override
  String get preferencesHeader => 'PREFERENCES';

  @override
  String get changeLanguageLabel => 'Change Language';

  @override
  String get storagePhotosPermissionReq =>
      'Storage/Photos permission is required to select from gallery.';

  @override
  String get cameraPermissionReq =>
      'Camera permission is required to take pictures.';

  @override
  String get storagePermissionReq =>
      'Storage permission is required to pick documents.';

  @override
  String get registrationSuccess =>
      'Registration successful! Please sign in with your mobile number.';

  @override
  String get registrationFailed => 'Registration failed. Please try again.';

  @override
  String get fullNameRequired => 'Full Name is required.';

  @override
  String get validMobileRequired =>
      'Enter a valid 10-digit Indian mobile number.';

  @override
  String get orgNameRequired => 'Organization Name is required.';

  @override
  String get gstinRequired => 'Enter your organization GSTIN.';

  @override
  String get addressRequired => 'Address is required.';

  @override
  String get validEmailRequired =>
      'Enter a valid email address without consecutive dots or dots at the start.';

  @override
  String get districtRequired => 'District is required.';

  @override
  String get talukaRequired => 'Taluka is required.';

  @override
  String get cityCorpRequired => 'City/Corporation is required.';

  @override
  String get villageRequired => 'Village is required.';

  @override
  String get aadhaarVerificationRequired =>
      'Please verify your Aadhaar number to proceed.';

  @override
  String get surveyNumberRequired => 'Survey number is required.';

  @override
  String get validGstRequired => 'Enter a valid 15-character GSTIN.';

  @override
  String get changeLanguageLaterHint =>
      'You can always change this later in settings.';

  @override
  String get changeBtn => 'Change';

  @override
  String get aadhaarDetailsSavedSuccessfully =>
      'Aadhaar verification details saved successfully';

  @override
  String get noInternetConnection => 'No Internet Connection';

  @override
  String get unableToLogin =>
      'Unable to login. Please check internet connection.';

  @override
  String get loginFailedMsg => 'Login failed. Please try again.';

  @override
  String get pleaseEnterFullName => 'Please enter your full name.';

  @override
  String get pleaseEnterValidEmail => 'Please enter a valid email address.';

  @override
  String get profileSaveError => 'Failed to save profile. Please try again.';

  @override
  String get aadhaarSendOtpError =>
      'Failed to send Aadhaar OTP. Please try again.';

  @override
  String get msgRegSuccessSignIn =>
      'Registration successful! Please sign in with your mobile number.';

  @override
  String get errEnterMandatoryFields => 'Please enter all mandatory fields.';

  @override
  String get msgRegSuccessLogin =>
      'Registration successful! Please login with your mobile number.';

  @override
  String get errEnterSiteName =>
      'Please enter site name (e.g. My Residence Construction)';

  @override
  String get errEnterDeliveryAddress => 'Please enter delivery address';

  @override
  String get msgEnquirySubmitted => 'Enquiry submitted to quarry operator!';

  @override
  String get msgDownloadingFile => 'Downloading ';

  @override
  String get msgDownloadingAppFee =>
      'Downloading Application Fee Demand Note...';

  @override
  String get msgDownloadingGrasReceipt => 'Downloading GRAS Fee Receipt...';

  @override
  String get msgDownloadingRoyaltyNote => 'Downloading Royalty Demand Note...';

  @override
  String get msgDownloadingPermitOrder =>
      'Downloading Official Excavation Permit Order...';

  @override
  String get msgDraftSaved => 'Draft saved successfully.';

  @override
  String get errUploadMandatoryDocs =>
      'Please upload all mandatory documents (*) before proceeding.';

  @override
  String get errAcceptDeclaration =>
      'Please accept statutory minor minerals declaration.';

  @override
  String get msgAppSubmitted =>
      'Application successfully submitted with fee paid!';

  @override
  String get msgPinMapOverlay => 'Pin map overlay opened. Location set.';

  @override
  String get msgGpsCaptured => 'Current GPS location captured successfully.';

  @override
  String get msgAttachedReceipt => 'Attached bank_stamped_receipt_MH2026.pdf';

  @override
  String get msgDownloadedChallan =>
      'Downloaded GRAS e-Challan (GRN & CIN) PDF';

  @override
  String get errStateEngPurpose =>
      'Please state the engineering purpose for drawdown';

  @override
  String get msgConsumptionLogged =>
      'Statutory on-site consumption drawdown logged successfully!';

  @override
  String get msgTransferEtpGenerated =>
      'Transfer e-TP generated successfully! Pass is ready for driver handover.';

  @override
  String get msgTransitPassShared => 'Transit pass link shared on WhatsApp!';

  @override
  String get msgGatePassReady => 'Gate pass ready to print / download.';

  @override
  String get errCannotCall => 'Cannot make call to ';

  @override
  String get errEnterPackageName => 'Please enter a package name';

  @override
  String get msgPackageCreated => 'Package created successfully!';

  @override
  String get errEnterProjectName => 'Enter the project name.';

  @override
  String get errSelectGovDept => 'Select or enter the government department.';

  @override
  String get errEnterOfficeName => 'Enter the issuing / division office name.';

  @override
  String get errEnterWorkOrder =>
      'Enter the work order / sanction order number.';

  @override
  String get errEnterSiteAddress => 'Enter the site address.';

  @override
  String get msgCallingSupervisor => 'Calling supervisor...';

  @override
  String get msgOpeningWhatsapp => 'Opening WhatsApp...';

  @override
  String get msgActiveScopeSet => 'Active operating scope set to: ';

  @override
  String get errEnterSupervisorName => 'Please enter supervisor name';

  @override
  String get errEnterSupervisorContact =>
      'Please enter supervisor contact detail';

  @override
  String get errEnterValidDigitp =>
      'Please enter a valid numeric DigiTP Number.';

  @override
  String get inTransitVehiclesTitle => 'In-Transit Vehicles';

  @override
  String get activeVehicleTracking => 'Active Vehicle Tracking';

  @override
  String get activeVehicleTrackingDesc =>
      'Select an in-transit vehicle to monitor real-time GPS location and ETA.';

  @override
  String get loadingInTransitVehicles => 'Loading In-Transit vehicles...';

  @override
  String get failedToLoadInTransitVehicles =>
      'Failed to load In-Transit vehicles';

  @override
  String get noVehiclesInTransit => 'No Vehicles In-Transit';

  @override
  String get noVehiclesInTransitDesc =>
      'There are currently no active mineral vehicles in-transit for your account.';

  @override
  String get refreshList => 'Refresh List';

  @override
  String get vehicleNA => 'Vehicle N/A';

  @override
  String get destinationNA => 'Destination N/A';

  @override
  String get gpsActive => 'GPS Active';

  @override
  String get mineralAndQty => 'Mineral & Qty:';

  @override
  String get destinationLabel => 'Destination:';

  @override
  String get distanceLabel => 'Distance :';

  @override
  String get driverLabel => 'Driver:';

  @override
  String get selectVehicleAndTrackLive => 'Select Vehicle & Track Live';

  @override
  String get digiTpLabel => 'DigiTP:';

  @override
  String get inTransitStatus => 'In Transit';
}
