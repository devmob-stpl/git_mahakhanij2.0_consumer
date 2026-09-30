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
  String get digitpDeliveries => 'डिजी-टीपी\nवितरण';

  @override
  String get receivedMaterial => 'प्राप्त\nसामग्री';

  @override
  String get inTransitVehicles => 'रास्ते में\nवाहन';

  @override
  String get coreServices => 'मुख्य सेवाएँ';

  @override
  String get digitpPasses => 'डिजी-टीपी\nपास';

  @override
  String get receiveMaterialAction => 'सामग्री\nप्राप्त करें';

  @override
  String get trackVehicle => 'वाहन\nट्रैक करें';

  @override
  String get recentDeliveriesHeader => 'डिजी-टीपी और खनिज वितरण';

  @override
  String get viewAll => 'सभी देखें';

  @override
  String get noRecentDeliveries => 'कोई हालिया डिजी-टीपी वितरण नहीं मिला।';

  @override
  String get receiveMaterial => 'सामग्री प्राप्त करें';

  @override
  String get receiveMaterialError => 'सामग्री प्राप्त करने में त्रुटि';

  @override
  String get scanDigiTp => 'डिजी-टीपी क्यूआर / बारकोड स्कैन करें';

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
    return '$vehicleNo के लिए लाइव जीपीएस स्थान प्राप्त कर रहा है...';
  }

  @override
  String get connectingToMahakhanij =>
      'महाखनिज जीपीएस ट्रैकिंग सेवा से जुड़ रहा है';

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
  String get viewDigiTp => 'डिजी-टीपी देखें';

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
  String get digiTpNo => 'डिजी-टीपी नंबर';

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
  String get createdDateAndTimeOfDigiTp =>
      'डिजी-टीपी के निर्माण की तिथि और समय';

  @override
  String get digiTpValidityDateAndTime => 'डिजी-टीपी वैधता तिथि और समय';

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
  String get liveVehicleTracking => 'लाइव वाहन ट्रैकिंग';

  @override
  String get liveGps => 'लाइव जीपीएस';

  @override
  String get currentGpsLocation => 'वर्तमान जीपीएस स्थान';

  @override
  String get trackingLiveGps => 'लाइव जीपीएस ट्रैक कर रहा है';

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
      'इस समय इस वाहन से जुड़ा कोई सक्रिय डिजी-टीपी यात्रा विवरण नहीं है।';

  @override
  String get mobileNumberUnavailable => 'मोबाइल नंबर उपलब्ध नहीं है';

  @override
  String get enterVehicleNo => 'वाहन नंबर दर्ज करें';

  @override
  String get enterDigiTpNumber => 'डिजी-टीपी नंबर दर्ज करें';

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
  String get revenueDeptMsg => 'राजस्व विभाग, महाराष्ट्र सरकार';

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
  String get enterPersonalContact =>
      'अपना व्यक्तिगत संपर्क और वितरण गंतव्य विवरण दर्ज करें।';

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
  String get continueToKyc => 'केवाईसी सत्यापन के लिए आगे बढ़ें';

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
  String get districtLabel => 'जिला *';

  @override
  String get selectDistrictHint => 'जिला चुनें';

  @override
  String get loadingDistricts => 'जिले लोड हो रहे हैं...';

  @override
  String get talukaLabel => 'तालुका *';

  @override
  String get talukaHint => 'उदा. हवेली';

  @override
  String get loading => 'लोड हो रहा है...';

  @override
  String get cityCorporationLabel => 'शहर / निगम';

  @override
  String get villageRuralLabel => 'गाँव / ग्रामीण क्षेत्र';

  @override
  String get cityCorporationHint => 'उदा. पुणे शहर (PMC)';

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
}
