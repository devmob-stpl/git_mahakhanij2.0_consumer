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
  String get digitpDeliveries => 'डिजी-टीपी\nवितरण';

  @override
  String get receivedMaterial => 'प्राप्त\nसामग्री';

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
  String get activityTab => 'अॅक्टिव्हिटी';

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
}
