import '../domain/common.dart';
import '../domain/temporary_excavation.dart';

class OptionItem {
  final String value;
  final String label;
  final String? description;

  const OptionItem({
    required this.value,
    required this.label,
    this.description,
  });
}

class DocumentDefinition {
  final String kind;
  final String category; // 'IDENTITY_LAND' | 'NOC' | 'PERMISSION' | 'OTHER'
  final String label;
  final String importance; // 'MANDATORY' | 'OPTIONAL'
  final bool requiresDocumentNumber;

  const DocumentDefinition({
    required this.kind,
    required this.category,
    required this.label,
    required this.importance,
    this.requiresDocumentNumber = false,
  });
}

class ApplicationFeeBreakdown {
  final double quantityBrass;
  final String slabLabel;
  final Money baseFee;
  final Money stampDuty;
  final Money totalFee;

  const ApplicationFeeBreakdown({
    required this.quantityBrass,
    required this.slabLabel,
    required this.baseFee,
    required this.stampDuty,
    required this.totalFee,
  });
}

class DemandNoteChannelBreakdown {
  final Money grasAmount;
  final Money dmf;
  final Money siCharges;
  final Money siTax;
  final Money tcs;
  final Money mahakhanijTotal;
  final Money grandTotal;

  const DemandNoteChannelBreakdown({
    required this.grasAmount,
    required this.dmf,
    required this.siCharges,
    required this.siTax,
    required this.tcs,
    required this.mahakhanijTotal,
    required this.grandTotal,
  });
}

class ExcavationRules {
  ExcavationRules._();

  static const double stampDutyAmount = 20.0;

  static const List<OptionItem> proposalApplicationTypes = [
    OptionItem(
      value: 'QUARRY_TEMPORARY_PLOT',
      label: 'Quarry – Temporary Plot Proposal',
      description: 'Commercial minor mineral extraction from temporary allocated plot',
    ),
    OptionItem(
      value: 'QUARRY_PROJECT_SELF_CONSUMPTION',
      label: 'Quarry For Project - Self Consumption',
      description: 'Material used strictly for project work / infrastructure development',
    ),
  ];

  static const List<OptionItem> proposalLevels = [
    OptionItem(value: 'DISTRICT_LEVEL', label: 'District Level (Revenue Officer)'),
    OptionItem(value: 'SUB_DIVISIONAL_LEVEL', label: 'Sub-Divisional Level (SDO / Tehsildar)'),
    OptionItem(value: 'STATE_LEVEL', label: 'State Level (Directorate of Geology & Mining)'),
  ];

  static const List<OptionItem> locationCategories = [
    OptionItem(value: 'RURAL', label: 'Rural'),
    OptionItem(value: 'URBAN', label: 'Urban'),
  ];

  static const List<OptionItem> plotLocations = [
    OptionItem(value: 'INTERIOR', label: 'Interior / Land Plot'),
    OptionItem(value: 'RIVERBED', label: 'Riverbed / Nalla'),
    OptionItem(value: 'PLAIN_AGRICULTURAL', label: 'Plain / Agricultural Land'),
    OptionItem(value: 'HILLY', label: 'Hilly / Slope Terrain'),
  ];

  static const List<OptionItem> districts = [
    OptionItem(value: 'Mumbai Suburban', label: 'Mumbai Suburban'),
    OptionItem(value: 'Pune', label: 'Pune'),
    OptionItem(value: 'Thane', label: 'Thane'),
    OptionItem(value: 'Nashik', label: 'Nashik'),
    OptionItem(value: 'Ahilyanagar', label: 'Ahilyanagar'),
    OptionItem(value: 'Nagpur', label: 'Nagpur'),
    OptionItem(value: 'Chhatrapati Sambhajinagar', label: 'Chhatrapati Sambhajinagar'),
  ];

