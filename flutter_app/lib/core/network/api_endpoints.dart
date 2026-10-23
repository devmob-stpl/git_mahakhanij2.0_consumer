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
  static String demoMahaServiceBaseUrl = 'https://mahaservice.mahakhanij.in/service.asmx';
  static String demoBaseUrl = 'https://mineral-mapping.mahakhanij.in';

  // Live / Production Environment Base URLs
  static String liveMineralProjectBaseUrl = 'https://mahakhanij.maharashtra.gov.in';
  static String liveMineralMappingBaseUrl = 'https://mahakhanij.maharashtra.gov.in';
  static String liveMasterBaseUrl = 'https://mahakhanij.maharashtra.gov.in';
  static String liveMahaServiceBaseUrl = 'https://mahakhanij.maharashtra.gov.in/mahaservice/service.asmx';
  static String liveBaseUrl = 'https://mahakhanij.maharashtra.gov.in';

  // Dynamic Base URL getters evaluated at runtime based on active environment
  static String get mineralProjectBaseUrl =>
      activeEnvironment == ApiEnvironment.demo ? demoMineralProjectBaseUrl : liveMineralProjectBaseUrl;

  static String get mineralMappingBaseUrl =>
      activeEnvironment == ApiEnvironment.demo ? demoMineralMappingBaseUrl : liveMineralMappingBaseUrl;

  static String get mahaServiceBaseUrl =>
      activeEnvironment == ApiEnvironment.demo ? demoMahaServiceBaseUrl : liveMahaServiceBaseUrl;

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
  static String getLoginMobileUrl({required String mobileNo, required String key, required String version}) =>
      '$loginMobile?MobileNo=$mobileNo&key=$key&version=$version&RegistraionId=1&LoginDeviceTypeId=1';

  static String get checkAadhaarExists => '$mineralProjectBaseUrl/mineral-project/sand-policy-Login/is-exists-consumer-aadharcard-no';
  static String getCheckAadhaarExistsUrl(String aadharNo, {String? mobileNo}) {
    String url = '$checkAadhaarExists?AadharCardNo=$aadharNo';
    if (mobileNo != null && mobileNo.isNotEmpty) {
      url += '&mobileNo=$mobileNo';
    }
    return url;
  }

  static String get generateAadhaarOtp => '$mineralMappingBaseUrl/mineral-mapping/aadhar-verification/generate-otp';
  static String get verifyAadhaarOtp => '$mineralMappingBaseUrl/mineral-mapping/aadhar-verification/submit-otp';
  static String get uploadPhoto => '$mineralMappingBaseUrl/mineral-mapping/uploads/upload-photo';

  // Organisation GST & PAN Verification Endpoints
  static String get checkGstExists =>
      '$mineralMappingBaseUrl/mineral-mapping/vehicle_owner_registration/check-gst-exists-VehicleOwner';
  static String getCheckGstExistsUrl({
    required String gstNo,
    required String mobileNo,
    int id = 0,
    int userCategory = 2,
  }) =>
      '$checkGstExists?GSTNo=$gstNo&MobileNo=$mobileNo&Id=$id&UserCategory=$userCategory';

  static String get verifyGstin =>
      '$mineralMappingBaseUrl/mineral-mapping/pan-validation/gstin-verification';

  static String get checkPanExists =>
      '$mineralMappingBaseUrl/mineral-mapping/vehicle_owner_registration/check-pan-exists-VehicleOwner';
  static String getCheckPanExistsUrl({
    required String panNo,
    required String mobileNo,
    int id = 0,
    int userCategory = 2,
  }) =>
      '$checkPanExists?PanNo=$panNo&MobileNo=$mobileNo&Id=$id&UserCategory=$userCategory';

  static String get verifyPan =>
      '$mineralMappingBaseUrl/mineral-mapping/pan-validation/pan-verification_v1';

  static String get saveUpdateConsumerDetails =>
      '$mineralMappingBaseUrl/mineral-mapping/consumer-project/save-update-consumer-Details';
  static String get consumerSignUp => saveUpdateConsumerDetails;
  static String get consumerProfileUpdate => saveUpdateConsumerDetails;
  static String get consumerProfile =>
      '$mineralMappingBaseUrl/mineral-mapping/consumer-project/get-consumer-details-by-mobileNo';
  static String getConsumerProfileUrl(String mobileNo) => '$consumerProfile?mobileNo=$mobileNo';

  static String get consumerDigiTpList => '$mineralProjectBaseUrl/mineral-project/sand-policy-Login/get-Consumer-digiTP-list';
  static String getConsumerDigiTpListUrl({required int consumerId, required int status}) =>
      '$consumerDigiTpList?consumerId=$consumerId&status=$status';

  static String get getConsumerInvoiceDetails => '$mineralProjectBaseUrl/mineral-project/sand-policy-Login/get-consumer-invoice-details';
  static String getConsumerInvoiceDetailsUrl({required dynamic invoiceNo, required int consumerId}) =>
      '$getConsumerInvoiceDetails?invoiceNo=$invoiceNo&consumerId=$consumerId';

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
  static String get getStatesUrl => '$masterBaseUrl/master/states/GetState';
  
  static String getDistrictsUrl([int stateId = 1]) =>
      '$masterBaseUrl/master/districts/GetDistrictByStateId/$stateId';
  static String getTalukasUrl(int districtId) =>
      '$masterBaseUrl/master/talukas/GetTalukaByDistrictId/$districtId';
  static String getCensusDataUrl({
    required int districtId,
    required int talukaId,
    required bool isTown,
    int userId = 0,
  }) =>
      '$mahaServiceBaseUrl/GetCensusVillageTownDetails_1_7?DistrictId=$districtId&TalukaId=$talukaId&IsTown=${isTown ? 1 : 0}&UserId=$userId&VillageUpdatedDate=&TownUpdatedDate=&PlotId=0&ReceiverPlotUpdatedDate=';

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
  static String get vehicleTrackingLocation =>
      'https://gps.mahakhanij.in/gps-data-provider/api/v2/vehicle-tracking/tracking/get-vehicle-current-location';
  static String getVehicleTrackingLocationUrl(String vehicleNo) =>
      '$vehicleTrackingLocation?VehicleNumber=$vehicleNo';

  // Consumer Reports & Plots
  static String get consumerPlots => '$mineralProjectBaseUrl/mineral-project/sand-policy-Login/consumer-plots';
  static String getConsumerPlotsUrl(int consumerId) => '$consumerPlots?consumerId=$consumerId';
  
  static String get consumerInvoiceReport => '$mineralProjectBaseUrl/mineral-project/sand-policy-Login/consumer-invoice-report';
}

