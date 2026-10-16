// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Marathi (`mr`).
class AppLocalizationsMr extends AppLocalizations {
  AppLocalizationsMr([String locale = 'mr']) : super(locale);

  @override
  String get appName => 'महाखनिज';

  @override
  String get language => 'भाषा';

  @override
  String get settings => 'सेटिंग्ज';

  @override
  String get home => 'मुख्यपृष्ठ';

  @override
  String get profile => 'प्रोफाइल';

  @override
  String get welcome => 'सुस्वागतम';

  @override
  String get digitpDeliveries => 'डिजीटीपी\nजारी केले';

  @override
  String get receivedMaterial => 'डिजीटीपी\nप्राप्त झाले';

  @override
  String get inTransitVehicles => 'मार्गातील\nवाहने';

  @override
  String get coreServices => 'मुख्य सेवा';

  @override
  String get digitpPasses => 'डिजीटीपी\nपास';

  @override
  String get receiveMaterialAction => 'सामग्री\nप्राप्त करा';

  @override
  String get trackVehicle => 'वाहन\nट्रॅक करा';

  @override
  String get recentDeliveriesHeader => 'डिजीटीपी आणि खनिज वितरण';

  @override
  String get viewAll => 'सर्व पहा';

  @override
  String get noRecentDeliveries => 'कोणतेही अलीकडील डिजीटीपी वितरण आढळले नाही.';

  @override
  String get receiveMaterial => 'सामग्री प्राप्त करा';

  @override
  String get receiveMaterialError => 'सामग्री प्राप्त करताना त्रुटी';

  @override
  String get scanDigiTp => 'डिजीटीपी क्यूआर / बारकोड स्कॅन करा';

  @override
  String get pointCameraDescription =>
      'परवाना तपशील काढण्यासाठी आणि सामग्री पावतीची पुष्टी करण्यासाठी कॅमेरा ड्रायव्हरच्या क्यूआर कोड किंवा बारकोडकडे वळवा.';

  @override
  String get openCameraScanner => 'कॅमेरा स्कॅनर उघडा';

  @override
  String get enterInvoiceManually => 'मॅन्युअली पावती क्रमांक प्रविष्ट करा';

  @override
  String get processingScan => 'स्कॅन प्रक्रियेत आहे...';

  @override
  String get decodingPermit => 'परवाना पेलोड डिकोड करत आहे...';

  @override
  String get ok => 'ठीक आहे';

  @override
  String get eTransitPassDetails => 'ई-ट्रान्झिट पास तपशील';

  @override
  String get invoiceHash => 'पावती #';

  @override
  String get vehicleNumber => 'वाहन क्रमांक';

  @override
  String get ownerName => 'प्लॉट मालकाचे नाव';

  @override
  String get ownerMobile => 'प्लॉट मालकाचा मोबाईल';

  @override
  String get driverDetails => 'चालकाचे तपशील';

  @override
  String get materialAndQuantity => 'सामग्री आणि प्रमाण';

  @override
  String get destination => 'गंतव्यस्थान';

  @override
  String get distanceKm => 'अंतर (किमी)';

  @override
  String get validityFrom => 'पासून वैध';

  @override
  String get validityUpto => 'पर्यंत वैध';

  @override
  String get confirmingReceipt => 'पावतीची पुष्टी करत आहे...';

  @override
  String get confirmAndReceiveMaterial => 'पुष्टी करा आणि सामग्री प्राप्त करा';

  @override
  String get track => 'ट्रॅक करा';

  @override
  String fetchingLiveGpsLocation(String vehicleNo) {
    return '$vehicleNo साठी लाईव्ह वाहन स्थान प्राप्त करत आहे...';
  }

  @override
  String get connectingToMahakhanij =>
      'महाखनिज वाहन ट्रॅकिंग सेवेशी कनेक्ट होत आहे';

  @override
  String get trackingDataUnavailable => 'ट्रॅकिंग डेटा अनुपलब्ध';

  @override
  String get retryFetching => 'पुन्हा प्रयत्न करा';

  @override
  String get tryDemoVehicle => 'डेमो वाहन वापरून पहा';

  @override
  String noLocationDataFor(String vehicleNo) {
    return '$vehicleNo साठी कोणताही स्थान डेटा नाही';
  }

  @override
  String get refreshLocation => 'रीफ्रेश करा';

  @override
  String get refresh => 'रिफ्रेश करा';

  @override
  String get inTransit => 'प्रवासात';

  @override
  String get delivered => 'प्राप्त';

  @override
  String get enquiries => 'चौकशी';

  @override
  String get noActiveDeliveries => 'कोणतेही वाहतुकीतील पास नाहीत';

  @override
  String get noDeliveriesInTransitDesc => 'सध्या वाहतुकीत कोणतेही पास नाहीत.';

  @override
  String get noDeliveredItems => 'कोणतेही प्राप्त पास नाहीत';

  @override
  String get noDeliveriesReceivedDesc =>
      'तुम्हाला अद्याप कोणतेही पास प्राप्त झालेले नाहीत.';

  @override
  String get noNotReceivedPasses => 'कोणतेही अप्राप्त पास नाहीत';

  @override
  String get noNotReceivedPassesDesc => 'सध्या कोणतेही अप्राप्त पास नाहीत.';

  @override
  String get noActiveEnquiries => 'कोणतीही सक्रिय चौकशी नाही';

  @override
  String get noActiveEnquiriesDesc => 'सध्या कोणतीही सक्रिय चौकशी नाही.';

  @override
  String get source => 'स्त्रोत';

  @override
  String get validity => 'वैधता';

  @override
  String get viewDigiTp => 'डिजीटीपी पहा';

  @override
  String get cancelEnquiry => 'चौकशी रद्द करा';

  @override
  String get cancelling => 'रद्द करत आहे...';

  @override
  String get activityTab => 'डिजीटीपी';

  @override
  String get mineral => 'खनिज';

  @override
  String get qty => 'प्रमाण';

  @override
  String get vehicle => 'वाहन';

  @override
  String get driver => 'चालक';

  @override
  String get quarrySeller => 'खाण';

