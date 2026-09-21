/// API Endpoints specification
/// Matches Section 6.1 of DEVELOPER_HANDOFF.md for easy live backend hookup.
class ApiEndpoints {
  ApiEndpoints._();

  // Auth & Profile
  static const String sendOtp = '/auth/otp/send';
  static const String verifyOtp = '/auth/otp/verify';
  static const String me = '/users/me';

  // Organizations & Projects
  static const String organizations = '/organizations';
  static String organizationById(String id) => '/organizations/$id';
  static String orgProjects(String orgId) => '/organizations/$orgId/projects';
  static String projectPackages(String projId) => '/projects/$projId/packages';
  static const String supervisors = '/supervisors';

  // Minerals & Stock Points
  static const String minerals = '/minerals';
  static const String stockPoints = '/stock-points';
  static String stockPointById(String id) => '/stock-points/$id';

  // Enquiries & Orders
  static const String enquiries = '/enquiries';
  static const String orders = '/orders';
  static String orderById(String id) => '/orders/$id';

  // Deliveries & DigiTP
  static const String deliveries = '/deliveries';
  static const String verifyQr = '/deliveries/verify-qr';
  static String receiveDelivery(String id) => '/deliveries/$id/receive';

  // Inventory & Consumption
  static const String inventory = '/inventory';
  static String consumeInventory(String id) => '/inventory/$id/consume';

  // Temporary Excavation Permits
  static const String excavationApplications = '/excavation/applications';
  static String excavationById(String id) => '/excavation/applications/$id';
  static const String excavationDrafts = '/excavation/drafts';
  static String excavationDraftById(String id) => '/excavation/drafts/$id';
  static const String paymentsInitiate = '/payments/initiate';
}