  static const List<OptionItem> talukas = [
    OptionItem(value: 'Haveli', label: 'Haveli'),
    OptionItem(value: 'Pune City', label: 'Pune City'),
    OptionItem(value: 'Khed', label: 'Khed'),
    OptionItem(value: 'Shirur', label: 'Shirur'),
    OptionItem(value: 'Maval', label: 'Maval'),
    OptionItem(value: 'Kurla', label: 'Kurla'),
    OptionItem(value: 'Andheri', label: 'Andheri'),
    OptionItem(value: 'Borivali', label: 'Borivali'),
  ];

  static const List<OptionItem> villages = [
    OptionItem(value: 'Wagholi', label: 'Wagholi'),
    OptionItem(value: 'Hadapsar', label: 'Hadapsar'),
    OptionItem(value: 'Kharadi', label: 'Kharadi'),
    OptionItem(value: 'Baner', label: 'Baner'),
    OptionItem(value: 'Hinjawadi', label: 'Hinjawadi'),
    OptionItem(value: 'Bandra', label: 'Bandra'),
    OptionItem(value: 'Juhu', label: 'Juhu'),
  ];

  static const List<OptionItem> demandNoteOffices = [
    OptionItem(value: 'DMO_PUNE', label: 'District Mining Office, Pune'),
    OptionItem(value: 'DMO_AHILYANAGAR', label: 'District Mining Office, Ahilyanagar'),
    OptionItem(value: 'DMO_NAGPUR', label: 'District Mining Office, Nagpur'),
    OptionItem(value: 'DMO_THANE', label: 'District Mining Office, Thane'),
    OptionItem(value: 'DMO_CHHATRAPATI_SAMBHAJINAGAR', label: 'District Mining Office, Chhatrapati Sambhajinagar'),
  ];

  static const List<OptionItem> grasOffices = [
    OptionItem(value: 'GRAS_PUNE', label: 'Cyber Treasury Pune (GRAS MH)'),
    OptionItem(value: 'GRAS_AHILYANAGAR', label: 'Treasury Office Ahilyanagar (GRAS MH)'),
    OptionItem(value: 'GRAS_NAGPUR', label: 'Cyber Treasury Nagpur (GRAS MH)'),
    OptionItem(value: 'GRAS_MUMBAI', label: 'Pay & Accounts Office Mumbai (GRAS MH)'),
  ];

  static const List<DocumentDefinition> documentDefinitions = [
    /* Core Land & Identity */
    DocumentDefinition(kind: 'PAN_CARD', category: 'IDENTITY_LAND', label: 'PAN Card Document', importance: 'MANDATORY'),
    DocumentDefinition(kind: 'SEVEN_TWELVE', category: 'IDENTITY_LAND', label: '7/12 Extract (Satbara)', importance: 'MANDATORY'),
    DocumentDefinition(kind: 'OWNER_APPROVAL', category: 'IDENTITY_LAND', label: 'Owner Approval / Affidavit', importance: 'MANDATORY'),
    DocumentDefinition(kind: 'AADHAAR_CARD', category: 'IDENTITY_LAND', label: 'Aadhaar Card Document', importance: 'OPTIONAL'),
    DocumentDefinition(kind: 'GST_CERTIFICATE', category: 'IDENTITY_LAND', label: 'GST Registration Certificate', importance: 'OPTIONAL'),

    /* NOC Documents */
    DocumentDefinition(kind: 'NOC_PWD', category: 'NOC', label: 'Public Works Department (PWD)', importance: 'OPTIONAL', requiresDocumentNumber: true),
    DocumentDefinition(kind: 'NOC_MSEB', category: 'NOC', label: 'MSEB (Electricity Board)', importance: 'OPTIONAL', requiresDocumentNumber: true),
    DocumentDefinition(kind: 'NOC_MPCB', category: 'NOC', label: 'MPCB (Pollution Control)', importance: 'OPTIONAL', requiresDocumentNumber: true),
    DocumentDefinition(kind: 'NOC_FOREST', category: 'NOC', label: 'Forest Department', importance: 'OPTIONAL', requiresDocumentNumber: true),
    DocumentDefinition(kind: 'NOC_GRAM_PANCHAYAT', category: 'NOC', label: 'Gram Panchayat', importance: 'OPTIONAL', requiresDocumentNumber: true),

    /* Excavation Permission */
    DocumentDefinition(kind: 'LAND_MUTATION', category: 'PERMISSION', label: 'Land Mutation (Ferfar)', importance: 'OPTIONAL'),
    DocumentDefinition(kind: 'IOD_CERTIFICATE', category: 'PERMISSION', label: 'IOD Certificate', importance: 'OPTIONAL'),
    DocumentDefinition(kind: 'LOI', category: 'PERMISSION', label: 'Letter of Intent (LOI)', importance: 'OPTIONAL'),
    DocumentDefinition(kind: 'IOD_APPROVED_BUILDING_PLAN', category: 'PERMISSION', label: 'IOD Approved Building Plan', importance: 'OPTIONAL'),
    DocumentDefinition(kind: 'EARTH_WORK_MEASUREMENT', category: 'PERMISSION', label: 'Measurement of Earth Work', importance: 'OPTIONAL'),
    DocumentDefinition(kind: 'BORE_LOG', category: 'PERMISSION', label: 'Bore Log Report', importance: 'OPTIONAL'),
    DocumentDefinition(kind: 'DP_REMARKS', category: 'PERMISSION', label: 'DP Remarks', importance: 'OPTIONAL'),

    /* Other */
    DocumentDefinition(kind: 'OTHER', category: 'OTHER', label: 'Other Supporting Documents', importance: 'OPTIONAL'),
  ];

