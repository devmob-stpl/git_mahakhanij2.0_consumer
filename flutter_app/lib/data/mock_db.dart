import '../domain/common.dart';
import '../domain/user.dart';
import '../domain/organization.dart';
import '../domain/mineral.dart';
import '../domain/order.dart';
import '../domain/delivery.dart';
import '../domain/inventory.dart';
import '../domain/temporary_excavation.dart';

/// Preloaded Mock Database for offline development & client demonstration
class MockDb {
  static final MockDb _instance = MockDb._internal();
  factory MockDb() => _instance;
  MockDb._internal() {
    _initData();
  }

  late List<User> users;
  late List<Organization> organizations;
  late List<Project> projects;
  late List<Package> packages;
  late List<SupervisorInfo> supervisors;
  late List<Mineral> minerals;
  late List<StockPoint> stockPoints;
  late List<Order> orders;
  late List<Delivery> deliveries;
  late List<InventoryBalance> inventoryBalances;
  late List<ConsumptionEntry> consumptionEntries;
  late List<TemporaryExcavationApplication> excavationApplications;

  void _initData() {
    users = [
      const User(
        id: 'user-org-001',
        fullName: 'Rohit Sanghavi',
        mobileNumber: '9822014576',
        email: 'rohit.s@sanghaviinfra.in',
        userType: UserType.organization,
        organizationId: 'org-001',
        designation: 'Project Procurement Lead',
        createdAt: '2023-01-15T10:00:00Z',
      ),
      const User(
        id: 'user-con-001',
        fullName: 'Aniket Deshmukh',
        mobileNumber: '9730845120',
        email: 'aniket.deshmukh@gmail.com',
        userType: UserType.normalConsumer,
        deliveryAddress: Address(
          line1: 'Plot 14, Pathardi Phata',
          village: 'Pathardi',
          taluka: 'Nashik',
          district: 'Nashik',
          pincode: '422010',
        ),
        deliveryGeo: GeoPoint(latitude: 19.9975, longitude: 73.7898),
        createdAt: '2023-06-10T10:00:00Z',
      ),
      const User(
        id: 'user-sup-001',
        fullName: 'Sunil Gaikwad',
        mobileNumber: '9145220087',
        userType: UserType.supervisor,
        organizationId: 'org-001',
        assignedPackageId: 'pkg-1',
        designation: 'Package Lead Inspector',
        createdAt: '2024-01-20T10:00:00Z',
      ),
    ];

    organizations = [
      const Organization(
        id: 'org-001',
        legalName: 'Sanghavi Infrastructure Pvt. Ltd.',
        registrationNumber: 'MH/MK/ENT/2023/018842',
        panNumber: 'AAACS8842F',
        gstNumber: '27AAACS8842F1Z5',
        registeredAddress: Address(
          line1: '4th Floor, Sanghavi House, LBS Marg',
          village: 'Kurla',
          taluka: 'Kurla',
          district: 'Mumbai Suburban',
          pincode: '400070',
        ),
        createdAt: '2023-01-01T00:00:00Z',
      ),
    ];

    projects = [
      const Project(
        id: 'proj-1',
        organizationId: 'org-001',
        name: 'Metro Line 4 - Wadala to Kasarvadavali',
        code: 'PRJ-MMRDA-ML4',
        description: 'Elevated viaduct and 32 stations along eastern expressway corridor',
        status: 'ACTIVE',
        startDate: '2024-01-01',
        location: Address(
          line1: 'Eastern Express Highway Section',
          taluka: 'Thane',
          district: 'Thane',
          pincode: '400601',
        ),
      ),
      const Project(
        id: 'proj-2',
        organizationId: 'org-001',
        name: 'Coastal Road Connector Package 2',
        code: 'PRJ-BMC-CR2',
        description: 'Undersea tunnel interchange and bridge ramps',
        status: 'ACTIVE',
        startDate: '2024-03-01',
        location: Address(
          line1: 'Worli Seaface Junction',
          taluka: 'Worli',
          district: 'Mumbai',
          pincode: '400018',
        ),
      ),
    ];

    packages = [
      const Package(
        id: 'pkg-1',
        projectId: 'proj-1',
        organizationId: 'org-001',
        name: 'Package 02 - Viaduct Ch. 12+500 to 24+000',
        code: 'PKG-02-VIA',
        siteAddress: Address(
          line1: 'Casting Yard, Near Mulund Toll Plaza',
          taluka: 'Kurla',
          district: 'Mumbai Suburban',
          pincode: '400080',
        ),
        siteGeo: GeoPoint(latitude: 19.1764, longitude: 72.9567),
        status: 'ACTIVE',
        startDate: '2024-01-10',
        supervisor: SupervisorInfo(
          id: 'sup-1',
          name: 'S. R. Pawar',
          mobileNumber: '9145220087',
          employeeCode: 'SUP-4417',
          assignedPackageId: 'pkg-1',
          assignedPackageName: 'Package 02 - Viaduct',
        ),
      ),
      const Package(
        id: 'pkg-2',
        projectId: 'proj-1',
        organizationId: 'org-001',
        name: 'Package 03 - Station Box CH-04 to CH-08',
        code: 'PKG-03-STN',
        siteAddress: Address(
          line1: 'Thane Station Interchange Site',
          taluka: 'Thane',
          district: 'Thane',
          pincode: '400602',
        ),
        siteGeo: GeoPoint(latitude: 19.2183, longitude: 72.9781),
        status: 'ACTIVE',
        startDate: '2024-02-15',
        supervisor: SupervisorInfo(
          id: 'sup-2',
          name: 'M. A. Kulkarni',
          mobileNumber: '9028117744',
          employeeCode: 'SUP-4482',
          assignedPackageId: 'pkg-2',
          assignedPackageName: 'Package 03 - Station Box',
        ),
      ),
    ];

    supervisors = [
      const SupervisorInfo(
        id: 'sup-1',
        name: 'S. R. Pawar',
        mobileNumber: '9145220087',
        employeeCode: 'SUP-4417',
        assignedPackageId: 'pkg-1',
        assignedPackageName: 'Package 02 - Viaduct',
      ),
      const SupervisorInfo(
        id: 'sup-2',
        name: 'M. A. Kulkarni',
        mobileNumber: '9028117744',
        employeeCode: 'SUP-4482',
        assignedPackageId: 'pkg-2',
        assignedPackageName: 'Package 03 - Station Box',
      ),
    ];

    minerals = [
      const Mineral(
        id: 'min-1',
        name: 'Natural River Sand',
        code: 'MIN-SND-01',
        category: 'SAND',
        description: 'Standard grading riverbed sand washed for high strength concrete',
        standardUnit: 'BRASS',
        defaultRatePerUnit: 6500.0,
      ),
      const Mineral(
        id: 'min-2',
        name: 'Manufactured Sand (M-Sand)',
        code: 'MIN-MSND-02',
        category: 'SAND',
        description: 'VSI crushed granite cubical sand for plastering and structural mix',
        standardUnit: 'BRASS',
        defaultRatePerUnit: 4200.0,
      ),
      const Mineral(
        id: 'min-3',
        name: 'Stone Aggregate 20mm',
        code: 'MIN-AGG-20',
        category: 'AGGREGATE',
        description: 'Blue metal 20mm basalt aggregate for RCC casting',
        standardUnit: 'BRASS',
        defaultRatePerUnit: 3400.0,
      ),
      const Mineral(
        id: 'min-4',
        name: 'Murrum / Soil Filling',
        code: 'MIN-MRM-01',
        category: 'MURRUM',
        description: 'Compacted murrum for road subgrade embankment filling',
        standardUnit: 'BRASS',
        defaultRatePerUnit: 1800.0,
      ),
    ];

    stockPoints = [
      const StockPoint(
        id: 'sp-1',
        name: 'Talegaon Government Minor Mineral Depot',
        code: 'SP-PUN-042',
        operatorName: 'Maharashtra State Mining Corporation (MSMC)',
        contactPhone: '020-25671234',
        address: Address(
          line1: 'Survey 144, Talegaon Dabhade',
          taluka: 'Maval',
          district: 'Pune',
          pincode: '410506',
        ),
        geo: GeoPoint(latitude: 18.7354, longitude: 73.6756),
        availableMineralIds: ['min-1', 'min-2', 'min-3', 'min-4'],
        distanceKm: 18.4,
      ),
      const StockPoint(
        id: 'sp-2',
        name: 'Bhiwandi Approved Aggregate Hub',
        code: 'SP-THN-019',
        operatorName: 'Konkan Mineral Logistics Ltd.',
        contactPhone: '022-27894567',
        address: Address(
          line1: 'Kalyan Naka Quarry Zone',
          taluka: 'Bhiwandi',
          district: 'Thane',
          pincode: '421302',
        ),
        geo: GeoPoint(latitude: 19.2967, longitude: 73.0631),
        availableMineralIds: ['min-2', 'min-3'],
        distanceKm: 24.2,
      ),
    ];

    orders = [
      const Order(
        id: 'ord-101',
        orderNumber: 'ORD-2024-8842',
        organizationId: 'org-001',
        projectId: 'proj-1',
        packageId: 'pkg-1',
        mineralId: 'min-3',
        mineralName: 'Stone Aggregate 20mm',
        orderedQuantity: Quantity(value: 80.0, unit: 'BRASS'),
        deliveredQuantity: Quantity(value: 60.0, unit: 'BRASS'),
        totalAmount: Money(amount: 272000.0),
        status: OrderStatus.partiallyDelivered,
        stockPointId: 'sp-2',
        stockPointName: 'Bhiwandi Approved Aggregate Hub',
        createdAt: '2024-05-10T09:30:00Z',
        deliveryIds: ['del-01', 'del-02'],
      ),
    ];

    deliveries = [
      const Delivery(
        id: 'del-003',
        deliveryNumber: 'DLV/2026/020115',
        orderId: 'ord-101',
        organizationId: 'org-001',
        packageId: 'pkg-1',
        transportPermit: TransportPermit(
          etpNumber: 'ETP/2026/MH/0436610',
          qrPayload: 'MHKNJ:ETP:2026:MH:0436610',
          issuedAt: '2026-09-21T08:00:00Z',
          validUntil: '2026-09-22T08:00:00Z',
          sourceQuarryName: 'Lonikand Murum Quarry',
          sourceStockPointId: 'sp-1',
          destinationLabel: 'Package 02 - Viaduct Casting Yard',
          destinationGeo: GeoPoint(latitude: 19.1764, longitude: 72.9567),
          mineralId: 'min-3',
          permittedQuantity: Quantity(value: 10.0, unit: 'BRASS'),
          vehicleNumber: 'MH-04-HY-1122',
        ),
        vehicle: Vehicle(
          registrationNumber: 'MH-04-HY-1122',
          transporterName: 'Konkan Roadlines',
          driverName: 'Rameshwar Patil',
          driverMobileNumber: '9766443322',
        ),
        status: DeliveryStatus.arrivedAtDestination,
        dispatchedAt: '2026-09-21T09:15:00Z',
      ),
      const Delivery(
        id: 'del-004',
        deliveryNumber: 'DLV/2026/020088',
        orderId: 'ord-101',
        organizationId: 'org-001',
        packageId: 'pkg-1',
        transportPermit: TransportPermit(
          etpNumber: 'ETP/2026/MH/0436344',
          qrPayload: 'MHKNJ:ETP:2026:MH:0436344',
          issuedAt: '2026-09-21T10:00:00Z',
          validUntil: '2026-09-22T10:00:00Z',
          sourceQuarryName: 'Godavari Sand Ghat',
          sourceStockPointId: 'sp-1',
          destinationLabel: 'Plot 14, Pathardi Phata, Nashik',
          destinationGeo: GeoPoint(latitude: 19.9975, longitude: 73.7898),
          mineralId: 'min-1',
          permittedQuantity: Quantity(value: 12.0, unit: 'BRASS'),
          vehicleNumber: 'MH-15-BN-4402',
        ),
        vehicle: Vehicle(
          registrationNumber: 'MH-15-BN-4402',
          transporterName: 'Godavari Transport',
          driverName: 'Nitin Wagh',
          driverMobileNumber: '9689330214',
        ),
        status: DeliveryStatus.inTransit,
        dispatchedAt: '2026-09-21T11:00:00Z',
      ),
      const Delivery(
        id: 'del-005',
        deliveryNumber: 'DLV/2026/020140',
        orderId: 'ord-101',
        organizationId: 'org-001',
        packageId: 'pkg-1',
        transportPermit: TransportPermit(
          etpNumber: 'ETP/2026/MH/0436781',
          qrPayload: 'MHKNJ:ETP:2026:MH:0436781',
          issuedAt: '2026-09-21T11:30:00Z',
          validUntil: '2026-09-22T11:30:00Z',
          sourceQuarryName: 'Lonikand Murum Quarry',
          sourceStockPointId: 'sp-1',
          destinationLabel: 'Package 02 - Viaduct Casting Yard',
          destinationGeo: GeoPoint(latitude: 19.1764, longitude: 72.9567),
          mineralId: 'min-4',
          permittedQuantity: Quantity(value: 40.0, unit: 'BRASS'),
          vehicleNumber: 'MH-12-XY-3391',
        ),
        vehicle: Vehicle(
          registrationNumber: 'MH-12-XY-3391',
          transporterName: 'Deccan Carriers',
          driverName: 'Sachin Kale',
          driverMobileNumber: '9764110238',
        ),
        status: DeliveryStatus.inTransit,
        dispatchedAt: '2026-09-21T12:00:00Z',
      ),
      const Delivery(
        id: 'del-001',
        deliveryNumber: 'DLV/2026/019740',
        orderId: 'ord-101',
        organizationId: 'org-001',
        packageId: 'pkg-1',
        transportPermit: TransportPermit(
          etpNumber: 'ETP/2026/MH/0431188',
          qrPayload: 'MHKNJ:ETP:2026:MH:0431188',
          issuedAt: '2026-09-12T07:10:00Z',
          validUntil: '2026-09-13T07:10:00Z',
          sourceQuarryName: 'Titwala Trap Quarry',
          sourceStockPointId: 'sp-2',
          destinationLabel: 'Package 02 - Viaduct Casting Yard',
          destinationGeo: GeoPoint(latitude: 19.1764, longitude: 72.9567),
          mineralId: 'min-3',
          permittedQuantity: Quantity(value: 50.0, unit: 'BRASS'),
          vehicleNumber: 'MH-04-GG-1234',
        ),
        vehicle: Vehicle(
          registrationNumber: 'MH-04-GG-1234',
          transporterName: 'Konkan Roadlines',
          driverName: 'Suresh Patil',
          driverMobileNumber: '9820117453',
        ),
        status: DeliveryStatus.received,
        dispatchedAt: '2026-09-12T07:40:00Z',
        deliveredAt: '2026-09-12T11:20:00Z',
      ),
      const Delivery(
        id: 'del-002',
        deliveryNumber: 'DLV/2026/019902',
        orderId: 'ord-101',
        organizationId: 'org-001',
        packageId: 'pkg-1',
        transportPermit: TransportPermit(
          etpNumber: 'ETP/2026/MH/0433027',
          qrPayload: 'MHKNJ:ETP:2026:MH:0433027',
          issuedAt: '2026-09-19T06:55:00Z',
          validUntil: '2026-09-20T06:55:00Z',
          sourceQuarryName: 'Titwala Trap Quarry',
          sourceStockPointId: 'sp-2',
          destinationLabel: 'Package 02 - Viaduct Casting Yard',
          destinationGeo: GeoPoint(latitude: 19.1764, longitude: 72.9567),
          mineralId: 'min-3',
          permittedQuantity: Quantity(value: 50.0, unit: 'BRASS'),
          vehicleNumber: 'MH-04-JK-8891',
        ),
        vehicle: Vehicle(
          registrationNumber: 'MH-04-JK-8891',
          transporterName: 'Konkan Roadlines',
          driverName: 'Ramesh Jadhav',
          driverMobileNumber: '9867224180',
        ),
        status: DeliveryStatus.receivedWithDiscrepancy,
        dispatchedAt: '2026-09-19T07:25:00Z',
        deliveredAt: '2026-09-19T11:46:00Z',
        discrepancyReport: DiscrepancyReport(
          manifestQuantity: Quantity(value: 50.0, unit: 'BRASS'),
          actualReceivedQuantity: Quantity(value: 47.0, unit: 'BRASS'),
          remarks: 'Shortage of 3 BRASS recorded at site weighbridge.',
          reportedAt: '2026-09-19T11:46:00Z',
          reportedByUserId: 'user-sup-001',
        ),
      ),
    ];

    inventoryBalances = [
      const InventoryBalance(
        id: 'inv-1',
        packageId: 'pkg-1',
        mineralId: 'min-3',
        mineralName: 'Stone Aggregate 20mm',
        receivedBalance: Quantity(value: 60.0, unit: 'BRASS'),
        consumedBalance: Quantity(value: 22.5, unit: 'BRASS'),
        currentAvailableBalance: Quantity(value: 37.5, unit: 'BRASS'),
        lastUpdatedAt: '2024-05-14T11:00:00Z',
      ),
      const InventoryBalance(
        id: 'inv-2',
        packageId: 'pkg-1',
        mineralId: 'min-1',
        mineralName: 'Natural River Sand',
        receivedBalance: Quantity(value: 40.0, unit: 'BRASS'),
        consumedBalance: Quantity(value: 18.0, unit: 'BRASS'),
        currentAvailableBalance: Quantity(value: 22.0, unit: 'BRASS'),
        lastUpdatedAt: '2024-05-13T16:45:00Z',
      ),
    ];

    consumptionEntries = [
      const ConsumptionEntry(
        id: 'con-1',
        inventoryBalanceId: 'inv-1',
        packageId: 'pkg-1',
        quantity: Quantity(value: 5.0, unit: 'BRASS'),
        purpose: 'Pier Cap C24 concrete batching mix',
        recordedByUserId: 'user-sup-1',
        recordedByName: 'S. R. Pawar (Supervisor)',
        recordedAt: '2024-05-14T10:30:00Z',
      ),
    ];

    const defaultApplicant = ApplicantDetails(
      fullName: 'Rohit Sanghavi',
      mobileNumber: '9822014576',
      panNumber: 'AFZPS1234K',
      registeredAddress: Address(
        line1: '4th Floor, Sanghavi House, LBS Marg',
        village: 'Kurla',
        taluka: 'Kurla',
        district: 'Mumbai Suburban',
        pincode: '400070',
      ),
    );
    const defaultSiteGeo = GeoPoint(latitude: 18.5204, longitude: 73.8567);
    const defaultAppFee = Money(amount: 520.0);

    excavationApplications = [
      // 1. TEA/2026/001521 - Submitted
      const TemporaryExcavationApplication(
        id: 'exc-1521',
        applicationNumber: 'TEA/2026/001521',
        organizationId: 'org-001',
        applicant: defaultApplicant,
        mineralId: 'min-1',
        mineralName: 'River Sand',
        estimatedQuantity: Quantity(value: 100, unit: 'BRASS'),
        siteAddress: Address(line1: 'Kharadi Site', village: 'Kharadi', taluka: 'Haveli', district: 'Pune', pincode: '411014'),
        siteGeo: defaultSiteGeo,
        village: 'Kharadi',
        surveyNumber: '102/1',
        fromDate: '2026-09-01',
        toDate: '2026-11-30',
        applicationFee: defaultAppFee,
        status: TemporaryExcavationStatus.submitted,
        purpose: 'Application fee of ₹520 paid. Ready for departmental review.',
        statusUpdatedAt: '2026-09-18T10:00:00Z',
      ),
      // 2. TEA/2026/001547 - Query Raised (Action Required)
      const TemporaryExcavationApplication(
        id: 'exc-1547',
        applicationNumber: 'TEA/2026/001547',
        organizationId: 'org-001',
        applicant: defaultApplicant,
        mineralId: 'min-1',
        mineralName: 'River Sand',
        estimatedQuantity: Quantity(value: 400, unit: 'BRASS'),
        siteAddress: Address(line1: 'Wagholi Site', village: 'Wagholi', taluka: 'Haveli', district: 'Pune', pincode: '412207'),
        siteGeo: defaultSiteGeo,
        village: 'Wagholi',
        surveyNumber: '42/1B',
        fromDate: '2026-09-01',
        toDate: '2026-11-30',
        applicationFee: defaultAppFee,
        status: TemporaryExcavationStatus.queryRaised,
        purpose: 'Revised site plan required with clear demarcation of excavation boundary.',
        statusUpdatedAt: '2026-09-15T10:00:00Z',
      ),
      // 3. TEA/2026/001688 - Under Review
      const TemporaryExcavationApplication(
        id: 'exc-1688',
        applicationNumber: 'TEA/2026/001688',
        organizationId: 'org-001',
        applicant: defaultApplicant,
        mineralId: 'min-4',
        mineralName: 'Murum',
        estimatedQuantity: Quantity(value: 200, unit: 'BRASS'),
        siteAddress: Address(line1: 'Alsangikar Site', village: 'Alsangikar', taluka: 'Sholapur', district: 'Sholapur', pincode: '413001'),
        siteGeo: defaultSiteGeo,
        village: 'Alsangikar',
        surveyNumber: '155/4',
        fromDate: '2026-09-01',
        toDate: '2026-11-30',
        applicationFee: defaultAppFee,
        status: TemporaryExcavationStatus.underReview,
        purpose: 'Site boundary inspection and verification in progress by Revenue Officer.',
        statusUpdatedAt: '2026-09-14T10:00:00Z',
      ),
      // 4. TEA/2026/001592 - Payment Due (Demand Note Issued)
      TemporaryExcavationApplication(
        id: 'exc-1592',
        applicationNumber: 'TEA/2026/001592',
        organizationId: 'org-001',
        applicant: defaultApplicant,
        mineralId: 'min-4',
        mineralName: 'Murum',
        estimatedQuantity: const Quantity(value: 6000, unit: 'BRASS'),
        siteAddress: const Address(line1: 'Vashind Site', village: 'Vashind', taluka: 'Shahapur', district: 'Thane', pincode: '421604'),
        siteGeo: defaultSiteGeo,
        village: 'Vashind',
        surveyNumber: '90',
        fromDate: '2026-09-01',
        toDate: '2026-11-30',
        applicationFee: defaultAppFee,
        status: TemporaryExcavationStatus.demandNoteIssued,
        purpose: 'Royalty calculation complete. Challan payment of ₹2,68,000 due.',
        demandNote: const DemandNote(
          demandNoteNumber: 'DN-SHA-2026-0090',
          issuedAt: '2026-09-14T09:00:00Z',
          dueDate: '2026-09-28',
          totalAmount: Money(amount: 268000),
        ),
        statusUpdatedAt: '2026-09-14T09:00:00Z',
      ),
      // 5. TEA/2026/001589 - Rejected
      const TemporaryExcavationApplication(
        id: 'exc-1589',
        applicationNumber: 'TEA/2026/001589',
        organizationId: 'org-001',
        applicant: defaultApplicant,
        mineralId: 'min-4',
        mineralName: 'Murum',
        estimatedQuantity: Quantity(value: 0, unit: 'BRASS'),
        siteAddress: Address(line1: 'Vashind Site', village: 'Vashind', taluka: 'Shahapur', district: 'Thane', pincode: '421604'),
        siteGeo: defaultSiteGeo,
        village: 'Vashind',
        surveyNumber: '45/2',
        fromDate: '2026-09-01',
        toDate: '2026-11-30',
        applicationFee: defaultAppFee,
        status: TemporaryExcavationStatus.rejected,
        purpose: 'Proposed excavation site falls within 100m restricted river buffer zone. Tehsil environmental NOC rejected.',
        statusUpdatedAt: '2026-09-13T10:00:00Z',
      ),
      // 6. TEA/2026/001620 - Under Review
      const TemporaryExcavationApplication(
        id: 'exc-1620',
        applicationNumber: 'TEA/2026/001620',
        organizationId: 'org-001',
        applicant: defaultApplicant,
        mineralId: 'min-3',
        mineralName: 'Bhasal (Khad)',
        estimatedQuantity: Quantity(value: 1000, unit: 'BRASS'),
        siteAddress: Address(line1: 'Kharadi Site', village: 'Kharadi', taluka: 'Haveli', district: 'Pune', pincode: '411014'),
        siteGeo: defaultSiteGeo,
        village: 'Kharadi',
        surveyNumber: '37',
        fromDate: '2026-09-01',
        toDate: '2026-11-30',
        applicationFee: defaultAppFee,
        status: TemporaryExcavationStatus.underReview,
        purpose: 'Site boundary inspection and verification in progress by Revenue Officer.',
        statusUpdatedAt: '2026-09-13T10:00:00Z',
      ),
      // 7. TEA/2026/001284 - Under Review
      const TemporaryExcavationApplication(
        id: 'exc-1284',
        applicationNumber: 'TEA/2026/001284',
        organizationId: 'org-001',
        applicant: defaultApplicant,
        mineralId: 'min-4',
        mineralName: 'Murum',
        estimatedQuantity: Quantity(value: 1100, unit: 'BRASS'),
        siteAddress: Address(line1: 'Vashind Site', village: 'Vashind', taluka: 'Shahapur', district: 'Thane', pincode: '421604'),
        siteGeo: defaultSiteGeo,
        village: 'Vashind',
        surveyNumber: '118/2',
        fromDate: '2026-09-01',
        toDate: '2026-11-30',
        applicationFee: defaultAppFee,
        status: TemporaryExcavationStatus.underReview,
        purpose: 'Site boundary inspection and verification in progress by Revenue Officer.',
        statusUpdatedAt: '2026-09-12T10:00:00Z',
      ),
      // 8. TEA/2026/000981 - Order Issued (Permit Ready)
      TemporaryExcavationApplication(
        id: 'exc-0981',
        applicationNumber: 'TEA/2026/000981',
        organizationId: 'org-001',
        applicant: defaultApplicant,
        mineralId: 'min-3',
        mineralName: 'Minor Mineral',
        estimatedQuantity: const Quantity(value: 1500, unit: 'BRASS'),
        siteAddress: const Address(line1: 'Talegaon Dabhade Site', village: 'Talegaon Dabhade', taluka: 'Maval', district: 'Pune', pincode: '410506'),
        siteGeo: defaultSiteGeo,
        village: 'Talegaon Dabhade',
        surveyNumber: '102/A',
        fromDate: '2026-09-01',
        toDate: '2026-11-30',
        applicationFee: defaultAppFee,
        status: TemporaryExcavationStatus.orderIssued,
        purpose: 'Official excavation order issued. Transport permits & DigiTP authorized.',
        excavationOrder: const ExcavationOrder(
          orderNumber: 'OrderNo-04/08/2026-1',
          issuedAt: '2026-09-07T10:00:00Z',
          validFrom: '2026-09-07',
          validUntil: '2026-12-31',
          permittedQuantity: Quantity(value: 1500, unit: 'BRASS'),
        ),
        statusUpdatedAt: '2026-09-07T10:00:00Z',
      ),
      // 9. TEA/2026/001182 - Order Issued (Permit Ready)
      TemporaryExcavationApplication(
        id: 'exc-1182',
        applicationNumber: 'TEA/2026/001182',
        organizationId: 'org-001',
        applicant: defaultApplicant,
        mineralId: 'min-4',
        mineralName: 'Murum',
        estimatedQuantity: const Quantity(value: 900, unit: 'BRASS'),
        siteAddress: const Address(line1: 'Kasauli Site', village: 'Kasauli', taluka: 'Shahapur', district: 'Thane', pincode: '421604'),
        siteGeo: defaultSiteGeo,
        village: 'Kasauli',
        surveyNumber: '203',
        fromDate: '2026-09-01',
        toDate: '2026-11-30',
        applicationFee: defaultAppFee,
        status: TemporaryExcavationStatus.orderIssued,
        purpose: 'Official excavation order issued. Transport permits & DigiTP authorized.',
        excavationOrder: const ExcavationOrder(
          orderNumber: 'OrderNo-04/08/2026-1',
          issuedAt: '2026-09-05T10:00:00Z',
          validFrom: '2026-09-05',
          validUntil: '2026-12-31',
          permittedQuantity: Quantity(value: 900, unit: 'BRASS'),
        ),
        statusUpdatedAt: '2026-09-05T10:00:00Z',
      ),
      // 10. In-progress Draft (Auto-saved)
      const TemporaryExcavationApplication(
        id: 'exc-draft-1',
        applicationNumber: 'DRAFT-TEMP-001',
        organizationId: 'org-001',
        applicant: defaultApplicant,
        mineralId: 'min-3',
        mineralName: 'Stone Aggregate 20mm',
        estimatedQuantity: Quantity(value: 22.0, unit: 'BRASS'),
        purpose: 'Temporary quarrying for infrastructure project work.',
        siteAddress: Address(
          line1: 'Survey 42, Near Highway Exit',
          village: 'Wagholi',
          taluka: 'Haveli',
          district: 'Pune',
          pincode: '412207',
        ),
        siteGeo: defaultSiteGeo,
        village: 'Wagholi',
        surveyNumber: '42/1B',
        fromDate: '2026-09-01',
        toDate: '2026-11-30',
        applicationFee: defaultAppFee,
        status: TemporaryExcavationStatus.draft,
        lastStepIndex: 2,
        statusUpdatedAt: '2026-09-14T09:15:00Z',
      ),
    ];
  }
}

