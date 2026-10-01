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
  String get digitpDeliveries => 'डिजी-टीपी\nजारी केले';

  @override
  String get receivedMaterial => 'डिजी-टीपी\nप्राप्त झाले';

  @override
  String get inTransitVehicles => 'मार्गातील\nवाहने';

  @override
  String get coreServices => 'मुख्य सेवा';

  @override
  String get digitpPasses => 'डिजी-टीपी\nपास';

  @override
  String get receiveMaterialAction => 'सामग्री\nप्राप्त करा';

  @override
  String get trackVehicle => 'वाहन\nट्रॅक करा';

  @override
  String get recentDeliveriesHeader => 'डिजी-टीपी आणि खनिज वितरण';

  @override
  String get viewAll => 'सर्व पहा';

  @override
  String get noRecentDeliveries =>
      'कोणतेही अलीकडील डिजी-टीपी वितरण आढळले नाही.';

  @override
  String get receiveMaterial => 'सामग्री प्राप्त करा';

  @override
  String get receiveMaterialError => 'सामग्री प्राप्त करताना त्रुटी';

  @override
  String get scanDigiTp => 'डिजी-टीपी क्यूआर / बारकोड स्कॅन करा';

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
  String get ownerName => 'मालकाचे नाव';

  @override
  String get ownerMobile => 'मालकाचा मोबाईल';

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
    return '$vehicleNo साठी लाईव्ह जीपीएस स्थान प्राप्त करत आहे...';
  }

  @override
  String get connectingToMahakhanij =>
      'महाखनिज जीपीएस ट्रॅकिंग सेवेशी कनेक्ट होत आहे';

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
  String get refreshLocation => 'स्थान रीफ्रेश करा';

  @override
  String get inTransit => 'प्रवासात';

  @override
  String get delivered => 'वितरित';

  @override
  String get enquiries => 'चौकशी';

  @override
  String get noActiveDeliveries => 'कोणतेही सक्रिय वितरण नाही';

  @override
  String get noDeliveriesInTransitDesc => 'सध्या प्रवासात कोणतेही वितरण नाही.';

  @override
  String get noDeliveredItems => 'कोणतेही वितरित आयटम नाहीत';

  @override
  String get noDeliveriesReceivedDesc =>
      'तुम्हाला अद्याप कोणतेही वितरण मिळालेले नाही.';

  @override
  String get noActiveEnquiries => 'कोणतीही सक्रिय चौकशी नाही';

  @override
  String get noActiveEnquiriesDesc => 'सध्या कोणतीही सक्रिय चौकशी नाही.';

  @override
  String get source => 'स्त्रोत';

  @override
  String get validity => 'वैधता';

  @override
  String get viewDigiTp => 'डिजी-टीपी पहा';

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
  String get quarrySeller => 'खाण / विक्रेता';

  @override
  String get digiTpNo => 'डिजी-टीपी क्र.';

  @override
  String get vehicleDriverName => 'वाहन चालकाचे नाव';

  @override
  String get driverMobileNumber => 'चालकाचा मोबाईल नंबर';

  @override
  String get ownerMobileNumber => 'मालकाचा मोबाईल नंबर';

  @override
  String get plotProjectName => 'प्लॉट / प्रकल्पाचे नाव';

  @override
  String get invoiceStatus => 'चलनाची स्थिती';

  @override
  String get createdDateAndTimeOfDigiTp => 'डिजी-टीपीची निर्मिती तारीख आणि वेळ';

  @override
  String get digiTpValidityDateAndTime => 'डिजी-टीपी वैधता तारीख आणि वेळ';

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
  String get saveChanges => 'बदल जतन करा';

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
  String get liveVehicleTracking => 'थेट वाहन ट्रॅकिंग';

  @override
  String get liveGps => 'थेट जीपीएस';

  @override
  String get currentGpsLocation => 'सध्याचे जीपीएस स्थान';

  @override
  String get trackingLiveGps => 'थेट जीपीएस ट्रॅक करत आहे';

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
      'सध्या या वाहनाशी संबंधित कोणतेही सक्रिय डिजी-टीपी प्रवास तपशील नाहीत.';

  @override
  String get mobileNumberUnavailable => 'मोबाईल नंबर उपलब्ध नाही';

  @override
  String get enterVehicleNo => 'वाहन क्रमांक प्रविष्ट करा';

  @override
  String get enterDigiTpNumber => 'डिजी-टीपी नंबर प्रविष्ट करा';

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
      'तुमचे वैयक्तिक संपर्क आणि वितरण गंतव्य तपशील प्रविष्ट करा.';

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
  String get continueToKyc => 'KYC पडताळणीसाठी पुढे जा';

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
  String get districtLabel => 'जिल्हा *';

  @override
  String get selectDistrictHint => 'जिल्हा निवडा';

  @override
  String get loadingDistricts => 'जिल्हे लोड करत आहे...';

  @override
  String get talukaLabel => 'तालुका *';

  @override
  String get talukaHint => 'उदा. हवेली';

  @override
  String get loading => 'लोड करत आहे...';

  @override
  String get cityCorporationLabel => 'शहर / महानगरपालिका';

  @override
  String get villageRuralLabel => 'गाव / ग्रामीण भाग';

  @override
  String get cityCorporationHint => 'उदा. पुणे शहर (PMC)';

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
  String get sendOtpBtn => 'OTP पाठवा';

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
  String get digitpsReceived => 'प्राप्त झालेले DigiTP';

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
  String get noDeliveriesFound => 'कोणतीही डिलिव्हरी आढळली नाही';

  @override
  String get noDeliveriesFoundDesc => 'तुमच्याकडे कोणतेही DigiTP पास नाहीत.';

  @override
  String get fetchingConsumerDigiTpRecords =>
      'ग्राहक DigiTP रेकॉर्ड आणत आहे...';

  @override
  String get failedToLoadDigiTpList => 'DigiTP सूची लोड करण्यात अयशस्वी';
}