  static const List<String> mandatoryDocuments = [
    'PAN_CARD',
    'SEVEN_TWELVE',
    'OWNER_APPROVAL',
  ];

  static List<String> missingRequiredDocuments(List<String> attachedKinds) {
    return mandatoryDocuments.where((k) => !attachedKinds.contains(k)).toList();
  }

  static ApplicationFeeBreakdown calculateApplicationFeeBreakdown(double quantityBrass) {
    final qty = quantityBrass < 0 ? 0.0 : quantityBrass;
    double baseAmount = 500.0;
    String slabLabel = '1 – 500 Brass';

    if (qty > 2000) {
      baseAmount = 5000.0;
      slabLabel = '2,001+ Brass';
    } else if (qty > 500) {
      baseAmount = 2000.0;
      slabLabel = '501 – 2,000 Brass';
    } else {
      baseAmount = 500.0;
      slabLabel = '1 – 500 Brass';
    }

    return ApplicationFeeBreakdown(
      quantityBrass: qty,
      slabLabel: slabLabel,
      baseFee: Money(amount: baseAmount),
      stampDuty: const Money(amount: stampDutyAmount),
      totalFee: Money(amount: baseAmount + stampDutyAmount),
    );
  }

  static Money computeApplicationFee(double quantityBrass) {
    return calculateApplicationFeeBreakdown(quantityBrass).totalFee;
  }

  static DemandNoteChannelBreakdown computeDetailedDemandNoteBreakdown(Quantity quantity) {
    final qty = quantity.value > 0 ? quantity.value : 10.0;
    final royaltyAmount = (qty * 400.0).clamp(2200.0, 9999999.0).roundToDouble();
    final dmfAmount = (royaltyAmount * 0.10).roundToDouble();
    final siChargesAmount = (qty * 25.0).clamp(100.0, 9999999.0).roundToDouble();
    final siTaxAmount = (siChargesAmount * 0.18).roundToDouble();
    final tcsAmount = (royaltyAmount * 0.02).roundToDouble();

    final mahakhanijTotal = dmfAmount + siChargesAmount + siTaxAmount + tcsAmount;
    final grandTotal = royaltyAmount + mahakhanijTotal;

    return DemandNoteChannelBreakdown(
      grasAmount: Money(amount: royaltyAmount),
      dmf: Money(amount: dmfAmount),
      siCharges: Money(amount: siChargesAmount),
      siTax: Money(amount: siTaxAmount),
      tcs: Money(amount: tcsAmount),
      mahakhanijTotal: Money(amount: mahakhanijTotal),
      grandTotal: Money(amount: grandTotal),
    );
  }

