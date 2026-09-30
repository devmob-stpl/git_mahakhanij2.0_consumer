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
  String get activityTab => 'गतिविधि';

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
}
