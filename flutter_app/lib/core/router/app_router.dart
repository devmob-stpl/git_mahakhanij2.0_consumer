import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/config/app_config.dart';
import '../../domain/delivery.dart';
import '../../domain/enquiry.dart';
import '../../domain/mineral.dart';
import '../../domain/order.dart';
import '../../domain/package.dart';
import '../../domain/project.dart';
import '../../domain/temporary_excavation.dart';

import '../../features/auth/splash_screen.dart';
import '../../features/auth/language_selection_screen.dart';
import '../../features/auth/welcome_screen.dart';
import '../../features/auth/login_screen.dart';
import '../../features/auth/register_screen.dart';
import '../../features/auth/otp_screen.dart';
import '../../features/auth/persona_switch_screen.dart';

import '../../features/shell/main_shell_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/activity/consumer_activity_screen.dart';

import '../../features/consumer/consumer_projects_screen.dart';
import '../../features/consumer/consumer_project_registration_screen.dart';
import '../../features/consumer/consumer_project_details_screen.dart';

import '../../features/excavation/temporary_excavation_screen.dart';
import '../../features/excavation/new_application_screen.dart';
import '../../features/excavation/application_details_screen.dart';
import '../../features/excavation/payment_screen.dart';

import '../../features/orders/orders_screen.dart';
import '../../features/orders/order_details_screen.dart';
import '../../features/orders/digitp_pass_screen.dart';
import '../../features/orders/delivery_tracking_screen.dart';
import '../../features/orders/live_vehicle_tracking_screen.dart';
import '../../features/orders/in_transit_vehicle_list_screen.dart';

import '../../features/receiving/receive_screen.dart';
import '../../features/receiving/receive_delivery_screen.dart';
import '../../features/receiving/digitp_scan_screen.dart';

import '../../features/inventory/inventory_screen.dart';
import '../../features/inventory/transfers_screen.dart';

import '../../features/enquiry/enquiries_screen.dart';
import '../../features/enquiry/create_enquiry_screen.dart';
import '../../features/enquiry/enquiry_details_screen.dart';

import '../../features/organization/projects_screen.dart';
import '../../features/organization/create_project_screen.dart';
import '../../features/organization/project_details_screen.dart';
import '../../features/organization/create_package_screen.dart';
import '../../features/organization/supervisors_screen.dart';
import '../../features/organization/register_supervisor_screen.dart';
import '../../features/organization/package_details_screen.dart';

import '../../features/minerals/mineral_catalog_screen.dart';
import '../../features/minerals/stock_point_map_screen.dart';
import '../../features/minerals/stock_point_details_screen.dart';

import '../../features/reports/consumer_reports_screen.dart';
import '../../features/settings/settings_screen.dart';
import '../../features/profile/profile_screen.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');
final GlobalKey<NavigatorState> _shellNavigatorHomeKey = GlobalKey<NavigatorState>(debugLabel: 'shellHome');
final GlobalKey<NavigatorState> _shellNavigatorProjectsKey = GlobalKey<NavigatorState>(debugLabel: 'shellProjects');
final GlobalKey<NavigatorState> _shellNavigatorActivityKey = GlobalKey<NavigatorState>(debugLabel: 'shellActivity');
final GlobalKey<NavigatorState> _shellNavigatorReportsKey = GlobalKey<NavigatorState>(debugLabel: 'shellReports');
final GlobalKey<NavigatorState> _shellNavigatorMoreKey = GlobalKey<NavigatorState>(debugLabel: 'shellMore');

LocalKey _pageKey(GoRouterState state) => ValueKey('${state.pageKey.value}_${identityHashCode(state)}');

final appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/',
  routes: [
    // Entry Point: Splash Screen
    GoRoute(
      path: '/',
      name: 'splash',
      pageBuilder: (context, state) => MaterialPage(
        key: _pageKey(state),
        child: const SplashScreen(),
      ),
    ),
    // Language Selection Screen (First Launch)
    GoRoute(
      path: '/language-selection',
      name: 'language-selection',
      pageBuilder: (context, state) => MaterialPage(
        key: _pageKey(state),
        child: const LanguageSelectionScreen(),
      ),
    ),
    // Welcome Screen
    GoRoute(
      path: '/welcome',
      name: 'welcome',
      pageBuilder: (context, state) => MaterialPage(
        key: _pageKey(state),
        child: const WelcomeScreen(),
      ),
    ),
    GoRoute(
      path: '/login',
      name: 'login',
      pageBuilder: (context, state) {
        final mobile = (state.extra is String) ? state.extra as String? : null;
        return MaterialPage(
          key: _pageKey(state),
          child: LoginScreen(initialMobile: mobile),
        );
      },
    ),
    GoRoute(
      path: '/register',
      name: 'register',
      pageBuilder: (context, state) => MaterialPage(
        key: _pageKey(state),
        child: const RegisterScreen(),
      ),
    ),
    GoRoute(
      path: '/otp',
      name: 'otp',
      pageBuilder: (context, state) {
        String mobile = '9822014576';
        Map<String, dynamic>? signUpData;
        if (state.extra is String) {
          mobile = state.extra as String;
        } else if (state.extra is Map<String, dynamic>) {
          final map = state.extra as Map<String, dynamic>;
          mobile = map['mobileNo']?.toString() ?? map['mobileNumber']?.toString() ?? '9822014576';
          signUpData = map;
        }
        return MaterialPage(
          key: _pageKey(state),
          child: OtpScreen(
            mobileNumber: mobile,
            signUpData: signUpData,
          ),
        );
      },
    ),
    GoRoute(
      path: '/persona-switch',
      name: 'persona-switch',
      pageBuilder: (context, state) => MaterialPage(
        key: _pageKey(state),
        child: const PersonaSwitchScreen(),
      ),
    ),

    // Bottom Navigation Shell (5 persistent branches mapped role-wise)
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return MainShellScreen(navigationShell: navigationShell);
      },
      branches: [
        // Branch 0: Home
        StatefulShellBranch(
          navigatorKey: _shellNavigatorHomeKey,
          routes: [
            GoRoute(
              path: '/home',
              name: 'home',
              pageBuilder: (context, state) => MaterialPage(
                key: _pageKey(state),
                child: const HomeScreen(),
              ),
            ),
          ],
        ),
        // Branch 1: Projects (Org)
        StatefulShellBranch(
          navigatorKey: _shellNavigatorProjectsKey,
          routes: [
            GoRoute(
              path: '/organization/projects',
              name: 'org-projects',
              pageBuilder: (context, state) => MaterialPage(
                key: _pageKey(state),
                child: const ProjectsScreen(),
              ),
            ),
          ],
        ),
        // Branch 2: Activity (Org & Consumer)
        StatefulShellBranch(
          navigatorKey: _shellNavigatorActivityKey,
          routes: [
            GoRoute(
              path: '/activity',
              name: 'activity',
              pageBuilder: (context, state) => MaterialPage(
                key: _pageKey(state),
                child: const ConsumerActivityScreen(),
              ),
            ),
          ],
        ),
        // Branch 3: Reports (Consumer)
        StatefulShellBranch(
          navigatorKey: _shellNavigatorReportsKey,
          routes: [
            GoRoute(
              path: '/reports',
              name: 'reports',
              pageBuilder: (context, state) => MaterialPage(
                key: _pageKey(state),
                child: const ConsumerReportsScreen(),
              ),
            ),
          ],
        ),
        // Branch 4: Profile
        StatefulShellBranch(
          navigatorKey: _shellNavigatorMoreKey, // Keeping the same key variable name for simplicity
          routes: [
            GoRoute(
              path: '/profile',
              name: 'profile',
              pageBuilder: (context, state) => MaterialPage(
                key: _pageKey(state),
                child: const ProfileScreen(),
              ),
            ),
          ],
        ),
      ],
    ),

    // Sub-screens & Workflows
    GoRoute(
      path: '/deliveries/in-transit',
      name: 'deliveries-in-transit',
      parentNavigatorKey: _rootNavigatorKey,
      pageBuilder: (context, state) => MaterialPage(
        key: _pageKey(state),
        child: const InTransitVehicleListScreen(),
      ),
    ),
    GoRoute(
      path: '/deliveries/:id/live-tracking',
      name: 'delivery-live-tracking',
      parentNavigatorKey: _rootNavigatorKey,
      pageBuilder: (context, state) {
        final deliveryId = state.pathParameters['id'] ?? 'del-001';
        final queryVehicleNo = state.uri.queryParameters['vehicleNo'];
        String? extraVehicleNo;
        if (state.extra is String) {
          extraVehicleNo = state.extra as String;
        } else if (state.extra is Map) {
          extraVehicleNo = (state.extra as Map)['vehicleNo']?.toString();
        }
        final vehicleNo = queryVehicleNo ?? extraVehicleNo ?? deliveryId;
        return MaterialPage(
          key: _pageKey(state),
          child: LiveVehicleTrackingScreen(
            deliveryId: deliveryId,
            vehicleNo: vehicleNo,
          ),
        );
      },
    ),

    GoRoute(
      path: '/receive',
      name: 'receive',
      parentNavigatorKey: _rootNavigatorKey,
      pageBuilder: (context, state) => MaterialPage(
        key: _pageKey(state),
        child: const ReceiveScreen(),
      ),
    ),
    GoRoute(
      path: '/receiving/scan',
      name: 'receiving-scan',
      parentNavigatorKey: _rootNavigatorKey,
      pageBuilder: (context, state) => MaterialPage(
        key: _pageKey(state),
        child: const DigitpScanScreen(),
      ),
    ),
    GoRoute(
      path: '/receiving/detail',
      name: 'receiving-detail',
      parentNavigatorKey: _rootNavigatorKey,
      pageBuilder: (context, state) {
        String? deliveryId;
        if (state.extra is Map<String, dynamic>) {
          deliveryId = (state.extra as Map<String, dynamic>)['deliveryId'] as String?;
        } else if (state.extra is Map) {
          deliveryId = (state.extra as Map)['deliveryId'] as String?;
        } else if (state.extra is String) {
          deliveryId = state.extra as String;
        }
        return MaterialPage(
          key: _pageKey(state),
          child: ReceiveDeliveryScreen(deliveryId: deliveryId),
        );
      },
    ),
    GoRoute(
      path: '/excavation',
      name: 'excavation',
      parentNavigatorKey: _rootNavigatorKey,
      pageBuilder: (context, state) => MaterialPage(
        key: _pageKey(state),
        child: const TemporaryExcavationScreen(),
      ),
    ),
    GoRoute(
      path: '/excavation/new',
      name: 'excavation-new',
      parentNavigatorKey: _rootNavigatorKey,
      pageBuilder: (context, state) {
        final draft = (state.extra is TemporaryExcavationApplication) ? state.extra as TemporaryExcavationApplication? : null;
        return MaterialPage(
          key: _pageKey(state),
          child: NewApplicationScreen(initialDraft: draft),
        );
      },
    ),
    GoRoute(
      path: '/excavation/detail',
      name: 'excavation-detail',
      parentNavigatorKey: _rootNavigatorKey,
      pageBuilder: (context, state) {
        final appId = (state.extra is String)
            ? state.extra as String
            : ((state.extra is TemporaryExcavationApplication)
                ? (state.extra as TemporaryExcavationApplication).id
                : 'exc-1521');
        return MaterialPage(
          key: _pageKey(state),
          child: ApplicationDetailsScreen(applicationId: appId),
        );
      },
    ),
    GoRoute(
      path: '/excavation/pay',
      name: 'excavation-pay',
      parentNavigatorKey: _rootNavigatorKey,
      pageBuilder: (context, state) {
        final data = (state.extra is Map<String, dynamic>) ? state.extra as Map<String, dynamic> : <String, dynamic>{};
        return MaterialPage(
          key: _pageKey(state),
          child: PaymentScreen(
            title: data['title'] ?? 'Application Fee Payment',
            amount: data['amount'] ?? '₹520',
            applicationId: data['applicationId'] ?? 'TEA/2026/DRAFT-001410',
            applicantName: data['applicantName'] ?? 'Rohit Sanghavi',
            proposedQuantity: data['proposedQuantity'] ?? '22 Brass',
            applicationFee: data['applicationFee'] ?? '₹500',
            stampDuty: data['stampDuty'] ?? '₹20',
          ),
        );
      },
    ),
    GoRoute(
      path: '/orders',
      name: 'orders',
      parentNavigatorKey: _rootNavigatorKey,
      pageBuilder: (context, state) => MaterialPage(
        key: _pageKey(state),
        child: const OrdersScreen(),
      ),
    ),
    GoRoute(
      path: '/orders/detail',
      name: 'orders-detail',
      parentNavigatorKey: _rootNavigatorKey,
      pageBuilder: (context, state) {
        final order = (state.extra is Order) ? state.extra as Order : null;
        return MaterialPage(
          key: _pageKey(state),
          child: order != null ? OrderDetailsScreen(order: order) : const OrdersScreen(),
        );
      },
    ),
    GoRoute(
      path: '/orders/digitp',
      name: 'orders-digitp',
      parentNavigatorKey: _rootNavigatorKey,
      pageBuilder: (context, state) {
        final permit = (state.extra is TransportPermit) ? state.extra as TransportPermit : null;
        return MaterialPage(
          key: _pageKey(state),
          child: permit != null ? DigitpPassScreen(permit: permit) : const OrdersScreen(),
        );
      },
    ),
    GoRoute(
      path: '/orders/tracking',
      name: 'orders-tracking',
      parentNavigatorKey: _rootNavigatorKey,
      pageBuilder: (context, state) {
        final del = (state.extra is Delivery) ? state.extra as Delivery : null;
        return MaterialPage(
          key: _pageKey(state),
          child: del != null ? DeliveryTrackingScreen(delivery: del) : const OrdersScreen(),
        );
      },
    ),
    GoRoute(
      path: '/inventory',
      name: 'inventory',
      parentNavigatorKey: _rootNavigatorKey,
      pageBuilder: (context, state) => MaterialPage(
        key: _pageKey(state),
        child: const InventoryScreen(),
      ),
    ),
    GoRoute(
      path: '/transfers',
      name: 'transfers',
      parentNavigatorKey: _rootNavigatorKey,
      pageBuilder: (context, state) => MaterialPage(
        key: _pageKey(state),
        child: const TransfersScreen(),
      ),
    ),
    GoRoute(
      path: '/enquiries',
      name: 'enquiries',
      parentNavigatorKey: _rootNavigatorKey,
      pageBuilder: (context, state) => MaterialPage(
        key: _pageKey(state),
        child: const EnquiriesScreen(),
      ),
    ),
    GoRoute(
      path: '/enquiries/create',
      name: 'enquiries-create',
      parentNavigatorKey: _rootNavigatorKey,
      pageBuilder: (context, state) => MaterialPage(
        key: _pageKey(state),
        child: const CreateEnquiryScreen(),
      ),
    ),
    GoRoute(
      path: '/enquiries/detail',
      name: 'enquiries-detail',
      parentNavigatorKey: _rootNavigatorKey,
      pageBuilder: (context, state) {
        final enq = (state.extra is Enquiry) ? state.extra as Enquiry : null;
        return MaterialPage(
          key: _pageKey(state),
          child: EnquiryDetailsScreen(enquiry: enq),
        );
      },
    ),
    GoRoute(
      path: '/consumer/projects',
      name: 'consumer-projects',
      parentNavigatorKey: _rootNavigatorKey,
      pageBuilder: (context, state) => MaterialPage(
        key: _pageKey(state),
        child: const ConsumerProjectsScreen(),
      ),
    ),
    GoRoute(
      path: '/consumer/projects/register',
      name: 'consumer-projects-register',
      parentNavigatorKey: _rootNavigatorKey,
      pageBuilder: (context, state) => MaterialPage(
        key: _pageKey(state),
        child: const ConsumerProjectRegistrationScreen(),
      ),
    ),
    GoRoute(
      path: '/consumer/projects/detail',
      name: 'consumer-projects-detail',
      parentNavigatorKey: _rootNavigatorKey,
      pageBuilder: (context, state) {
        final proj = (state.extra is Project) ? state.extra as Project : null;
        return MaterialPage(
          key: _pageKey(state),
          child: proj != null ? ConsumerProjectDetailsScreen(project: proj) : const ConsumerProjectsScreen(),
        );
      },
    ),
    GoRoute(
      path: '/organization/projects/create',
      name: 'org-projects-create',
      parentNavigatorKey: _rootNavigatorKey,
      pageBuilder: (context, state) => MaterialPage(
        key: _pageKey(state),
        child: const CreateProjectScreen(),
      ),
    ),
    GoRoute(
      path: '/organization/projects/detail',
      name: 'org-projects-detail',
      parentNavigatorKey: _rootNavigatorKey,
      pageBuilder: (context, state) {
        final proj = (state.extra is Project) ? state.extra as Project : null;
        return MaterialPage(
          key: _pageKey(state),
          child: proj != null ? ProjectDetailsScreen(project: proj) : const ProjectsScreen(),
        );
      },
    ),
    GoRoute(
      path: '/organization/packages/create',
      name: 'org-packages-create',
      parentNavigatorKey: _rootNavigatorKey,
      pageBuilder: (context, state) {
        final proj = (state.extra is Project) ? state.extra as Project? : null;
        return MaterialPage(
          key: _pageKey(state),
          child: CreatePackageScreen(project: proj),
        );
      },
    ),
    GoRoute(
      path: '/organization/supervisors',
      name: 'org-supervisors',
      parentNavigatorKey: _rootNavigatorKey,
      pageBuilder: (context, state) => MaterialPage(
        key: _pageKey(state),
        child: const SupervisorsScreen(),
      ),
    ),
    GoRoute(
      path: '/organization/supervisors/create',
      name: 'org-supervisors-create',
      parentNavigatorKey: _rootNavigatorKey,
      pageBuilder: (context, state) => MaterialPage(
        key: _pageKey(state),
        child: const RegisterSupervisorScreen(),
      ),
    ),
    GoRoute(
      path: '/organization/packages/detail',
      name: 'org-packages-detail',
      parentNavigatorKey: _rootNavigatorKey,
      pageBuilder: (context, state) {
        final pkg = (state.extra is Package) ? state.extra as Package : null;
        return MaterialPage(
          key: _pageKey(state),
          child: pkg != null ? PackageDetailsScreen(package: pkg) : const ProjectsScreen(),
        );
      },
    ),
    GoRoute(
      path: '/minerals',
      name: 'minerals',
      parentNavigatorKey: _rootNavigatorKey,
      pageBuilder: (context, state) => MaterialPage(
        key: _pageKey(state),
        child: const MineralCatalogScreen(),
      ),
    ),
    GoRoute(
      path: '/minerals/stock-points',
      name: 'minerals-stock-points',
      parentNavigatorKey: _rootNavigatorKey,
      pageBuilder: (context, state) => MaterialPage(
        key: _pageKey(state),
        child: const StockPointMapScreen(),
      ),
    ),
    GoRoute(
      path: '/minerals/stock-points/detail',
      name: 'minerals-stock-points-detail',
      parentNavigatorKey: _rootNavigatorKey,
      pageBuilder: (context, state) {
        final sp = (state.extra is StockPoint) ? state.extra as StockPoint : null;
        return MaterialPage(
          key: _pageKey(state),
          child: sp != null ? StockPointDetailsScreen(stockPoint: sp) : const StockPointMapScreen(),
        );
      },
    ),
    GoRoute(
      path: '/settings',
      name: 'settings',
      parentNavigatorKey: _rootNavigatorKey,
      pageBuilder: (context, state) => MaterialPage(
        key: _pageKey(state),
        child: const SettingsScreen(),
      ),
    ),

    // Compatibility Route Aliases matching React Prototype URLs
    GoRoute(path: '/projects', redirect: (_, __) => AppConfig.enableOrganizationFlow ? '/organization/projects' : '/consumer/projects'),
    GoRoute(path: '/projects/new', redirect: (_, __) => AppConfig.enableOrganizationFlow ? '/organization/projects/create' : '/consumer/projects/register'),
    GoRoute(path: '/temporary-excavation', redirect: (_, __) => '/excavation'),
    GoRoute(path: '/temporary-excavation/new', redirect: (_, __) => '/excavation/new'),
    GoRoute(path: '/stock-points', redirect: (_, __) => '/minerals/stock-points'),
    GoRoute(path: '/verify', redirect: (_, __) => '/otp'),
    GoRoute(path: '/supervisors', redirect: (_, __) => AppConfig.enableOrganizationFlow ? '/organization/supervisors' : '/home'),
    GoRoute(path: '/prototype/persona', redirect: (_, __) => '/persona-switch'),
  ],
);