  static bool awaitsApplicationFee(TemporaryExcavationApplication app) {
    return app.status == TemporaryExcavationStatus.draft;
  }

  static bool awaitsDemandNotePayment(TemporaryExcavationApplication app) {
    return app.status == TemporaryExcavationStatus.demandNoteIssued;
  }

  static bool awaitsPayment(TemporaryExcavationApplication app) {
    return awaitsApplicationFee(app) || awaitsDemandNotePayment(app);
  }

  static bool needsApplicantResponse(TemporaryExcavationApplication app) {
    return app.status == TemporaryExcavationStatus.queryRaised;
  }

  static bool hasExcavationOrder(TemporaryExcavationApplication app) {
    return app.status == TemporaryExcavationStatus.orderIssued;
  }

  static Map<String, String> validateApplicantStep({
    required String fullName,
    required String mobileNumber,
    required String panNumber,
    required String addressLine,
    required String district,
    required String pincode,
    String? email,
  }) {
    final errors = <String, String>{};
    if (fullName.trim().isEmpty) errors['fullName'] = 'Enter applicant full name.';
    final mobileClean = mobileNumber.replaceAll(RegExp(r'\D'), '');
    if (!RegExp(r'^[6-9]\d{9}$').hasMatch(mobileClean)) {
      errors['mobileNumber'] = 'Enter a valid 10-digit mobile number.';
    }
    if (email != null && email.trim().isNotEmpty) {
      if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email.trim())) {
        errors['email'] = 'Enter a valid email address.';
      }
    }
    final panClean = panNumber.trim().toUpperCase();
    if (!RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]{1}$').hasMatch(panClean)) {
      errors['panNumber'] = 'PAN looks like ABCDE1234F.';
    }
    if (addressLine.trim().isEmpty) errors['addressLine'] = 'Enter registered street address.';
    if (district.trim().isEmpty) errors['district'] = 'Enter registered district.';
    if (!RegExp(r'^[1-9]\d{5}$').hasMatch(pincode.trim())) {
      errors['pincode'] = 'Enter valid 6-digit PIN code.';
    }
    return errors;
  }

  static Map<String, String> validateExcavationStep({
    required String applicationType,
    required String mineralId,
    required double? quantityBrass,
    required int? liftingPeriodDays,
    required String reasonForApplying,
  }) {
    final errors = <String, String>{};
    if (applicationType.isEmpty) errors['applicationType'] = 'Select an application type.';
    if (mineralId.isEmpty) errors['mineralId'] = 'Select a mineral.';
    if (quantityBrass == null || quantityBrass <= 0) {
      errors['quantityBrass'] = 'Enter excavation quantity in Brass.';
    }
    if (liftingPeriodDays == null || liftingPeriodDays <= 0) {
      errors['liftingPeriodDays'] = 'Enter lifting period in days.';
    }
    if (reasonForApplying.trim().isEmpty) {
      errors['reasonForApplying'] = 'Enter reason for applying.';
    }
    return errors;
  }

  static Map<String, String> validateLocationStep({
    required String district,
    required String taluka,
    required String village,
    required String surveyNumber,
    required double? totalPlotAreaHectare,
  }) {
    final errors = <String, String>{};
    if (district.trim().isEmpty) errors['district'] = 'District is required.';
    if (taluka.trim().isEmpty) errors['taluka'] = 'Taluka is required.';
    if (village.trim().isEmpty) errors['village'] = 'Village is required.';
    if (surveyNumber.trim().isEmpty) errors['surveyNumber'] = 'Survey number is required.';
    if (totalPlotAreaHectare == null || totalPlotAreaHectare <= 0) {
      errors['totalPlotAreaHectare'] = 'Enter total plot area in Hectares.';
    }
    return errors;
  }
}
