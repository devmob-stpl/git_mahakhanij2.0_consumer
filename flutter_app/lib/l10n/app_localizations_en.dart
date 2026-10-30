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
  String get digitpDeliveries => 'Issued DigiTPs';

  @override
  String get receivedMaterial => 'Received DigiTPs';

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
      'Point camera at the driver\'s QR code or barcode to extract permit details and confirm mineral receipt.';

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
  String get eTransitPassDetails => 'DIGITP PASS DETAILS';

  @override
  String get invoiceHash => 'Invoice #';

  @override
  String get vehicleNumber => 'Vehicle Number';

  @override
  String get ownerName => 'Plot Owner Name';

  @override
  String get ownerMobile => 'Plot Owner Mobile';

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
    return 'Fetching live Vehicle location for $vehicleNo...';
  }

  @override
  String get connectingToMahakhanij =>
      'Connecting to Mahakhanij Vehicle Tracking Service';

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
  String get refreshLocation => 'Refresh';

  @override
  String get refresh => 'Refresh';

  @override
  String get inTransit => 'In Transit';

  @override
  String get delivered => 'Received';

  @override
  String get enquiries => 'Enquiries';

  @override
  String get noActiveDeliveries => 'No Active DigiTP In Transit';

  @override
  String get noDeliveriesInTransitDesc =>
      'There are currently no DigiTP in transit.';

  @override
  String get noDeliveredItems => 'No Received DigiTP';

  @override
  String get noDeliveriesReceivedDesc =>
      'You have not received any DigiTP yet.';

  @override
  String get noNotReceivedPasses => 'No Not Received DigiTP';

  @override
  String get noNotReceivedPassesDesc =>
      'There are currently no not received DigiTP.';

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
  String get quarrySeller => 'Quarry';

  @override
  String get digiTpNo => 'DigiTP No';

  @override
  String get vehicleDriverName => 'Vehicle Driver Name';

  @override
  String get driverMobileNumber => 'Driver Mobile Number';

  @override
  String get ownerMobileNumber => 'Plot Owner Mobile Number';

  @override
  String get plotProjectName => 'Plot Name';

  @override
  String get invoiceStatus => 'Invoice Status';

  @override
  String get createdDateAndTimeOfDigiTp => 'Created date and time of DigiTP';

  @override
  String get digiTpValidityDateAndTime => 'DigiTP validity date and time';

  @override
  String get receivedDate => 'Received Date';

  @override
  String get receiveDate => 'Receive Date';

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
  String get kycVerification => 'KYC Verification';

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
  String get liveVehicleTracking => 'Track Vehicle';

  @override
  String get liveGps => 'Live Vehicle';

  @override
  String get currentGpsLocation => 'CURRENT VEHICLE LOCATION';

  @override
  String get trackingLiveGps => 'Tracking Live Vehicle';

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
  String get viewAllReceivedDeliveries => 'View All Received DigiTP Deliveries';

  @override
  String get materialReceivedSuccess => 'Mineral Received Successfully!';

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
  String get chooseAccountType => 'Choose Consumer Type';

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
  String get talukaHint => 'Select Taluka';

  @override
  String get loading => 'Loading...';

  @override
  String get cityCorporationLabel => 'City / Corporation';

  @override
  String get villageRuralLabel => 'Village / Rural Area';

  @override
  String get cityCorporationHint => 'Select City';

  @override
  String get villageRuralHint => 'Select Village';

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
      'Verify your Aadhaar OTP and upload document photo';

  @override
  String get method1LiveOtp => 'Step 1: OTP Verification';

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
      'Step 2: Upload Aadhaar Card Document (PDF / Image)';

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
  String get noDeliveriesFound => 'No DigiTP Passes Found';

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
  String get resendBtn => 'Resend OTP';

  @override
  String get digitpsNotReceived => 'Not Received DigiTPs';

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
  String get validEmailRequired => 'Enter a valid email address.';

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
  String get msgGpsCaptured =>
      'Current Vehicle location captured successfully.';

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
      'Select an in-transit vehicle to monitor real-time Vehicle location and ETA.';

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
  String get gpsActive => 'Vehicle Active';

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

  @override
  String get roleBuilder => 'Builder';

  @override
  String get roleContractor => 'Contractor';

  @override
  String get roleGovernment => 'Government';

  @override
  String get roleOrganization => 'Organization';

  @override
  String get mineralStoneAgg20 => 'Stone Aggregate 20mm';

  @override
  String get mineralRiverSand => 'Natural River Sand';

  @override
  String get mineralMSand => 'Manufactured Sand (M-Sand)';

  @override
  String get mineralMurrum => 'Murrum / Soil Filling';

  @override
  String get noEnquiriesRaised => 'No enquiries raised.';

  @override
  String get quotationAccepted =>
      'Quotation accepted! Converted to formal statutory order.';

  @override
  String get docOtherSupporting => 'Other Supporting Document';

  @override
  String get docSiteBoundary => 'Site Boundary Photo';

  @override
  String get docNoc => 'Environmental / Gram Panchayat NOC';

  @override
  String get docUploadedSuccess => 'Document uploaded successfully!';

  @override
  String get queryResponseSubmitted =>
      'Query response submitted successfully! Status updated to Under Review.';

  @override
  String get mineralStoneAgg20Basalt => 'Stone Aggregate 20mm (Basalt)';

  @override
  String get appBlocked => 'App Blocked';

  @override
  String get accountBlockedLogout =>
      'Your app has been blocked. You will be logged out.';

  @override
  String get whatsapp => 'WhatsApp';

  @override
  String get gatePass => 'Gate Pass';

  @override
  String get noMineralsStockPoint => 'No minerals listed for this stock point.';

  @override
  String get noOrdersPlaced => 'No orders placed yet.';

  @override
  String get noDeliveriesRecorded => 'No deliveries recorded.';

  @override
  String get discoverQuarries => 'Discover nearby quarries for this package';

  @override
  String get scanQrCodeTruck => 'Scan QR code of truck at site gate';

  @override
  String get issueTransferEtp => 'Issue Transfer e-TP to move mineral surplus';

  @override
  String get noProjectsRegistered => 'No projects registered.';

  @override
  String get noPackagesAdded => 'No packages added to this project yet.';

  @override
  String get supervisorRegistered => 'Supervisor registered successfully!';

  @override
  String get invalidDigiTpNumber =>
      'Please enter a valid numeric DigiTP number';

  @override
  String get deliveryNotFound => 'Delivery not found.';

  @override
  String get langEnglish => 'English (EN)';

  @override
  String get langHindi => 'हिंदी (HI)';

  @override
  String get langMarathi => 'मराठी (MR)';

  @override
  String get errorUpdatingProfile =>
      'An error occurred while updating profile: ';

  @override
  String get errorPrefix => 'Error: ';

  @override
  String get downloadedReceipt => 'Downloaded DigiTP_Receipt_';

  @override
  String get statusNotReceived => 'Not Received';

  @override
  String get statusArrivedAtSite => 'Arrived at Site';

  @override
  String get statusPassIssued => 'Pass Issued';

  @override
  String get authorizedQuarry => 'Authorized Quarry';

  @override
  String financialYear(String yearRange) {
    return 'FY $yearRange';
  }

  @override
  String get verifyDigiTp => 'Verify DigiTP';

  @override
  String get removeBtn => 'Remove';

  @override
  String get contactPersonNameLabel => 'Contact Person Name';

  @override
  String get contactPersonNameHint => 'Enter Contact Person Name';

  @override
  String get contactPersonNameRequired => 'Contact person name is required.';

  @override
  String get orgPanRequired => 'Organization PAN number is required.';

  @override
  String get validPanRequired =>
      'Enter a valid 10-character PAN (e.g. ABCDE1234F).';

  @override
  String get organisationDetailsHeader => 'ORGANIZATION DETAILS';

  @override
  String get contactPersonDetailsHeader => 'CONTACT PERSON DETAILS';

  @override
  String get locationDetailsHeader => 'LOCATION DETAILS';

  @override
  String get orgNameRequiredLabel => 'Organization Name *';

  @override
  String get emailIdRequiredLabel => 'Email ID *';

  @override
  String get addressRequiredLabel => 'Address *';

  @override
  String get contactPersonNameRequiredLabel => 'Contact Person Name *';

  @override
  String get mobileNumberRequiredLabel => 'Mobile No. *';

  @override
  String get contactPersonAadhaarOptionalLabel =>
      'Contact Person Aadhaar No. (optional)';

  @override
  String get enterOrgNameHint => 'Enter organization / company / firm name';

  @override
  String get enterEmailHint => 'Enter email address';

  @override
  String get registeredOfficeAddressHint => 'Registered office address';

  @override
  String get enterContactPersonNameHint => 'Enter contact person name';

  @override
  String get enterTenDigitMobileHint => 'Enter 10-digit mobile number';

  @override
  String get enterTwelveDigitAadhaarHint => 'Enter 12-digit Aadhaar number';

  @override
  String get emailRequired => 'Email ID is required.';

  @override
  String get enterValidAadhaarNumber =>
      'Enter a valid 12-digit Aadhaar number.';

  @override
  String get aadhaarCannotStartWithZeroOrOne =>
      'Aadhaar number cannot start with 0 or 1.';

  @override
  String get aadhaarAlreadyRegistered =>
      'This Aadhaar card number is already registered in Mahakhanij system.';

  @override
  String get invalidAadhaarNumber =>
      'Invalid Aadhaar number entered. Please verify and try again.';

  @override
  String get aadhaarSendOtpFailed =>
      'Failed to send OTP to Aadhaar-registered mobile number.';

  @override
  String get contactPersonAadhaarVerificationTitle =>
      'Contact Person Aadhaar Verification';

  @override
  String get orgPanVerificationTitle => 'Organization PAN Verification';

  @override
  String get verifiedStatus => 'Verified';

  @override
  String get notVerifiedStatus => 'Not Verified';

  @override
  String get uploadAadhaarDocOptional => 'Upload Aadhaar Document (Optional)';

  @override
  String get chooseAadhaarCardPhotoPdf => 'Choose Aadhaar Card photo / PDF';

  @override
  String get otpSentToAadhaarMobileNotice =>
      'OTP will be sent to your Aadhaar registered mobile number';

  @override
  String get resendOtpBtn => 'Resend OTP';

  @override
  String get enterSixDigitOtpHint => 'Enter 6-digit OTP';

  @override
  String get enterValidAadhaarOtp => 'Enter a valid 6-digit Aadhaar OTP.';

  @override
  String get panNoOptionalLabel => 'PAN No. (optional)';

  @override
  String get enterTenDigitPan => 'Enter 10 digit PAN';

  @override
  String get uploadPanDocOptional => 'Upload PAN Document (Optional)';

  @override
  String get choosePanCardPhotoPdf => 'Choose PAN Card photo / PDF';

  @override
  String get verifyPanBtn => 'Verify PAN';

  @override
  String get panStatusPrefix => 'Status: ';

  @override
  String get panAlreadyRegistered =>
      'This PAN number is already registered in Mahakhanij system.';

  @override
  String get invalidPanNumber =>
      'Invalid PAN number entered. Please verify and try again.';

  @override
  String get panVerificationFailed =>
      'PAN verification failed. Please try again.';

  @override
  String get orgDeclarationText =>
      'I confirm that the information provided above is correct. If the information is found to be incorrect, I understand that I may be subject to applicable legal action.';

  @override
  String get confirmDeclarationRequired =>
      'Please confirm the declaration to complete registration.';

  @override
  String get organisationConsumer => 'Organization Consumer';

  @override
  String get individualConsumer => 'Individual Consumer';

  @override
  String get requiresOrgKycSubtitle =>
      'Requires Contact Person Aadhaar & Organization PAN';

  @override
  String get requiresIndividualKycSubtitle => 'Requires Aadhaar';

  @override
  String get pendingBadge => 'Pending';

  @override
  String get contactPersonAadhaarVerified => 'Contact Person Aadhaar Verified';

  @override
  String get contactPersonAadhaarPending => 'Contact Person Aadhaar Pending';

  @override
  String get authContactPersonIdentity => 'Authorized Contact Person Identity';

  @override
  String get nationalIdentityUidai => 'National Identity (UIDAI)';

  @override
  String get contactPersonAadhaar => 'Contact Person Aadhaar';

  @override
  String get orgPanVerified => 'Organization PAN Verified';

  @override
  String get orgPanPending => 'Organization PAN Pending';

  @override
  String get incomeTaxDeptEntityPan => 'Income Tax Department (Entity PAN)';

  @override
  String get orgPan => 'Organization PAN';

  @override
  String get verifyPanArrow => 'Verify PAN →';

  @override
  String get kycDetailsSavedSuccessfully =>
      'KYC verification details saved successfully';

  @override
  String get orgPanInfoTitle => 'Organization PAN Information';

  @override
  String get verifyOrgPanDesc =>
      'Verify organization PAN number and upload PAN document copy';

  @override
  String get panNumberLabel => 'PAN Number';

  @override
  String get panVerificationLabel => 'PAN Verification';

  @override
  String get verifiedUpper => 'VERIFIED';

  @override
  String get pendingUpper => 'PENDING';

  @override
  String get method1LivePanVerification => 'Step 1: PAN Verification';

  @override
  String get orgPanNumberRequired => 'Organization PAN Number *';

  @override
  String get method2UploadPanCard =>
      'Step 2: Upload PAN Card Document (PDF / Image)';

  @override
  String get choosePanPdfOrImage => 'Choose PAN PDF or image';

  @override
  String get uploadingDots => 'Uploading...';

  @override
  String get verifyOrgPanBeforeSaving =>
      'Please verify your Organization PAN before saving.';

  @override
  String get loadingConsumerProfile => 'Loading Consumer Profile...';

  @override
  String get failedToFetchConsumerProfile => 'Failed to fetch Consumer Profile';

  @override
  String get retryLoadingProfile => 'Retry Loading Profile';

  @override
  String resendInSeconds(String seconds) {
    return 'Resend in 00:$seconds';
  }

  @override
  String verifiedCountSummary(String verifiedCount, String totalDocs) {
    return '$verifiedCount of $totalDocs Verified';
  }

  @override
  String get clientSessionExpired =>
      'Client session expired. Please resend OTP.';

  @override
  String get invalidAadhaarOtp =>
      'Invalid Aadhaar OTP. Please check and try again.';

  @override
  String get uploadFailedWithReason => 'Upload failed: ';

  @override
  String get docUploadFailed => 'Document upload failed. Please try again.';

  @override
  String get panDocUploadFailed =>
      'PAN document upload failed. Please try again.';

  @override
  String get failedToUpdateProfile => 'Failed to update consumer profile.';

  @override
  String get orgNameCannotContainNumbers =>
      'Organization Name cannot contain numbers.';

  @override
  String get marathiNotAcceptedInAddress =>
      'Address cannot contain Marathi characters.';

  @override
  String get marathiNotAcceptedInEmail =>
      'Email cannot contain Marathi characters.';

  @override
  String get emailConsecutiveDots =>
      'Email cannot start with a dot or contain consecutive dots.';

  @override
  String get mobileRequired => 'Mobile number is required.';

  @override
  String get aadhaarServerError => 'Aadhaar server error. Please try again.';

  @override
  String get openSettings => 'Open Settings';

  @override
  String get permissionRequiredTitle => 'Permission Required';

  @override
  String get cameraPermissionRequired =>
      'Camera permission is required to capture documents.';

  @override
  String get cameraPermissionDeniedTwice =>
      'Camera permission has been denied. To capture and upload documents, please enable Camera permission in the app\'s Settings.';

  @override
  String get galleryPermissionDeniedTwice =>
      'Gallery access has been denied. To select documents, please enable permission in the app\'s Settings.';

  @override
  String get filePermissionDeniedTwice =>
      'Storage access has been denied. To select documents, please enable permission in the app\'s Settings.';

  @override
  String get allow => 'Allow';

  @override
  String get dontAllow => 'Don\'t Allow';

  @override
  String get unsupportedFileFormat =>
      'Unsupported file format. Please upload a valid PDF or Image file.';

  @override
  String get verifyOrgPanBeforeRegistration =>
      'Please verify your Organization PAN before completing registration.';

  @override
  String get userNotAvailable =>
      'User not available. Please register or check mobile number.';

  @override
  String get mobileAlreadyRegistered =>
      'This mobile number is already registered in Mahakhanij system.';

  @override
  String get recordAlreadyExists => 'Record already exists in the system.';

  @override
  String get fileSizeTooLarge =>
      'File size is too large. Please select a file under 5MB.';

  @override
  String get connectionTimeout => 'Connection timed out. Please try again.';

  @override
  String get serverErrorTryAgain => 'Server error. Please try again later.';

  @override
  String get somethingWentWrong => 'Something went wrong. Please try again.';

  @override
  String get digitpAlreadyReceived => 'DigiTP is already received.';

  @override
  String get projectRegisteredSuccess => 'Project registered successfully!';

  @override
  String get projectRegisterFailed => 'Failed to register project.';

  @override
  String get deliverySiteRegisteredSuccess =>
      'Private delivery site registered successfully!';

  @override
  String get deliverySiteRegisterFailed => 'Failed to register site.';

  @override
  String get invalidResponseFromServer =>
      'Invalid response received from server.';

  @override
  String get gstVerificationFailed =>
      'GST verification failed. Please try again.';

  @override
  String get failedToFetchDashboardCounts =>
      'Failed to fetch dashboard counts.';

  @override
  String get errVehicleNoRequired => 'Vehicle number cannot be empty.';

  @override
  String get inventoryBalanceNotFound => 'Inventory balance not found.';

  @override
  String get aadhaarLabel => 'Aadhaar';

  @override
  String get speedUnitKmH => 'km/h';

  @override
  String get unitBrass => 'Brass';

  @override
  String get citizenServices => 'Citizen Services';

  @override
  String get registerProject => 'Register Project';

  @override
  String get findMineralPlaces => 'Find Mineral Places';

  @override
  String get organizationServices => 'Organization Services';

  @override
  String get unauthorizedAccess =>
      'Access restricted to Organization accounts.';

  @override
  String get projectsTab => 'Projects';

  @override
  String get temporaryExcavation => 'Temporary Excavation';

  @override
  String get mineralEnquiries => 'Mineral Enquiries';

  @override
  String get mineralsCatalog => 'Mineral Catalog';

  @override
  String get siteInventory => 'Site Inventory';

  @override
  String get materialTransfers => 'Transfers';

  @override
  String get purchaseOrders => 'Orders';

  @override
  String get supervisors => 'Supervisors';
}
