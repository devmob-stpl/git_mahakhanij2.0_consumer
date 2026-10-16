// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get appName => 'महाखनिज';

  @override
  String get language => 'भाषा';

  @override
  String get settings => 'सेटिंग्स';

  @override
  String get home => 'होम';

  @override
  String get profile => 'प्रोफ़ाइल';

  @override
  String get welcome => 'स्वागत है';

  @override
  String get digitpDeliveries => 'डिजीटीपी\nजारी किए गए';

  @override
  String get receivedMaterial => 'डिजीटीपी\nप्राप्त हुए';

  @override
  String get inTransitVehicles => 'मार्ग में\nवाहन';

  @override
  String get coreServices => 'मुख्य सेवाएँ';

  @override
  String get digitpPasses => 'डिजीटीपी\nपास';

  @override
  String get receiveMaterialAction => 'सामग्री\nप्राप्त करें';

  @override
  String get trackVehicle => 'वाहन\nट्रैक करें';

  @override
  String get recentDeliveriesHeader => 'डिजीटीपी और खनिज वितरण';

  @override
  String get viewAll => 'सभी देखें';

  @override
  String get noRecentDeliveries => 'कोई हालिया डिजीटीपी वितरण नहीं मिला।';

  @override
  String get receiveMaterial => 'सामग्री प्राप्त करें';

  @override
  String get receiveMaterialError => 'सामग्री प्राप्त करने में त्रुटि';

  @override
  String get scanDigiTp => 'डिजीटीपी क्यूआर / बारकोड स्कैन करें';

  @override
  String get pointCameraDescription =>
      'परमिट विवरण निकालने और सामग्री रसीद की पुष्टि करने के लिए कैमरे को ड्राइवर के क्यूआर कोड या बारकोड पर इंगित करें।';

  @override
  String get openCameraScanner => 'कैमरा स्कैनर खोलें';

  @override
  String get enterInvoiceManually => 'मैन्युअल रूप से चालान संख्या दर्ज करें';

  @override
  String get processingScan => 'स्कैन संसाधित कर रहा है...';

  @override
  String get decodingPermit => 'परमिट पेलोड डिकोड कर रहा है...';

  @override
  String get ok => 'ठीक है';

  @override
  String get eTransitPassDetails => 'ई-ट्रांजिट पास विवरण';

  @override
  String get invoiceHash => 'चालान #';

  @override
  String get vehicleNumber => 'वाहन नंबर';

  @override
  String get ownerName => 'मालिक का नाम';

  @override
  String get ownerMobile => 'मालिक का मोबाइल';

  @override
  String get driverDetails => 'चालक का विवरण';

  @override
  String get materialAndQuantity => 'सामग्री और मात्रा';

  @override
  String get destination => 'गंतव्य';

  @override
  String get distanceKm => 'दूरी (किमी)';

  @override
  String get validityFrom => 'से मान्य';

  @override
  String get validityUpto => 'तक मान्य';

  @override
  String get confirmingReceipt => 'रसीद की पुष्टि कर रहा है...';

  @override
  String get confirmAndReceiveMaterial => 'पुष्टि करें और सामग्री प्राप्त करें';

  @override
  String get track => 'ट्रैक करें';

  @override
  String fetchingLiveGpsLocation(String vehicleNo) {
    return '$vehicleNo के लिए लाइव वाहन स्थान प्राप्त कर रहा है...';
  }

  @override
  String get connectingToMahakhanij =>
      'महाखनिज वाहन ट्रैकिंग सेवा से जुड़ रहा है';

  @override
  String get trackingDataUnavailable => 'ट्रैकिंग डेटा अनुपलब्ध';

  @override
  String get retryFetching => 'पुनः प्राप्त करें';

  @override
  String get tryDemoVehicle => 'डेमो वाहन आज़माएं';

  @override
  String noLocationDataFor(String vehicleNo) {
    return '$vehicleNo के लिए कोई स्थान डेटा नहीं';
  }

  @override
  String get refreshLocation => 'स्थान ताज़ा करें';

  @override
  String get inTransit => 'रास्ते में';

  @override
  String get delivered => 'वितरित';

  @override
  String get enquiries => 'पूछताछ';

  @override
  String get noActiveDeliveries => 'कोई सक्रिय वितरण नहीं';

  @override
  String get noDeliveriesInTransitDesc =>
      'वर्तमान में रास्ते में कोई वितरण नहीं है।';

  @override
  String get noDeliveredItems => 'कोई वितरित आइटम नहीं';

  @override
  String get noDeliveriesReceivedDesc =>
      'आपको अभी तक कोई वितरण प्राप्त नहीं हुआ है।';

  @override
  String get noActiveEnquiries => 'कोई सक्रिय पूछताछ नहीं';

  @override
  String get noActiveEnquiriesDesc => 'वर्तमान में कोई सक्रिय पूछताछ नहीं है।';

  @override
  String get source => 'स्रोत';

  @override
  String get validity => 'वैधता';

  @override
  String get viewDigiTp => 'डिजीटीपी देखें';

  @override
  String get cancelEnquiry => 'पूछताछ रद्द करें';

  @override
  String get cancelling => 'रद्द कर रहा है...';

  @override
  String get activityTab => 'डिजीटीपी';

  @override
  String get mineral => 'खनिज';

  @override
  String get qty => 'मात्रा';

  @override
  String get vehicle => 'वाहन';

  @override
  String get driver => 'ड्राइवर';

  @override
  String get quarrySeller => 'खदान / विक्रेता';

  @override
  String get digiTpNo => 'डिजीटीपी नंबर';

  @override
  String get vehicleDriverName => 'वाहन चालक का नाम';

  @override
  String get driverMobileNumber => 'चालक का मोबाइल नंबर';

  @override
  String get ownerMobileNumber => 'मालिक का मोबाइल नंबर';

  @override
  String get plotProjectName => 'प्लॉट / परियोजना का नाम';

  @override
  String get invoiceStatus => 'चालान की स्थिति';

  @override
  String get createdDateAndTimeOfDigiTp => 'डिजीटीपी के निर्माण की तिथि और समय';

  @override
  String get digiTpValidityDateAndTime => 'डिजीटीपी वैधता तिथि और समय';

  @override
  String get profileName => 'नाम';

  @override
  String get profileMobile => 'मोबाइल नंबर';

  @override
  String get profileEmail => 'ईमेल';

  @override
  String get profileAddress => 'पता';

  @override
  String get profileDistrict => 'ज़िला';

  @override
  String get profileTaluka => 'तालुका';

  @override
  String get profileCityVillage => 'शहर / गाँव';

  @override
  String get profilePincode => 'पिनकोड';

  @override
  String get saveBtn => 'सहेजें';

  @override
  String get saveChanges => 'परिवर्तन सहेजें';

  @override
  String get aadhaarKyc => 'आधार केवाईसी';

  @override
  String get verifyAadhaar => 'आधार सत्यापित करें';

  @override
  String get uploadDocument => 'दस्तावेज़ अपलोड करें';

  @override
  String get viewDocument => 'दस्तावेज़ देखें';

  @override
  String get aadhaarVerified => 'सत्यापित';

  @override
  String get aadhaarPending => 'लंबित';

  @override
  String get rural => 'ग्रामीण';

  @override
  String get urban => 'शहरी';

  @override
  String get residentialDetails => 'आवासीय विवरण';

  @override
  String get personalDetails => 'व्यक्तिगत विवरण';

  @override
  String get liveVehicleTracking => 'वाहन ट्रैक करें';

  @override
  String get liveGps => 'लाइव वाहन';

  @override
  String get currentGpsLocation => 'वर्तमान वाहन स्थान';

  @override
  String get trackingLiveGps => 'लाइव वाहन ट्रैक कर रहा है';

  @override
  String get speed => 'गति';

  @override
  String get lastUpdated => 'अंतिम अपडेट';

  @override
  String get tripDetails => 'यात्रा विवरण';

  @override
  String get tripId => 'ट्रिप आईडी';

  @override
  String get originQuarryPlot => 'मूल / खदान प्लॉट';

  @override
  String get destinationSite => 'गंतव्य स्थल';

  @override
  String get totalDistance => 'कुल दूरी';

  @override
  String get validFrom => 'से मान्य';

  @override
  String get validUpto => 'तक मान्य';

  @override
  String get noActiveDigiTpTripDetails =>
      'इस समय इस वाहन से जुड़ा कोई सक्रिय डिजीटीपी यात्रा विवरण नहीं है।';

  @override
  String get mobileNumberUnavailable => 'मोबाइल नंबर उपलब्ध नहीं है';

  @override
  String get enterVehicleNo => 'वाहन नंबर दर्ज करें';

  @override
  String get enterDigiTpNumber => 'डिजीटीपी नंबर दर्ज करें';

  @override
  String get enterDigiTpNumberHint => 'उदा. 491 या 0436610';

  @override
  String get cancel => 'रद्द करें';

  @override
  String get fetchDetails => 'विवरण प्राप्त करें';

  @override
  String get scanAnotherCode => 'अन्य कोड स्कैन करें';

  @override
  String get viewAllReceivedDeliveries => 'सभी प्राप्त वितरण देखें';

  @override
  String get materialReceivedSuccess => 'सामग्री सफलतापूर्वक प्राप्त हुई!';

  @override
  String get govtOfMaharashtra => 'महाराष्ट्र सरकार';

  @override
  String get revenueDepartment => 'महसूल विभाग';

  @override
  String get minorMineralTransportSystem => 'गौण खनिज परिवहन प्रणाली';

  @override
  String get revenueDeptMsg => 'महसूल विभाग, महाराष्ट्र सरकार';

  @override
  String get welcomeTitle => 'खनिज, स्रोत से साइट तक';

  @override
  String get welcomeSubtitle =>
      'खनिज स्थान खोजें, पूछताछ करें, वाहन को ट्रैक करें, सत्यापित करें कि क्या आता है, और जो आप उपयोग करते हैं उसे प्रबंधित करें।';

  @override
  String get signIn => 'साइन इन करें';

  @override
  String get createAccount => 'नया खाता बनाएँ';

  @override
  String get loginHeading => 'लॉग इन';

  @override
  String get mobileNumberHint => 'मोबाइल नंबर';

  @override
  String waitSeconds(String seconds) {
    return 'कृपया $seconds सेकंड प्रतीक्षा करें';
  }

  @override
  String get resendOtp => 'ओटीपी पुनः भेजें';

  @override
  String get invalidMobileError =>
      'एक मान्य 10-अंकीय भारतीय मोबाइल नंबर दर्ज करें।';

  @override
  String get invalidOtpError => 'कृपया पूरा 5-अंकीय OTP दर्ज करें।';

  @override
  String get getOtpBtn => 'ओटीपी प्राप्त करें';

  @override
  String get loginBtn => 'लॉग इन करें';

  @override
  String get newMemberMsg => 'नये सदस्य हैं? ';

  @override
  String get signUpLink => 'साइन अप करें';

  @override
  String get chooseAccountType => 'खाता प्रकार चुनें';

  @override
  String get howWillYouUse => 'आप महाखनिज का उपयोग कैसे करेंगे?';

  @override
  String get chooseAccountDesc =>
      'यह तय करता है कि ऐप आपको क्या दिखाता है। इसे बाद में बदला नहीं जा सकता।';

  @override
  String get individual => 'व्यक्तिगत';

  @override
  String get individualDesc =>
      'व्यक्तिगत उपयोग के लिए खनिज खरीदने वाले व्यक्ति के लिए।';

  @override
  String get organization => 'संगठन';

  @override
  String get organizationDesc =>
      'प्रोजेक्ट्स और पैकेजों में काम करने वाले बिल्डर, ठेकेदार, सरकारी निकाय या किसी अन्य संगठन के लिए।';

  @override
  String get alreadyHaveAccount => 'क्या आपके पास पहले से एक खाता है? ';

  @override
  String get basicAndAddressDetails => 'मूल और पता विवरण';

  @override
  String get enterPersonalContact => 'अपना व्यक्तिगत संपर्क विवरण दर्ज करें।';

  @override
  String get fullName => 'पूरा नाम';

  @override
  String get mobileNumber => 'मोबाइल नंबर';

  @override
  String get tenDigitNumber => '10-अंकीय नंबर';

  @override
  String get weWillSendVerification =>
      'हम इस नंबर पर 5 अंकों का सत्यापन कोड भेजेंगे।';

  @override
  String get orgNameLabel => 'संगठन का नाम';

  @override
  String get orgTypeLabel => 'संगठन का प्रकार';

  @override
  String get gstinLabel => 'जीएसटीआईएन (GSTIN)';

  @override
  String get continueBtn => 'जारी रखें';

  @override
  String get continueToKyc => 'आगे बढ़ें';

  @override
  String get completeRegistration => 'पंजीकरण पूरा करें';

  @override
  String get skipAadhaar => 'आधार सत्यापन छोड़ें और साइनअप पूरा करें';

  @override
  String stepOf(int step, int total) {
    return 'चरण $step / $total';
  }

  @override
  String get personaIndividualDesc => 'व्यक्तिगत और गृह निर्माण';

  @override
  String get personaOrganizationDesc =>
      'इन्फ्रास्ट्रक्चर और वाणिज्यिक परियोजनाएं';

  @override
  String get whereDeliverMineral => 'खनिज कहाँ पहुँचाया जाना चाहिए?';

  @override
  String get areaClassificationLabel => 'क्षेत्र वर्गीकरण';

  @override
  String get urbanCity => 'शहरी (शहर)';

  @override
  String get ruralVillage => 'ग्रामीण (गाँव)';

  @override
  String get districtLabel => 'जिला';

  @override
  String get selectDistrictHint => 'जिला चुनें';

  @override
  String get loadingDistricts => 'जिले लोड हो रहे हैं...';

  @override
  String get talukaLabel => 'तालुका';

  @override
  String get talukaHint => 'उदा. हवेली';

  @override
  String get loading => 'लोड हो रहा है...';

  @override
  String get cityCorporationLabel => 'शहर / निगम';

  @override
  String get villageRuralLabel => 'गाँव / ग्रामीण क्षेत्र';

  @override
  String get cityCorporationHint => 'उदा. पुणे शहर';

  @override
  String get villageRuralHint => 'उदा. नारायणगांव';

  @override
  String get addressLabel => 'पता (घर / फ्लैट / सड़क / क्षेत्र)';

  @override
  String get addressHint => 'प्लॉट / मकान नं., भवन, क्षेत्र / सड़क';

  @override
  String get pincodeLabel => 'पिन कोड';

  @override
  String get pincodeHint => '6-अंकीय पिन कोड';

  @override
  String get profileScreenTitle => 'उपभोक्ता प्रोफ़ाइल और केवाईसी';

  @override
  String get settingsScreenTitle => 'सेटिंग्स';

  @override
  String get cameraBtn => 'कैमरा';

  @override
  String get galleryBtn => 'गैलरी';

  @override
  String get fileDocumentBtn => 'फ़ाइल दस्तावेज़';

  @override
  String get aadhaarEkycInfoTitle => 'आधार ई-केवाईसी जानकारी';

  @override
  String get aadhaarNumberLabel => 'आधार संख्या';

  @override
  String get aadhaarVerificationLabel => 'आधार सत्यापन';

  @override
  String get aadhaarDocumentUrlLabel => 'आधार दस्तावेज़ URL';

  @override
  String get closeBtn => 'बंद करें';

  @override
  String get verifyAadhaarBtn => 'आधार सत्यापित करें';

  @override
  String get aadhaarIdentityVerificationTitle => 'आधार पहचान सत्यापन';

  @override
  String get aadhaarIdentityVerificationDesc =>
      'अपना आधार OTP सत्यापित करें या दस्तावेज़ फ़ोटो अपलोड करें';

  @override
  String get method1LiveOtp => 'विधि 1: लाइव OTP सत्यापन';

  @override
  String get twelveDigitAadhaarNumber => '12-अंकीय आधार संख्या *';

  @override
  String get enterTwelveDigitAadhaar => '12 अंकों का आधार दर्ज करें';

  @override
  String get sendOtpBtn => 'OTP भेजें';

  @override
  String get sixDigitAadhaarOtp => '6-अंकीय आधार OTP *';

  @override
  String get enterSixDigitOtp => '6 अंकों का OTP दर्ज करें';

  @override
  String get verifyOtpBtn => 'OTP सत्यापित करें';

  @override
  String get method2UploadAadhaar =>
      'विधि 2: आधार कार्ड दस्तावेज़ अपलोड करें (PDF / चित्र)';

  @override
  String get uploadAadhaarDesc =>
      'महाखनिज दस्तावेज़ सर्वर के माध्यम से अपलोड करने के लिए दस्तावेज़ फ़ाइल चुनें';

  @override
  String get chooseAadhaarPdfOrImage => 'आधार PDF या चित्र चुनें';

  @override
  String get uploadingToMahakhanijServer =>
      'महाखनिज सर्वर पर अपलोड हो रहा है...';

  @override
  String get replaceBtn => 'बदलें';

  @override
  String get uploadBtn => 'अपलोड करें';

  @override
  String get retryBtn => 'पुनः प्रयास करें';

  @override
  String get aadhaarVerificationCompleted => 'आधार सत्यापन पूर्ण हुआ!';

  @override
  String get aadhaarVerificationSuccessDesc =>
      'महाराष्ट्र सरकार के साथ आधार क्रेडेंशियल्स सफलतापूर्वक सत्यापित किए गए।';

  @override
  String get doneBtn => 'पूर्ण';

  @override
  String get reports => 'रिपोर्ट';

  @override
  String get last30Days => 'पिछले 30 दिन';

  @override
  String get quarterly => 'त्रैमासिक';

  @override
  String get fy2425 => 'वित्तीय वर्ष 24-25';

  @override
  String get filterByQuarry => 'खदान (पार्टी) द्वारा फ़िल्टर करें';

  @override
  String get allQuarries => 'सभी खदानें';

  @override
  String get errorLoadingPlots => 'प्लॉट लोड करने में त्रुटि';

  @override
  String get noDataAvailable => 'कोई डेटा उपलब्ध नहीं';

  @override
  String get totalReceived => 'कुल प्राप्त';

  @override
  String get digitpsReceived => 'प्राप्त डिजीटीपी';

  @override
  String get passes => 'पास';

  @override
  String get mineralProcurementBreakdown => 'खनिज खरीद विवरण';

  @override
  String get byVolume => 'मात्रा के अनुसार';

  @override
  String get noMaterialsFound => 'कोई सामग्री नहीं मिली';

  @override
  String get errorLoadingReport => 'रिपोर्ट लोड करने में त्रुटि: ';

  @override
  String get units => 'युनिट्स';

  @override
  String get notReceived => 'प्राप्त नहीं हुआ';

  @override
  String get all => 'सभी';

  @override
  String get noDeliveriesFound => 'कोई डिलीवरी नहीं मिली';

  @override
  String get noDeliveriesFoundDesc => 'आपके पास कोई डिजीटीपी पास नहीं है।';

  @override
  String get fetchingConsumerDigiTpRecords =>
      'उपभोक्ता डिजीटीपी रिकॉर्ड प्राप्त कर रहे हैं...';

  @override
  String get failedToLoadDigiTpList => 'डिजीटीपी सूची लोड करने में विफल';

  @override
  String get orgKycVerification => 'संगठन केवाईसी (KYC) सत्यापन';

  @override
  String get optionalLabel => 'वैकल्पिक';

  @override
  String get verifyIdentityOrSkip =>
      'आधार OTP के माध्यम से पहचान सत्यापित करें या अपना पंजीकरण पूरा करने के लिए छोड़ें।';

  @override
  String get aadhaarCardOtpVerification => 'आधार कार्ड OTP सत्यापन';

  @override
  String get enterTwelveDigitAadhaarToReceiveOtp =>
      'OTP प्राप्त करने के लिए 12-अंकीय आधार दर्ज करें';

  @override
  String get aadhaarCardNumberLabel => 'आधार कार्ड नंबर';

  @override
  String get twelveDigitAadhaarHint => '12-अंकीय आधार नंबर';

  @override
  String get enterSixDigitAadhaarOtpLabel => '6-अंकीय आधार OTP दर्ज करें';

  @override
  String get sixDigitOtpHint => '6-अंकीय OTP';

  @override
  String get aadhaarIdentityVerified => 'आधार पहचान सत्यापित';

  @override
  String get aadhaarVerifiedNationalId => 'आधार सत्यापित राष्ट्रीय पहचान पत्र';

  @override
  String get uploadAadhaarCardOptional => 'आधार कार्ड अपलोड करें (वैकल्पिक)';

  @override
  String get frontOrCombinedAadhaar =>
      'आधार कार्ड की फ्रंट या संयुक्त कॉपी (PDF / Image)';

  @override
  String get aadhaarNonMandatoryNotice =>
      'आधार सत्यापन अनिवार्य नहीं है। आप किसी भी समय इस चरण को छोड़ सकते हैं और पंजीकरण पूरा कर सकते हैं।';

  @override
  String get resendBtn => 'पुनः भेजें';

  @override
  String get digitpsNotReceived => 'डिजीटीपी\nप्राप्त नहीं';

  @override
  String get enterFullName => 'पूरा नाम दर्ज करें';

  @override
  String get emailOptional => 'ईमेल (वैकल्पिक)';

  @override
  String get enterEmail => 'ईमेल दर्ज करें';

  @override
  String get stateLabel => 'राज्य';

  @override
  String get loadingStates => 'राज्य लोड हो रहे हैं...';

  @override
  String get selectStateHint => 'राज्य चुनें';

  @override
  String get consumerLabel => 'उपभोक्ता';

  @override
  String get organizationLabel => 'संस्था';

  @override
  String get actionRequiredLabel => 'कार्रवाई आवश्यक';

  @override
  String get aadhaarAuthenticationLabel => 'आधार प्रमाणीकरण';

  @override
  String get approvedLabel => 'स्वीकृत';

  @override
  String get invalidOtpServer =>
      'अवैध OTP दर्ज किया गया। कृपया पुनः प्रयास करें।';

  @override
  String get maharashtraState => 'महाराष्ट्र';

  @override
  String get viewBtn => 'देखें';

  @override
  String get logoutBtn => 'लॉगआउट';

  @override
  String get logoutErrorMsg => 'लॉगआउट के दौरान नेटवर्क/API त्रुटि:';

  @override
  String get logoutFailedMsg => 'लॉगआउट विफल रहा। कृपया पुनः प्रयास करें।';

  @override
  String get preferencesHeader => 'प्राथमिकताएं';

  @override
  String get changeLanguageLabel => 'भाषा बदलें';

  @override
  String get storagePhotosPermissionReq =>
      'गैलरी से चुनने के लिए स्टोरेज/फोटो अनुमति आवश्यक है।';

  @override
  String get cameraPermissionReq =>
      'तस्वीरें लेने के लिए कैमरा अनुमति आवश्यक है।';

  @override
  String get storagePermissionReq =>
      'दस्तावेज़ चुनने के लिए स्टोरेज अनुमति आवश्यक है।';

  @override
  String get registrationSuccess =>
      'पंजीकरण सफल! कृपया अपने मोबाइल नंबर से साइन इन करें।';

  @override
  String get registrationFailed => 'पंजीकरण विफल। कृपया पुनः प्रयास करें।';

  @override
  String get fullNameRequired => 'पूरा नाम आवश्यक है।';

  @override
  String get validMobileRequired =>
      'एक वैध 10-अंकीय भारतीय मोबाइल नंबर दर्ज करें।';

  @override
  String get orgNameRequired => 'संगठन का नाम आवश्यक है।';

  @override
  String get gstinRequired => 'अपना संगठन GSTIN दर्ज करें।';

  @override
  String get addressRequired => 'पता आवश्यक है।';

  @override
  String get validEmailRequired =>
      'बिना लगातार डॉट्स या शुरुआत में डॉट्स के एक वैध ईमेल पता दर्ज करें।';

  @override
  String get districtRequired => 'ज़िला आवश्यक है।';

  @override
  String get talukaRequired => 'तालुका आवश्यक है।';

  @override
  String get cityCorpRequired => 'शहर/निगम आवश्यक है।';

  @override
  String get villageRequired => 'गाँव आवश्यक है।';

  @override
  String get aadhaarVerificationRequired =>
      'कृपया आगे बढ़ने के लिए अपना आधार नंबर सत्यापित करें।';

  @override
  String get surveyNumberRequired => 'सर्वेक्षण संख्या आवश्यक है।';

  @override
  String get validGstRequired => 'एक वैध 15-वर्ण का GSTIN दर्ज करें।';

  @override
  String get changeLanguageLaterHint =>
      'आप इसे बाद में सेटिंग्स में बदल सकते हैं।';

  @override
  String get changeBtn => 'बदलें';

  @override
  String get aadhaarDetailsSavedSuccessfully =>
      'आधार सत्यापन विवरण सफलतापूर्वक सहेजा गया';

  @override
  String get noInternetConnection => 'कोई इंटरनेट कनेक्शन नहीं';

  @override
  String get unableToLogin =>
      'लॉगिन करने में असमर्थ। कृपया इंटरनेट कनेक्शन जाँचें।';

  @override
  String get loginFailedMsg => 'लॉगिन विफल। कृपया पुनः प्रयास करें।';

  @override
  String get pleaseEnterFullName => 'कृपया अपना पूरा नाम दर्ज करें।';

  @override
  String get pleaseEnterValidEmail => 'कृपया एक वैध ईमेल पता दर्ज करें।';

  @override
  String get profileSaveError =>
      'प्रोफाइल सहेजने में विफल। कृपया पुनः प्रयास करें।';

  @override
  String get aadhaarSendOtpError =>
      'आधार OTP भेजने में विफल। कृपया पुनः प्रयास करें।';

  @override
  String get msgRegSuccessSignIn =>
      'पंजीकरण सफल! कृपया अपने मोबाइल नंबर से साइन इन करें।';

  @override
  String get errEnterMandatoryFields => 'कृपया सभी अनिवार्य फ़ील्ड दर्ज करें।';

  @override
  String get msgRegSuccessLogin =>
      'पंजीकरण सफल! कृपया अपने मोबाइल नंबर से लॉगिन करें।';

  @override
  String get errEnterSiteName => 'कृपया साइट का नाम दर्ज करें';

  @override
  String get errEnterDeliveryAddress => 'कृपया वितरण पता दर्ज करें';

  @override
  String get msgEnquirySubmitted => 'खदान संचालक को पूछताछ प्रस्तुत की गई!';

  @override
  String get msgDownloadingFile => 'फ़ाइल डाउनलोड हो रही है... ';

  @override
  String get msgDownloadingAppFee =>
      'आवेदन शुल्क मांग पत्र डाउनलोड हो रहा है...';

  @override
  String get msgDownloadingGrasReceipt =>
      'GRAS शुल्क रसीद डाउनलोड हो रही है...';

  @override
  String get msgDownloadingRoyaltyNote =>
      'रॉयल्टी मांग पत्र डाउनलोड हो रहा है...';

  @override
  String get msgDownloadingPermitOrder =>
      'आधिकारिक उत्खनन परमिट आदेश डाउनलोड हो रहा है...';

  @override
  String get msgDraftSaved => 'ड्राफ्ट सफलतापूर्वक सहेजा गया।';

  @override
  String get errUploadMandatoryDocs =>
      'कृपया आगे बढ़ने से पहले सभी अनिवार्य दस्तावेज़ (*) अपलोड करें।';

  @override
  String get errAcceptDeclaration =>
      'कृपया वैधानिक लघु खनिज घोषणा स्वीकार करें।';

  @override
  String get msgAppSubmitted =>
      'शुल्क भुगतान के साथ आवेदन सफलतापूर्वक जमा किया गया!';

  @override
  String get msgPinMapOverlay => 'पिन मैप ओवरले खोला गया। स्थान सेट किया गया।';

  @override
  String get msgGpsCaptured =>
      'वर्तमान वाहन स्थान सफलतापूर्वक कैप्चर किया गया।';

  @override
  String get msgAttachedReceipt => 'संलग्न बैंक रसीद';

  @override
  String get msgDownloadedChallan => 'GRAS ई-चालान डाउनलोड किया गया';

  @override
  String get errStateEngPurpose =>
      'कृपया ड्रॉडाउन के लिए इंजीनियरिंग उद्देश्य बताएं';

  @override
  String get msgConsumptionLogged =>
      'वैधानिक ऑन-साइट खपत ड्रॉडाउन सफलतापूर्वक लॉग किया गया!';

  @override
  String get msgTransferEtpGenerated =>
      'ई-टीपी सफलतापूर्वक उत्पन्न! पास ड्राइवर के लिए तैयार है।';

  @override
  String get msgTransitPassShared =>
      'व्हाट्सएप पर ट्रांजिट पास लिंक साझा किया गया!';

  @override
  String get msgGatePassReady => 'गेट पास प्रिंट / डाउनलोड के लिए तैयार है।';

  @override
  String get errCannotCall => 'कॉल नहीं कर सकते ';

  @override
  String get errEnterPackageName => 'कृपया पैकेज का नाम दर्ज करें';

  @override
  String get msgPackageCreated => 'पैकेज सफलतापूर्वक बनाया गया!';

  @override
  String get errEnterProjectName => 'प्रोजेक्ट का नाम दर्ज करें।';

  @override
  String get errSelectGovDept => 'सरकारी विभाग का चयन करें या दर्ज करें।';

  @override
  String get errEnterOfficeName =>
      'जारी करने वाले/प्रभाग कार्यालय का नाम दर्ज करें।';

  @override
  String get errEnterWorkOrder =>
      'कार्य आदेश / स्वीकृति आदेश संख्या दर्ज करें।';

  @override
  String get errEnterSiteAddress => 'साइट का पता दर्ज करें।';

  @override
  String get msgCallingSupervisor => 'सुपरवाइज़र को कॉल कर रहे हैं...';

  @override
  String get msgOpeningWhatsapp => 'व्हाट्सएप खुल रहा है...';

  @override
  String get msgActiveScopeSet => 'सक्रिय कार्यक्षेत्र सेट किया गया: ';

  @override
  String get errEnterSupervisorName => 'कृपया सुपरवाइज़र का नाम दर्ज करें';

  @override
  String get errEnterSupervisorContact =>
      'कृपया सुपरवाइज़र का संपर्क विवरण दर्ज करें';

  @override
  String get errEnterValidDigitp =>
      'कृपया एक वैध संख्यात्मक DigiTP नंबर दर्ज करें।';

  @override
  String get inTransitVehiclesTitle => 'मार्ग में वाहन';

  @override
  String get activeVehicleTracking => 'सक्रिय वाहन ट्रैकिंग';

  @override
  String get activeVehicleTrackingDesc =>
      'रियल-टाइम वाहन स्थान और ईटीए की निगरानी के लिए मार्ग में वाहन चुनें।';

  @override
  String get loadingInTransitVehicles => 'मार्ग में वाहन लोड हो रहे हैं...';

  @override
  String get failedToLoadInTransitVehicles =>
      'मार्ग में वाहन लोड करने में विफल';

  @override
  String get noVehiclesInTransit => 'कोई वाहन मार्ग में नहीं है';

  @override
  String get noVehiclesInTransitDesc =>
      'वर्तमान में आपके खाते के लिए कोई सक्रिय खनिज वाहन मार्ग में नहीं है।';

  @override
  String get refreshList => 'सूची रीफ्रेश करें';

  @override
  String get vehicleNA => 'वाहन उपलब्ध नहीं';

  @override
  String get destinationNA => 'गंतव्य उपलब्ध नहीं';

  @override
  String get gpsActive => 'वाहन सक्रिय';

  @override
  String get mineralAndQty => 'खनिज और मात्रा:';

  @override
  String get destinationLabel => 'गंतव्य:';

  @override
  String get distanceLabel => 'दूरी:';

  @override
  String get driverLabel => 'चालक:';

  @override
  String get selectVehicleAndTrackLive => 'वाहन चुनें और लाइव ट्रैक करें';

  @override
  String get digiTpLabel => 'DigiTP:';

  @override
  String get inTransitStatus => 'मार्ग में';

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
  String get deliveryNotFound => 'Delivery not found';

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
  String get statusNotReceived => 'प्राप्त नहीं हुआ';

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
  String get removeBtn => 'निकालें';
}