  @override
  String get digiTpNo => 'डिजीटीपी क्र.';

  @override
  String get vehicleDriverName => 'वाहन चालकाचे नाव';

  @override
  String get driverMobileNumber => 'चालकाचा मोबाईल नंबर';

  @override
  String get ownerMobileNumber => 'प्लॉट मालकाचा मोबाईल नंबर';

  @override
  String get plotProjectName => 'प्लॉटचे नाव';

  @override
  String get invoiceStatus => 'चलनाची स्थिती';

  @override
  String get createdDateAndTimeOfDigiTp => 'डिजीटीपीची निर्मिती तारीख आणि वेळ';

  @override
  String get digiTpValidityDateAndTime => 'डिजीटीपी वैधता तारीख आणि वेळ';

  @override
  String get receivedDate => 'प्राप्त तारीख';

  @override
  String get receiveDate => 'प्राप्त तारीख';

  @override
  String get profileName => 'नाव';

  @override
  String get profileMobile => 'मोबाईल क्र.';

  @override
  String get profileEmail => 'ईमेल';

  @override
  String get profileAddress => 'पत्ता';

  @override
  String get profileDistrict => 'जिल्हा';

  @override
  String get profileTaluka => 'तालुका';

  @override
  String get profileCityVillage => 'शहर / गाव';

  @override
  String get profilePincode => 'पिनकोड';

  @override
  String get saveBtn => 'जतन करा';

  @override
  String get saveChanges => 'बदल जतन करा';

  @override
  String get kycVerification => 'केवायसी पडताळणी';

  @override
  String get aadhaarKyc => 'आधार केवायसी';

  @override
  String get verifyAadhaar => 'आधार पडताळणी करा';

  @override
  String get uploadDocument => 'दस्तऐवज अपलोड करा';

  @override
  String get viewDocument => 'दस्तऐवज पहा';

  @override
  String get aadhaarVerified => 'पडताळणी झाली';

  @override
  String get aadhaarPending => 'प्रलंबित';

  @override
  String get rural => 'ग्रामीण';

  @override
  String get urban => 'शहरी';

  @override
  String get residentialDetails => 'निवासी तपशील';

  @override
  String get personalDetails => 'वैयक्तिक तपशील';

  @override
  String get liveVehicleTracking => 'वाहन ट्रॅक करा';

  @override
  String get liveGps => 'थेट वाहन';

  @override
  String get currentGpsLocation => 'सध्याचे वाहन स्थान';

  @override
  String get trackingLiveGps => 'थेट वाहन ट्रॅक करत आहे';

  @override
  String get speed => 'वेग';

  @override
  String get lastUpdated => 'अंतिम अपडेट';

  @override
  String get tripDetails => 'प्रवासाचे तपशील';

  @override
  String get tripId => 'ट्रिप आयडी';

  @override
  String get originQuarryPlot => 'मूळ / खाण प्लॉट';

  @override
  String get destinationSite => 'गंतव्य स्थान';

  @override
  String get totalDistance => 'एकूण अंतर';

  @override
  String get validFrom => 'पासून वैध';

  @override
  String get validUpto => 'पर्यंत वैध';

  @override
  String get noActiveDigiTpTripDetails =>
      'सध्या या वाहनाशी संबंधित कोणतेही सक्रिय डिजीटीपी प्रवास तपशील नाहीत.';

  @override
  String get mobileNumberUnavailable => 'मोबाईल नंबर उपलब्ध नाही';

  @override
  String get enterVehicleNo => 'वाहन क्रमांक प्रविष्ट करा';

  @override
  String get enterDigiTpNumber => 'डिजीटीपी नंबर प्रविष्ट करा';

  @override
  String get enterDigiTpNumberHint => 'उदा. 491 किंवा 0436610';

  @override
  String get cancel => 'रद्द करा';

  @override
  String get fetchDetails => 'तपशील मिळवा';

  @override
  String get scanAnotherCode => 'दुसरा कोड स्कॅन करा';

  @override
  String get viewAllReceivedDeliveries => 'सर्व प्राप्त वितरणे पहा';

  @override
  String get materialReceivedSuccess => 'सामग्री यशस्वीरित्या प्राप्त झाली!';

  @override
  String get govtOfMaharashtra => 'महाराष्ट्र शासन';

  @override
  String get revenueDepartment => 'महसूल विभाग';

  @override
  String get minorMineralTransportSystem => 'गौणखनिज वाहतूक प्रणाली';

  @override
  String get revenueDeptMsg => 'महसूल विभाग, महाराष्ट्र शासन';

  @override
  String get welcomeTitle => 'खनिज, स्रोतापासून साइटपर्यंत';

  @override
  String get welcomeSubtitle =>
      'खनिज ठिकाण शोधा, चौकशी करा, वाहनाचा मागोवा घ्या, काय येते ते सत्यापित करा आणि तुम्ही काय वापरता ते व्यवस्थापित करा.';

  @override
  String get signIn => 'साइन इन करा';

  @override
  String get createAccount => 'नवीन खाते तयार करा';

  @override
  String get loginHeading => 'लॉगिन';

  @override
  String get mobileNumberHint => 'मोबाईल क्रमांक';

  @override
  String waitSeconds(String seconds) {
    return 'कृपया $seconds सेकंद प्रतीक्षा करा';
  }

  @override
  String get resendOtp => 'ओटीपी पुन्हा पाठवा';

  @override
  String get invalidMobileError =>
      'वैध 10-अंकी भारतीय मोबाईल क्रमांक प्रविष्ट करा.';

  @override
  String get invalidOtpError => 'कृपया संपूर्ण 5-अंकी OTP प्रविष्ट करा.';

  @override
  String get getOtpBtn => 'ओटीपी मिळवा';

  @override
  String get loginBtn => 'लॉगिन करा';

  @override
  String get newMemberMsg => 'नवीन सदस्य? ';

  @override
  String get signUpLink => 'साइन अप करा';

  @override
  String get chooseAccountType => 'खाता प्रकार निवडा';

  @override
  String get howWillYouUse => 'तुम्ही महाखनिज कसे वापराल?';

