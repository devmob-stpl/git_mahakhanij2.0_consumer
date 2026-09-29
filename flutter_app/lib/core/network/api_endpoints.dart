enum ApiEnvironment { demo, live }

class ApiEndpoints {
  ApiEndpoints._();

  /// Environment selection switch (Default: Demo)
  static ApiEnvironment activeEnvironment = ApiEnvironment.demo;

  // ===========================================================================
  // BASE URL CONFIGURATION
  // Manage all environment Base URLs in one central place.
  // ===========================================================================
  
  // Demo Environment Base URLs
  static String demoMineralProjectBaseUrl = 'https://mineral-project.mahakhanij.in';
  static String demoMineralMappingBaseUrl = 'https://mineral-mapping.mahakhanij.in';
  static String demoMasterBaseUrl = 'https://master.mahakhanij.in';
  static String demoBaseUrl = 'https://mineral-mapping.mahakhanij.in';

  // Live / Production Environment Base URLs
  static String liveMineralProjectBaseUrl = 'https://mahakhanij.maharashtra.gov.in';
  static String liveMineralMappingBaseUrl = 'https://mahakhanij.maharashtra.gov.in';
  static String liveMasterBaseUrl = 'https://mahakhanij.maharashtra.gov.in';
  static String liveBaseUrl = 'https://mahakhanij.maharashtra.gov.in';

  // Dynamic Base URL getters evaluated at runtime based on active environment
  static String get mineralProjectBaseUrl =>
      activeEnvironment == ApiEnvironment.demo ? demoMineralProjectBaseUrl : liveMineralProjectBaseUrl;

  static String get mineralMappingBaseUrl =>
      activeEnvironment == ApiEnvironment.demo ? demoMineralMappingBaseUrl : liveMineralMappingBaseUrl;

  static String get masterBaseUrl =>
      activeEnvironment == ApiEnvironment.demo ? demoMasterBaseUrl : liveMasterBaseUrl;

  static String get baseUrl =>
      activeEnvironment == ApiEnvironment.demo ? demoBaseUrl : liveBaseUrl;

  // ===========================================================================
  // DYNAMIC ENDPOINT PATHS & URL BUILDERS
  // All endpoints build their URLs dynamically from the configured Base URLs.
  // ===========================================================================

  // Auth & Profile
  static String get getUserKey => '$mineralProjectBaseUrl/mineral-project/sand-policy-Login/get-user-key';
  static String getUserKeyUrl(String mobileNo) =>
      '$getUserKey?MobileNo=$mobileNo&Key=&LoginDeviceTypeId=1';

  static String get loginMobile => '$mineralProjectBaseUrl/mineral-project/sand-policy-Login/login-mobile';
  static String getLoginMobileUrl({required String mobileNo, required String key}) =>
      '$loginMobile?MobileNo=$mobileNo&key=$key&version=1&RegistraionId=1&LoginDeviceTypeId=1';

  static String get checkAadhaarExists => '$mineralMappingBaseUrl/mineral-mapping/consumer-project/is-exists-consumer-aadharcard-no';
  static String getCheckAadhaarExistsUrl(String aadharNo) => '$checkAadhaarExists?AadharCardNo=$aadharNo';

  static String get generateAadhaarOtp => '$mineralMappingBaseUrl/mineral-mapping/aadhar-verification/generate-otp';
  static String get verifyAadhaarOtp => '$mineralMappingBaseUrl/mineral-mapping/aadhar-verification/submit-otp';
  static String get uploadPhoto => '$mineralMappingBaseUrl/mineral-mapping/uploads/upload-photo';

  static String get consumerSignUp => '$mineralProjectBaseUrl/mineral-project/sand-policy-Login/consumer-signup-v1';
  static String get consumerProfile => '$mineralProjectBaseUrl/mineral-project/sand-policy-Login/get-Consumer-Profile';
  static String getConsumerProfileUrl(String mobileNo) => '$consumerProfile?mobileNo=$mobileNo';

  static String get consumerDigiTpList => '$mineralProjectBaseUrl/mineral-project/sand-policy-Login/get-Consumer-digiTP-list';
  static String getConsumerDigiTpListUrl({required int consumerId, required int status}) =>
      '$consumerDigiTpList?consumerId=$consumerId&status=$status';

  static String get getConsumerInvoiceDetails => '$mineralProjectBaseUrl/mineral-project/sand-policy-Login/get-consumer-invoice-details';
  static String getConsumerInvoiceDetailsUrl(dynamic invoiceNo) =>
      '$getConsumerInvoiceDetails?invoiceNo=$invoiceNo';

