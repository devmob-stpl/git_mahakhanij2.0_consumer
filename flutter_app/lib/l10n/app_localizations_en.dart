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
  String get digitpDeliveries => 'DigiTP\nDeliveries';

  @override
  String get receivedMaterial => 'Received\nMaterial';

  @override
  String get inTransitVehicles => 'In Transit\nVehicles';

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
  String get activityTab => 'Activity';

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
}