  @override
  String get chooseAccountDesc =>
      'अॅप तुम्हाला काय दाखवते हे हे ठरवते. हे नंतर बदलता येणार नाही.';

  @override
  String get individual => 'वैयक्तिक';

  @override
  String get individualDesc =>
      'वैयक्तिक वापरासाठी खनिज खरेदी करणार्‍या व्यक्तीसाठी.';

  @override
  String get organization => 'संस्था';

  @override
  String get organizationDesc =>
      'प्रकल्प आणि पॅकेजेसमध्ये काम करणाऱ्या बिल्डर, कंत्राटदार, सरकारी संस्था किंवा इतर कोणत्याही संस्थेसाठी.';

  @override
  String get alreadyHaveAccount => 'आधीच खाते आहे का? ';

  @override
  String get basicAndAddressDetails => 'मूलभूत आणि पत्ता तपशील';

  @override
  String get enterPersonalContact =>
      'तुमचे वैयक्तिक संपर्क तपशील प्रविष्ट करा.';

  @override
  String get fullName => 'पूर्ण नाव';

  @override
  String get mobileNumber => 'मोबाईल क्रमांक';

  @override
  String get tenDigitNumber => '10-अंकी क्रमांक';

  @override
  String get weWillSendVerification =>
      'आम्ही या नंबरवर 5-अंकी सत्यापन कोड पाठवू.';

  @override
  String get orgNameLabel => 'संस्थेचे नाव';

  @override
  String get orgTypeLabel => 'संस्थेचा प्रकार';

  @override
  String get gstinLabel => 'जीएसटीआयएन (GSTIN)';

  @override
  String get continueBtn => 'पुढे जा';

  @override
  String get continueToKyc => 'पुढे जा';

  @override
  String get completeRegistration => 'नोंदणी पूर्ण करा';

  @override
  String get skipAadhaar => 'आधार पडताळणी वगळा आणि साइनअप पूर्ण करा';

  @override
  String stepOf(int step, int total) {
    return 'चरण $step / $total';
  }

  @override
  String get personaIndividualDesc => 'वैयक्तिक आणि घर बांधकाम';

  @override
  String get personaOrganizationDesc => 'पायाभूत सुविधा आणि व्यावसायिक प्रकल्प';

  @override
  String get whereDeliverMineral => 'खनिजाचे वितरण कोठे करावे?';

  @override
  String get areaClassificationLabel => 'क्षेत्र वर्गीकरण';

  @override
  String get urbanCity => 'शहरी (शहर)';

  @override
  String get ruralVillage => 'ग्रामीण (गाव)';

  @override
  String get districtLabel => 'जिल्हा';

  @override
  String get selectDistrictHint => 'जिल्हा निवडा';

  @override
  String get loadingDistricts => 'जिल्हे लोड करत आहे...';

  @override
  String get talukaLabel => 'तालुका';

  @override
  String get talukaHint => 'उदा. हवेली';

  @override
  String get loading => 'लोड करत आहे...';

  @override
  String get cityCorporationLabel => 'शहर / महानगरपालिका';

  @override
  String get villageRuralLabel => 'गाव / ग्रामीण भाग';

  @override
  String get cityCorporationHint => 'उदा. पुणे शहर';

  @override
  String get villageRuralHint => 'उदा. नारायणगाव';

  @override
  String get addressLabel => 'पत्ता (घर / फ्लॅट / रस्ता / क्षेत्र)';

  @override
  String get addressHint => 'प्लॉट / घर क्र., इमारत, क्षेत्र / रस्ता';

  @override
  String get pincodeLabel => 'पिन कोड';

  @override
  String get pincodeHint => '6-अंकी पिन कोड';

  @override
  String get profileScreenTitle => 'ग्राहक प्रोफाइल आणि केवायसी (KYC)';

  @override
  String get settingsScreenTitle => 'सेटिंग्ज';

  @override
  String get cameraBtn => 'कॅमेरा';

  @override
  String get galleryBtn => 'गॅलरी';

  @override
  String get fileDocumentBtn => 'फाइल दस्तऐवज';

  @override
  String get aadhaarEkycInfoTitle => 'आधार ई-केवायसी माहिती';

  @override
  String get aadhaarNumberLabel => 'आधार क्रमांक';

  @override
  String get aadhaarVerificationLabel => 'आधार पडताळणी';

  @override
  String get aadhaarDocumentUrlLabel => 'आधार दस्तऐवज URL';

  @override
  String get closeBtn => 'बंद करा';

  @override
  String get verifyAadhaarBtn => 'आधार पडताळणी करा';

  @override
  String get aadhaarIdentityVerificationTitle => 'आधार ओळख पडताळणी';

  @override
  String get aadhaarIdentityVerificationDesc =>
      'तुमचा आधार OTP सत्यापित करा किंवा दस्तऐवज फोटो अपलोड करा';

  @override
  String get method1LiveOtp => 'पद्धत १: थेट OTP पडताळणी';

  @override
  String get twelveDigitAadhaarNumber => '१२-अंकी आधार क्रमांक *';

  @override
  String get enterTwelveDigitAadhaar => '१२ अंकी आधार क्रमांक प्रविष्ट करा';

  @override
  String get sendOtpBtn => 'ओटीपी पाठवा';

  @override
  String get sixDigitAadhaarOtp => '६-अंकी आधार OTP *';

  @override
  String get enterSixDigitOtp => '६ अंकी OTP प्रविष्ट करा';

  @override
  String get verifyOtpBtn => 'OTP पडताळणी करा';

  @override
  String get method2UploadAadhaar =>
      'पद्धत २: आधार कार्ड दस्तऐवज अपलोड करा (PDF / चित्र)';

  @override
  String get uploadAadhaarDesc =>
      'महाखनिज दस्तऐवज सर्व्हरद्वारे अपलोड करण्यासाठी दस्तऐवज फाइल निवडा';

  @override
  String get chooseAadhaarPdfOrImage => 'आधार PDF किंवा चित्र निवडा';

  @override
  String get uploadingToMahakhanijServer =>
      'महाखनिज सर्व्हरवर अपलोड होत आहे...';

  @override
  String get replaceBtn => 'बदला';