  static String get receiveInvoice => '$mineralProjectBaseUrl/mineral-project/sand-policy-Login/receive-invoice';

  static String get consumerDashboardCount => '$mineralProjectBaseUrl/mineral-project/sand-policy-Login/get-consumer-dashboard-count';
  static String getConsumerDashboardCountUrl(int consumerId) =>
      '$consumerDashboardCount?consumerId=$consumerId';

  static String get logoutUser => '$mineralProjectBaseUrl/mineral-project/sand-policy-Login/logout-user';
  static String getLogoutUserUrl({required dynamic userId, int appId = 1}) =>
      '$logoutUser?UserId=$userId&AppId=$appId';


  static String get sendOtp => '$baseUrl/auth/otp/send';

  static String get verifyOtp => '$baseUrl/auth/otp/verify';
  static String get me => '$baseUrl/users/me';

  // Organizations & Projects
  static String get saveConsumerProject => '$mineralProjectBaseUrl/mineral-project/sand-policy-Login/Save-Consumer-Project';
  static String get saveUpdateConsumerProject => saveConsumerProject;

  static String get getConsumerProjects => '$mineralMappingBaseUrl/mineral-mapping/consumer-project/get-Nsp-project-details';
  static String getConsumerProjectsUrl({
    required int userId,
    int organizationId = 0,
    int departmentId = 0,
    String search = '',
    int noPage = 1,
    int rowsPerPage = 50,
  }) =>
      '$getConsumerProjects?UserId=$userId&OrganizationId=$organizationId&DepartmentId=$departmentId&Search=$search&NoPage=$noPage&RowsPerPage=$rowsPerPage';

  static String get organizations => '$baseUrl/organizations';
  static String organizationById(String id) => '$baseUrl/organizations/$id';
  static String orgProjects(String orgId) => '$baseUrl/organizations/$orgId/projects';
  static String projectPackages(String projId) => '$baseUrl/projects/$projId/packages';
  static String get supervisors => '$baseUrl/supervisors';

  // Master Location Endpoints
  static String getDistrictsUrl([int stateId = 1]) =>
      '$masterBaseUrl/master/districts/GetDistrictByStateId/$stateId';
  static String getTalukasUrl(int districtId) =>
      '$masterBaseUrl/master/talukas/GetTalukaByDistrictId/$districtId';
  static String getCensusDataUrl({
    required int districtId,
    required int talukaId,
    required bool isTown,
    int stateId = 1,
    int noPage = 1,
    int rowsPerPage = 1000,
  }) =>
      '$masterBaseUrl/master/census/getCensusDataCode?StateId=$stateId&DistrictId=$districtId&TalukaId=$talukaId&IsTown=$isTown&NoPage=$noPage&RowsPerPage=$rowsPerPage';

  // Minerals & Stock Points
  static String get minerals => '$baseUrl/minerals';
  static String get stockPoints => '$baseUrl/stock-points';
  static String stockPointById(String id) => '$baseUrl/stock-points/$id';

  // Enquiries & Orders
  static String get enquiries => '$baseUrl/enquiries';
  static String get orders => '$baseUrl/orders';
  static String orderById(String id) => '$baseUrl/orders/$id';

  // Deliveries & DigiTP
  static String get deliveries => '$baseUrl/deliveries';
  static String get verifyQr => '$baseUrl/deliveries/verify-qr';
  static String receiveDelivery(String id) => '$baseUrl/deliveries/$id/receive';

  // Inventory & Consumption
  static String get inventory => '$baseUrl/inventory';
  static String consumeInventory(String id) => '$baseUrl/inventory/$id/consume';

  // Temporary Excavation Permits
  static String get excavationApplications => '$baseUrl/excavation/applications';
  static String excavationById(String id) => '$baseUrl/excavation/applications/$id';
  static String get excavationDrafts => '$baseUrl/excavation/drafts';
  static String excavationDraftById(String id) => '$baseUrl/excavation/drafts/$id';
  static String get paymentsInitiate => '$baseUrl/payments/initiate';

  // Live Vehicle Tracking
  static String get vehicleTrackingLocationAndTrip =>
      'https://gps.mahakhanij.in/gps-data-provider/api/v2/mobile/vehicle-tracking/tracking/get-vehicles-current-location-and-trip';
  static String getVehicleTrackingLocationAndTripUrl(String vehicleNo) =>
      '$vehicleTrackingLocationAndTrip?VehicleNo=$vehicleNo';
}