  @override
  String get uploadBtn => 'अपलोड करा';

  @override
  String get retryBtn => 'पुन्हा प्रयत्न करा';

  @override
  String get aadhaarVerificationCompleted => 'आधार पडताळणी पूर्ण झाली!';

  @override
  String get aadhaarVerificationSuccessDesc =>
      'महाराष्ट्र सरकारसोबत आधार क्रेडेन्शियल्स यशस्वीरित्या सत्यापित झाले.';

  @override
  String get doneBtn => 'पूर्ण झाले';

  @override
  String get reports => 'अहवाल';

  @override
  String get last30Days => 'मागील ३० दिवस';

  @override
  String get quarterly => 'त्रैमासिक';

  @override
  String get fy2425 => 'आर्थिक वर्ष 24-25';

  @override
  String get filterByQuarry => 'खाण (पार्टी) नुसार फिल्टर करा';

  @override
  String get allQuarries => 'सर्व खाणी';

  @override
  String get errorLoadingPlots => 'प्लॉट्स लोड करताना त्रुटी';

  @override
  String get noDataAvailable => 'कोणताही डेटा उपलब्ध नाही';

  @override
  String get totalReceived => 'एकूण प्राप्त';

  @override
  String get digitpsReceived => 'प्राप्त झालेले डिजीटीपी';

  @override
  String get passes => 'पास';

  @override
  String get mineralProcurementBreakdown => 'खनिज खरेदी तपशील';

  @override
  String get byVolume => 'आकारमानानुसार';

  @override
  String get noMaterialsFound => 'कोणतेही साहित्य आढळले नाही';

  @override
  String get errorLoadingReport => 'अहवाल लोड करताना त्रुटी: ';

  @override
  String get units => 'एकक';

  @override
  String get notReceived => 'प्राप्त झाले नाही';

  @override
  String get all => 'सर्व';

  @override
  String get noDeliveriesFound => 'कोणतेही डिजीटीपी पास आढळले नाहीत';

  @override
  String get noDeliveriesFoundDesc => 'तुमच्याकडे कोणतेही DigiTP पास नाहीत.';

  @override
  String get fetchingConsumerDigiTpRecords =>
      'ग्राहक DigiTP रेकॉर्ड आणत आहे...';

  @override
  String get failedToLoadDigiTpList => 'DigiTP सूची लोड करण्यात अयशस्वी';

  @override
  String get orgKycVerification => 'संस्था केवायसी (KYC) पडताळणी';

  @override
  String get optionalLabel => 'पर्यायी';

  @override
  String get verifyIdentityOrSkip =>
      'आधार OTP द्वारे ओळख सत्यापित करा किंवा तुमची नोंदणी पूर्ण करण्यासाठी वगळा.';

  @override
  String get aadhaarCardOtpVerification => 'आधार कार्ड OTP पडताळणी';

  @override
  String get enterTwelveDigitAadhaarToReceiveOtp =>
      'OTP प्राप्त करण्यासाठी 12-अंकी आधार प्रविष्ट करा';

  @override
  String get aadhaarCardNumberLabel => 'आधार कार्ड नंबर';

  @override
  String get twelveDigitAadhaarHint => '12-अंकी आधार नंबर';

  @override
  String get enterSixDigitAadhaarOtpLabel => '6-अंकी आधार OTP प्रविष्ट करा';

  @override
  String get sixDigitOtpHint => '6-अंकी OTP';

  @override
  String get aadhaarIdentityVerified => 'आधार ओळख सत्यापित';

  @override
  String get aadhaarVerifiedNationalId => 'आधार सत्यापित राष्ट्रीय ओळखपत्र';

  @override
  String get uploadAadhaarCardOptional => 'आधार कार्ड अपलोड करा (पर्यायी)';

  @override
  String get frontOrCombinedAadhaar =>
      'आधार कार्डची फ्रंट किंवा संयुक्त प्रत (PDF / Image)';

  @override
  String get aadhaarNonMandatoryNotice =>
      'आधार पडताळणी अनिवार्य नाही. तुम्ही कोणत्याही वेळी ही पायरी वगळू शकता आणि नोंदणी पूर्ण करू शकता.';

  @override
  String get resendBtn => 'OTP पुन्हा पाठवा';

  @override
  String get digitpsNotReceived => 'डिजीटीपी\nप्राप्त नाही';

  @override
  String get enterFullName => 'पूर्ण नाव प्रविष्ट करा';

  @override
  String get emailOptional => 'ई-मेल (पर्यायी)';

  @override
  String get enterEmail => 'ई-मेल प्रविष्ट करा';

  @override
  String get stateLabel => 'राज्य';

  @override
  String get loadingStates => 'राज्ये लोड होत आहेत...';

  @override
  String get selectStateHint => 'राज्य निवडा';

  @override
  String get consumerLabel => 'ग्राहक';

  @override
  String get organizationLabel => 'संस्था';

  @override
  String get actionRequiredLabel => 'कारवाई आवश्यक';

  @override
  String get aadhaarAuthenticationLabel => 'आधार प्रमाणीकरण';

  @override
  String get approvedLabel => 'मंजूर';

  @override
  String get invalidOtpServer =>
      'अवैध OTP प्रविष्ट केला. कृपया पुन्हा प्रयत्न करा.';

  @override
  String get maharashtraState => 'महाराष्ट्र';

  @override
  String get viewBtn => 'पहा';

  @override
  String get logoutBtn => 'लॉगआउट';

  @override
  String get logoutErrorMsg => 'लॉगआउट दरम्यान नेटवर्क/API त्रुटी:';

  @override
  String get logoutFailedMsg => 'लॉगआउट अयशस्वी. कृपया पुन्हा प्रयत्न करा.';

  @override
  String get preferencesHeader => 'प्राधान्ये';

  @override
  String get changeLanguageLabel => 'भाषा बदला';

  @override
  String get storagePhotosPermissionReq =>
      'गॅलरीतून निवडण्यासाठी स्टोरेज/फोटो परवानगी आवश्यक आहे.';

  @override
  String get cameraPermissionReq =>
      'फोटो काढण्यासाठी कॅमेरा परवानगी आवश्यक आहे.';

  @override
  String get storagePermissionReq =>
      'कागदपत्रे निवडण्यासाठी स्टोरेज परवानगी आवश्यक आहे.';

  @override
  String get registrationSuccess =>
      'नोंदणी यशस्वी! कृपया तुमच्या मोबाईल नंबरने साइन इन करा.';

  @override
  String get registrationFailed => 'नोंदणी अयशस्वी. कृपया पुन्हा प्रयत्न करा.';

  @override
  String get fullNameRequired => 'पूर्ण नाव आवश्यक आहे.';

  @override
  String get validMobileRequired =>
      'एक वैध 10-अंकी भारतीय मोबाईल नंबर प्रविष्ट करा.';

  @override
  String get orgNameRequired => 'संस्थेचे नाव आवश्यक आहे.';

  @override
  String get gstinRequired => 'तुमचा संस्था GSTIN प्रविष्ट करा.';

  @override
  String get addressRequired => 'पत्ता आवश्यक आहे.';

  @override
  String get validEmailRequired =>
      'सलग डॉट्स किंवा सुरुवातीला डॉट्स नसलेला एक वैध ईमेल पत्ता प्रविष्ट करा.';

  @override
  String get districtRequired => 'जिल्हा आवश्यक आहे.';

  @override
  String get talukaRequired => 'तालुका आवश्यक आहे.';

  @override
  String get cityCorpRequired => 'शहर/महानगरपालिका आवश्यक आहे.';

  @override
  String get villageRequired => 'गाव आवश्यक आहे.';

  @override
  String get aadhaarVerificationRequired =>
      'कृपया पुढे जाण्यासाठी तुमचा आधार क्रमांक सत्यापित करा.';

  @override
  String get surveyNumberRequired => 'सर्वेक्षण क्रमांक आवश्यक आहे.';

  @override
  String get validGstRequired => 'एक वैध 15-अक्षरी GSTIN प्रविष्ट करा.';

  @override
  String get changeLanguageLaterHint =>
      'तुम्ही हे नंतर कधीही सेटिंग्जमध्ये बदलू शकता.';

  @override
  String get changeBtn => 'बदला';

  @override
  String get aadhaarDetailsSavedSuccessfully =>
      'आधार पडताळणी तपशील यशस्वीरित्या जतन केले';

  @override
  String get noInternetConnection => 'इंटरनेट कनेक्शन नाही';

  @override
  String get unableToLogin =>
      'लॉगिन करणे शक्य नाही. कृपया इंटरनेट कनेक्शन तपासा.';

  @override
  String get loginFailedMsg => 'लॉगिन अयशस्वी. कृपया पुन्हा प्रयत्न करा.';

  @override
  String get pleaseEnterFullName => 'कृपया आपले पूर्ण नाव प्रविष्ट करा.';

  @override
  String get pleaseEnterValidEmail => 'कृपया वैध ईमेल पत्ता प्रविष्ट करा.';

  @override
  String get profileSaveError =>
      'प्रोफाइल जतन करणे अयशस्वी. कृपया पुन्हा प्रयत्न करा.';

  @override
  String get aadhaarSendOtpError =>
      'आधार OTP पाठवणे अयशस्वी. कृपया पुन्हा प्रयत्न करा.';

  @override
  String get msgRegSuccessSignIn =>
      'नोंदणी यशस्वी! कृपया आपल्या मोबाइल नंबरने साइन इन करा.';

  @override
  String get errEnterMandatoryFields =>
      'कृपया सर्व अनिवार्य फील्ड प्रविष्ट करा.';

  @override
  String get msgRegSuccessLogin =>
      'नोंदणी यशस्वी! कृपया आपल्या मोबाइल नंबरने लॉगिन करा.';

  @override
  String get errEnterSiteName => 'कृपया साइटचे नाव प्रविष्ट करा';

  @override
  String get errEnterDeliveryAddress => 'कृपया वितरण पत्ता प्रविष्ट करा';

  @override
  String get msgEnquirySubmitted => 'खाण चालकाला चौकशी सादर केली!';

  @override
  String get msgDownloadingFile => 'फाईल डाउनलोड होत आहे... ';

  @override
  String get msgDownloadingAppFee => 'अर्ज शुल्क मागणी पत्र डाउनलोड होत आहे...';

  @override
  String get msgDownloadingGrasReceipt => 'GRAS शुल्क पावती डाउनलोड होत आहे...';

  @override
  String get msgDownloadingRoyaltyNote =>
      'रॉयल्टी मागणी पत्र डाउनलोड होत आहे...';

  @override
  String get msgDownloadingPermitOrder =>
      'अधिकृत उत्खनन परवानगी आदेश डाउनलोड होत आहे...';

  @override
  String get msgDraftSaved => 'मसुदा यशस्वीरित्या जतन केला.';

  @override
  String get errUploadMandatoryDocs =>
      'कृपया पुढे जाण्यापूर्वी सर्व अनिवार्य दस्तऐवज (*) अपलोड करा.';

  @override
  String get errAcceptDeclaration => 'कृपया वैधानिक गौण खनिज घोषणा स्वीकारा.';

  @override
  String get msgAppSubmitted => 'शुल्क भरून अर्ज यशस्वीरित्या सादर केला!';

  @override
  String get msgPinMapOverlay => 'पिन मॅप आच्छादन उघडले. स्थान सेट केले.';

  @override
  String get msgGpsCaptured => 'सध्याचे वाहन स्थान यशस्वीरित्या कॅप्चर केले.';

  @override
  String get msgAttachedReceipt => 'जोडलेली बँक पावती';

  @override
  String get msgDownloadedChallan => 'GRAS ई-चलन डाउनलोड केले';

  @override
  String get errStateEngPurpose =>
      'कृपया ड्रॉडाउनसाठी अभियांत्रिकी उद्देश सांगा';

  @override
  String get msgConsumptionLogged =>
      'वैधानिक ऑन-साइट वापर ड्रॉडाउन यशस्वीरित्या लॉग केले!';

  @override
  String get msgTransferEtpGenerated =>
      'ई-टीपी यशस्वीरित्या व्युत्पन्न! पास ड्रायव्हरसाठी तयार आहे.';

  @override
  String get msgTransitPassShared =>
      'व्हॉट्सअॅपवर ट्रान्झिट पास लिंक सामायिक केली!';

  @override
  String get msgGatePassReady => 'गेट पास प्रिंट / डाउनलोडसाठी तयार आहे.';

  @override
  String get errCannotCall => 'कॉल करू शकत नाही ';

  @override
  String get errEnterPackageName => 'कृपया पॅकेजचे नाव प्रविष्ट करा';

  @override
  String get msgPackageCreated => 'पॅकेज यशस्वीरित्या तयार केले!';

  @override
  String get errEnterProjectName => 'प्रकल्पाचे नाव प्रविष्ट करा.';

  @override
  String get errSelectGovDept => 'सरकारी विभाग निवडा किंवा प्रविष्ट करा.';

  @override
  String get errEnterOfficeName =>
      'जारी करणार्‍या/विभाग कार्यालयाचे नाव प्रविष्ट करा.';

  @override
  String get errEnterWorkOrder =>
      'कार्य आदेश / मंजुरी आदेश क्रमांक प्रविष्ट करा.';

  @override
  String get errEnterSiteAddress => 'साइटचा पत्ता प्रविष्ट करा.';

  @override
  String get msgCallingSupervisor => 'पर्यवेक्षकाला कॉल करत आहे...';

  @override
  String get msgOpeningWhatsapp => 'व्हॉट्सअॅप उघडत आहे...';

  @override
  String get msgActiveScopeSet => 'सक्रिय कार्यक्षेत्र सेट केले: ';

  @override
  String get errEnterSupervisorName => 'कृपया पर्यवेक्षकाचे नाव प्रविष्ट करा';

  @override
  String get errEnterSupervisorContact =>
      'कृपया पर्यवेक्षकाचा संपर्क तपशील प्रविष्ट करा';

  @override
  String get errEnterValidDigitp =>
      'कृपया वैध संख्यात्मक DigiTP क्रमांक प्रविष्ट करा.';

  @override
  String get inTransitVehiclesTitle => 'मार्गावरील वाहने';

  @override
  String get activeVehicleTracking => 'सक्रिय वाहन ट्रॅकिंग';

  @override
  String get activeVehicleTrackingDesc =>
      'रिअल-टाइम वाहन स्थान आणि ETA चे निरीक्षण करण्यासाठी मार्गावरील वाहन निवडा.';

  @override
  String get loadingInTransitVehicles => 'मार्गावरील वाहने लोड होत आहेत...';

  @override
  String get failedToLoadInTransitVehicles =>
      'मार्गावरील वाहने लोड करण्यात अयशस्वी';

  @override
  String get noVehiclesInTransit => 'कोणतीही वाहने मार्गावर नाहीत';

  @override
  String get noVehiclesInTransitDesc =>
      'आपल्या खात्यासाठी सध्या कोणतीही सक्रिय खनिज वाहने मार्गावर नाहीत.';

  @override
  String get refreshList => 'सूची रिफ्रेश करा';

  @override
  String get vehicleNA => 'वाहन उपलब्ध नाही';

  @override
  String get destinationNA => 'गंतव्य उपलब्ध नाही';

  @override
  String get gpsActive => 'वाहन सक्रिय';

  @override
  String get mineralAndQty => 'खनिज आणि प्रमाण:';

  @override
  String get destinationLabel => 'गंतव्य:';

  @override
  String get distanceLabel => 'अंतर:';

  @override
  String get driverLabel => 'चालक:';

  @override
  String get selectVehicleAndTrackLive => 'वाहन निवडा आणि थेट ट्रॅक करा';

  @override
  String get digiTpLabel => 'DigiTP:';

  @override
  String get inTransitStatus => 'मार्गावर';

  @override
  String get roleBuilder => 'बिल्डर';

  @override
  String get roleContractor => 'कंत्राटदार';

  @override
  String get roleGovernment => 'शासकीय';

  @override
  String get roleOrganization => 'संस्था';

  @override
  String get mineralStoneAgg20 => 'खडी २० मिमी';

  @override
  String get mineralRiverSand => 'नैसर्गिक वाळू';

  @override
  String get mineralMSand => 'एम-वाळू (M-Sand)';

  @override
  String get mineralMurrum => 'मुरूम / माती';

  @override
  String get noEnquiriesRaised => 'कोणतीही चौकशी केलेली नाही.';

  @override
  String get quotationAccepted =>
      'कोटेशन स्वीकारले! औपचारिक ऑर्डरमध्ये रूपांतरित झाले.';

  @override
  String get docOtherSupporting => 'इतर सहाय्यक दस्तऐवज';

  @override
  String get docSiteBoundary => 'जागा सीमा फोटो';

  @override
  String get docNoc => 'पर्यावरण / ग्रामपंचायत एनओसी';

  @override
  String get docUploadedSuccess => 'दस्तऐवज यशस्वीरित्या अपलोड केले!';

  @override
  String get queryResponseSubmitted =>
      'चौकशी प्रतिसाद यशस्वीरित्या सबमिट केला!';

  @override
  String get mineralStoneAgg20Basalt => 'खडी २० मिमी (बेसाल्ट)';

  @override
  String get appBlocked => 'ॲप ब्लॉक केले';

  @override
  String get accountBlockedLogout =>
      'आपले ॲप ब्लॉक केले गेले आहे. आपण लॉग आउट व्हाल.';

  @override
  String get whatsapp => 'व्हॉट्सॲप';

  @override
  String get gatePass => 'गेट पास';

  @override
  String get noMineralsStockPoint => 'या साठा बिंदूसाठी खनिजे सूचीबद्ध नाहीत.';

  @override
  String get noOrdersPlaced => 'अद्याप कोणतीही ऑर्डर दिली नाही.';

  @override
  String get noDeliveriesRecorded => 'कोणत्याही वितरणाची नोंद नाही.';

  @override
  String get discoverQuarries => 'या पॅकेजसाठी जवळील खाणी शोधा';

  @override
  String get scanQrCodeTruck => 'गेटवर ट्रकचा क्यूआर कोड स्कॅन करा';

  @override
  String get issueTransferEtp => 'अतिरिक्त खनिजासाठी ट्रान्सफर ई-टीपी जारी करा';

  @override
  String get noProjectsRegistered => 'कोणतेही प्रकल्प नोंदणीकृत नाहीत.';

  @override
  String get noPackagesAdded => 'या प्रकल्पात अद्याप पॅकेज जोडलेले नाहीत.';

  @override
  String get supervisorRegistered => 'पर्यवेक्षक यशस्वीरित्या नोंदणीकृत!';

  @override
  String get invalidDigiTpNumber =>
      'कृपया वैध अंकीय डिजी-टीपी क्रमांक प्रविष्ट करा';

  @override
  String get deliveryNotFound => 'वितरण सापडले नाही';

  @override
  String get langEnglish => 'English (EN)';

  @override
  String get langHindi => 'हिंदी (HI)';

  @override
  String get langMarathi => 'मराठी (MR)';

  @override
  String get errorUpdatingProfile => 'प्रोफाइल अपडेट करताना त्रुटी आली: ';

  @override
  String get errorPrefix => 'त्रुटी: ';

  @override
  String get downloadedReceipt => 'डाउनलोड केलेली पावती: DigiTP_Receipt_';

  @override
  String get statusNotReceived => 'प्राप्त झाले नाही';

  @override
  String get statusArrivedAtSite => 'जागेवर पोहोचले';

  @override
  String get statusPassIssued => 'पास जारी केला';

  @override
  String get authorizedQuarry => 'अधिकृत खाण';

  @override
  String financialYear(String yearRange) {
    return 'आर्थिक वर्ष $yearRange';
  }

  @override
  String get verifyDigiTp => 'डिजी-टीपी पडताळा';

  @override
  String get removeBtn => 'काढून टाका';

  @override
  String get contactPersonNameLabel => 'संपर्क व्यक्तीचे नाव';

  @override
  String get contactPersonNameHint => 'संपर्क व्यक्तीचे नाव प्रविष्ट करा';

  @override
  String get contactPersonNameRequired => 'संपर्क व्यक्तीचे नाव आवश्यक आहे.';

  @override
  String get orgPanRequired => 'संस्थेचा पॅन नंबर आवश्यक आहे.';

  @override
  String get validPanRequired =>
      '10 वर्णांचा वैध पॅन प्रविष्ट करा (उदा. ABCDE1234F).';

  @override
  String get organisationDetailsHeader => 'संस्था तपशील';

  @override
  String get contactPersonDetailsHeader => 'संपर्क व्यक्ती तपशील';

  @override
  String get locationDetailsHeader => 'ठिकाण तपशील';

  @override
  String get orgNameRequiredLabel => 'संस्थेचे नाव *';

  @override
  String get emailIdRequiredLabel => 'ईमेल आयडी *';

  @override
  String get addressRequiredLabel => 'पत्ता *';

  @override
  String get contactPersonNameRequiredLabel => 'संपर्क व्यक्तीचे नाव *';

  @override
  String get mobileNumberRequiredLabel => 'मोबाईल क्र. *';

  @override
  String get contactPersonAadhaarOptionalLabel =>
      'संपर्क व्यक्ती आधार क्र. (पर्यायी)';

  @override
  String get enterOrgNameHint => 'संस्था / कंपनी / फर्मचे नाव प्रविष्ट करा';

  @override
  String get enterEmailHint => 'ईमेल पत्ता प्रविष्ट करा';

  @override
  String get registeredOfficeAddressHint => 'नोंदणीकृत कार्यालयाचा पत्ता';

  @override
  String get enterContactPersonNameHint => 'संपर्क व्यक्तीचे नाव प्रविष्ट करा';

  @override
  String get enterTenDigitMobileHint => '१० अंकी मोबाईल क्रमांक प्रविष्ट करा';

  @override
  String get enterTwelveDigitAadhaarHint => '१२ अंकी आधार क्रमांक प्रविष्ट करा';

  @override
  String get emailRequired => 'ईमेल आयडी आवश्यक आहे.';

  @override
  String get enterValidAadhaarNumber =>
      'वैध १२ अंकी आधार क्रमांक प्रविष्ट करा.';

  @override
  String get aadhaarCannotStartWithZeroOrOne =>
      'आधार क्रमांक ० किंवा १ ने सुरू होऊ शकत नाही.';

  @override
  String get aadhaarAlreadyRegistered =>
      'हा आधार कार्ड क्रमांक महाखनिज प्रणालीमध्ये आधीपासूनच नोंदणीकृत आहे.';

  @override
  String get invalidAadhaarNumber =>
      'अवैध आधार क्रमांक प्रविष्ट केला आहे. कृपया तपासा आणि पुन्हा प्रयत्न करा.';

  @override
  String get aadhaarSendOtpFailed =>
      'आधार नोंदणीकृत मोबाईल क्रमांकावर ओटीपी पाठवण्यात अयशस्वी.';

  @override
  String get contactPersonAadhaarVerificationTitle =>
      'संपर्क व्यक्ती आधार\\nपडताळणी';

  @override
  String get orgPanVerificationTitle => 'संस्था पॅन पडताळणी';

  @override
  String get verifiedStatus => 'पडताळणी पूर्ण';

  @override
  String get notVerifiedStatus => 'पडताळणी अपूर्ण';

  @override
  String get uploadAadhaarDocOptional => 'आधार दस्तऐवज अपलोड करा (पर्यायी)';

  @override
  String get chooseAadhaarCardPhotoPdf => 'आधार कार्ड फोटो / पीडीएफ निवडा';

  @override
  String get otpSentToAadhaarMobileNotice =>
      'तुमच्या आधार नोंदणीकृत मोबाईल क्रमांकावर ओटीपी पाठवला जाईल';

  @override
  String get resendOtpBtn => 'ओटीपी पुन्हा पाठवा';

  @override
  String get enterSixDigitOtpHint => '६ अंकी ओटीपी प्रविष्ट करा';

  @override
  String get enterValidAadhaarOtp => 'वैध ६ अंकी आधार ओटीपी प्रविष्ट करा.';

  @override
  String get panNoOptionalLabel => 'पॅन क्र. (पर्यायी)';

  @override
  String get enterTenDigitPan => '१० अंकी पॅन प्रविष्ट करा';

  @override
  String get uploadPanDocOptional => 'पॅन दस्तऐवज अपलोड करा (पर्यायी)';

  @override
  String get choosePanCardPhotoPdf => 'पॅन कार्ड फोटो / पीडीएफ निवडा';

  @override
  String get verifyPanBtn => 'पॅन पडताळणी करा';

  @override
  String get panStatusPrefix => 'स्थिती: ';

  @override
  String get panAlreadyRegistered =>
      'हा पॅन क्रमांक महाखनिज प्रणालीमध्ये आधीपासूनच नोंदणीकृत आहे.';

  @override
  String get invalidPanNumber =>
      'अवैध पॅन क्रमांक प्रविष्ट केला आहे. कृपया तपासा आणि पुन्हा प्रयत्न करा.';

  @override
  String get panVerificationFailed =>
      'पॅन पडताळणी अयशस्वी झाली. कृपया पुन्हा प्रयत्न करा.';

  @override
  String get orgDeclarationText =>
      'मी पुष्टी करतो/करते की वर दिलेली माहिती खरी आणि अचूक आहे. माहिती चुकीची आढळल्यास, मी लागू कायदेशीर कारवाईस पात्र राहीन याची मला जाणीव आहे.';

  @override
  String get confirmDeclarationRequired =>
      'नोंदणी पूर्ण करण्यासाठी कृपया घोषणेची पुष्टी करा.';

  @override
  String get organisationConsumer => 'संस्था ग्राहक';

  @override
  String get individualConsumer => 'वैयक्तिक ग्राहक';

  @override
  String get requiresOrgKycSubtitle =>
      'संपर्क व्यक्ती आधार आणि संस्था पॅन आवश्यक';

  @override
  String get requiresIndividualKycSubtitle => 'वैयक्तिक आधार पडताळणी आवश्यक';

  @override
  String get pendingBadge => 'प्रलंबित';

  @override
  String get contactPersonAadhaarVerified =>
      'संपर्क व्यक्ती आधार पडताळणी पूर्ण';

  @override
  String get contactPersonAadhaarPending => 'संपर्क व्यक्ती आधार प्रलंबित';

  @override
  String get authContactPersonIdentity => 'अधिकृत संपर्क व्यक्ती ओळख';

  @override
  String get nationalIdentityUidai => 'राष्ट्रीय ओळख (UIDAI)';

  @override
  String get contactPersonAadhaar => 'संपर्क व्यक्ती आधार';

  @override
  String get orgPanVerified => 'संस्था पॅन पडताळणी पूर्ण';

  @override
  String get orgPanPending => 'संस्था पॅन प्रलंबित';

  @override
  String get incomeTaxDeptEntityPan => 'आयकर विभाग (संस्था पॅन)';

  @override
  String get orgPan => 'संस्था पॅन';

  @override
  String get verifyPanArrow => 'पॅन पडताळणी करा →';

  @override
  String get kycDetailsSavedSuccessfully =>
      'केवायसी पडताळणी तपशील यशस्वीरित्या जतन केले';

  @override
  String get orgPanInfoTitle => 'संस्था पॅन माहिती';

  @override
  String get verifyOrgPanDesc =>
      'संस्थेचा पॅन क्रमांक पडताळा आणि पॅन दस्तऐवजाची प्रत अपलोड करा';

  @override
  String get panNumberLabel => 'पॅन क्रमांक';

  @override
  String get panVerificationLabel => 'पॅन पडताळणी';

  @override
  String get verifiedUpper => 'पडताळणी पूर्ण';

  @override
  String get pendingUpper => 'प्रलंबित';

  @override
  String get method1LivePanVerification => 'पद्धत १: थेट पॅन पडताळणी';

  @override
  String get orgPanNumberRequired => 'संस्था पॅन क्रमांक *';

  @override
  String get method2UploadPanCard =>
      'पद्धत २: पॅन कार्ड दस्तऐवज अपलोड करा (पीडीएफ / प्रतिमा)';

  @override
  String get choosePanPdfOrImage => 'पॅन पीडीएफ किंवा प्रतिमा निवडा';

  @override
  String get uploadingDots => 'अपलोड होत आहे...';

  @override
  String get verifyOrgPanBeforeSaving =>
      'कृपया जतन करण्यापूर्वी आपल्या संस्थेचा पॅन पडताळून घ्या.';

  @override
  String get loadingConsumerProfile => 'ग्राहक प्रोफाइल लोड होत आहे...';

  @override
  String get failedToFetchConsumerProfile =>
      'ग्राहक प्रोफाइल मिळवण्यात अयशस्वी';

  @override
  String get retryLoadingProfile => 'प्रोफाइल लोड करण्याचा पुन्हा प्रयत्न करा';

  @override
  String resendInSeconds(String seconds) {
    return '00:$seconds मध्ये पुन्हा पाठवा';
  }

  @override
  String verifiedCountSummary(String verifiedCount, String totalDocs) {
    return '$totalDocs पैकी $verifiedCount पडताळणी पूर्ण';
  }

  @override
  String get clientSessionExpired =>
      'क्लायंट सत्र संपले आहे. कृपया पुन्हा OTP पाठवा.';

  @override
  String get invalidAadhaarOtp =>
      'अवैध आधार OTP. कृपया तपासा आणि पुन्हा प्रयत्न करा.';

  @override
  String get uploadFailedWithReason => 'अपलोड अयशस्वी: ';

  @override
  String get docUploadFailed =>
      'दस्तऐवज अपलोड अयशस्वी. कृपया पुन्हा प्रयत्न करा.';

  @override
  String get panDocUploadFailed =>
      'पॅन दस्तऐवज अपलोड अयशस्वी. कृपया पुन्हा प्रयत्न करा.';

  @override
  String get failedToUpdateProfile => 'ग्राहक प्रोफाइल अपडेट करण्यात अयशस्वी.';
}
