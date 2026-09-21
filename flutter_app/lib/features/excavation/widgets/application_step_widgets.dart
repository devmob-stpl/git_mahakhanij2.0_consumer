import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../domain/temporary_excavation.dart';
import '../../../rules/excavation_rules.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_text_field.dart';

/* ---------------------------------------------------------------------------
 * STEP 1 · WHO IS APPLYING? (APPLICANT & IDENTITY DETAILS)
 * ------------------------------------------------------------------------ */

class ApplicantStepWidget extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController mobileController;
  final TextEditingController landlineController;
  final TextEditingController emailController;
  final TextEditingController districtController;
  final TextEditingController pincodeController;
  final TextEditingController addressController;
  final TextEditingController panController;
  final TextEditingController aadhaarController;
  final TextEditingController gstController;
  final Map<String, String> errors;
  final VoidCallback onChanged;

  const ApplicantStepWidget({
    super.key,
    required this.nameController,
    required this.mobileController,
    required this.landlineController,
    required this.emailController,
    required this.districtController,
    required this.pincodeController,
    required this.addressController,
    required this.panController,
    required this.aadhaarController,
    required this.gstController,
    required this.errors,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title & Subtitle
        const Text(
          'Who is applying?',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: AppColors.ink,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Pre-filled from your account. Correct anything that has changed.',
          style: TextStyle(
            fontSize: 13,
            color: AppColors.inkSecondary,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 20),

        // Applicant Name
        AppTextField(
          label: 'Applicant Name',
          isRequired: true,
          controller: nameController,
          onChanged: (_) => onChanged(),
        ),
        if (errors.containsKey('fullName'))
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(errors['fullName']!, style: const TextStyle(color: AppColors.danger600, fontSize: 12)),
          ),
        const SizedBox(height: 14),

        // Mobile No. & Landline No. (2-column layout)
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppTextField(
                    label: 'Applicant Mobile No.',
                    isRequired: true,
                    controller: mobileController,
                    keyboardType: TextInputType.phone,
                    onChanged: (_) => onChanged(),
                  ),
                  if (errors.containsKey('mobileNumber'))
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(errors['mobileNumber']!, style: const TextStyle(color: AppColors.danger600, fontSize: 12)),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AppTextField(
                label: 'Applicant Landline No.',
                hint: 'e.g. 020-2567890',
                controller: landlineController,
                keyboardType: TextInputType.phone,
                onChanged: (_) => onChanged(),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        // Email Id
        AppTextField(
          label: 'Applicant Email Id',
          isRequired: true,
          controller: emailController,
          keyboardType: TextInputType.emailAddress,
          onChanged: (_) => onChanged(),
        ),
        if (errors.containsKey('email'))
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(errors['email']!, style: const TextStyle(color: AppColors.danger600, fontSize: 12)),
          ),
        const SizedBox(height: 20),

        // APPLICANT REGISTERED ADDRESS Section Header
        const Divider(color: AppColors.line, height: 1),
        const SizedBox(height: 16),
        const Text(
          'APPLICANT REGISTERED ADDRESS',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.8,
            color: AppColors.inkMuted,
          ),
        ),
        const SizedBox(height: 12),

        // District & Pincode (2-column layout)
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppTextField(
                    label: 'District',
                    isRequired: true,
                    controller: districtController,
                    onChanged: (_) => onChanged(),
                  ),
                  if (errors.containsKey('district'))
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(errors['district']!, style: const TextStyle(color: AppColors.danger600, fontSize: 12)),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppTextField(
                    label: 'Applicant Pincode',
                    isRequired: true,
                    controller: pincodeController,
                    keyboardType: TextInputType.number,
                    onChanged: (_) => onChanged(),
                  ),
                  if (errors.containsKey('pincode'))
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(errors['pincode']!, style: const TextStyle(color: AppColors.danger600, fontSize: 12)),
                    ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        // Registered Street Address
        AppTextField(
          label: 'Registered Street Address',
          isRequired: true,
          controller: addressController,
          onChanged: (_) => onChanged(),
        ),
        if (errors.containsKey('addressLine'))
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(errors['addressLine']!, style: const TextStyle(color: AppColors.danger600, fontSize: 12)),
          ),
        const SizedBox(height: 20),

        // TAX & IDENTIFICATION NUMBERS Raised Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.neutral25,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.line),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'TAX & IDENTIFICATION NUMBERS',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                  color: AppColors.inkSecondary,
                ),
              ),
              const SizedBox(height: 12),

              // PAN Number
              AppTextField(
                label: 'PAN Number',
                isRequired: true,
                controller: panController,
                onChanged: (_) => onChanged(),
              ),
              if (errors.containsKey('panNumber'))
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(errors['panNumber']!, style: const TextStyle(color: AppColors.danger600, fontSize: 12)),
                ),
              const SizedBox(height: 14),

              // Aadhaar Number & GST Number (2-column layout)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: AppTextField(
                      label: 'Aadhaar Number',
                      hint: 'XXXX XXXX XXXX',
                      controller: aadhaarController,
                      keyboardType: TextInputType.number,
                      onChanged: (_) => onChanged(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppTextField(
                      label: 'GST Number',
                      controller: gstController,
                      onChanged: (_) => onChanged(),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/* ---------------------------------------------------------------------------
 * STEP 2 · WHAT WILL YOU EXTRACT? (PROPOSAL & EXCAVATION DETAILS)
 * ------------------------------------------------------------------------ */

class ExcavationStepWidget extends StatelessWidget {
  final String applicationType;
  final ValueChanged<String> onApplicationTypeChanged;
  final String proposalLevel;
  final ValueChanged<String> onProposalLevelChanged;
  final String mineralId;
  final ValueChanged<String> onMineralChanged;
  final TextEditingController quantityController;
  final TextEditingController liftingPeriodController;
  final TextEditingController reasonController;

  // Self consumption controllers & state
  final String projectType;
  final ValueChanged<String> onProjectTypeChanged;
  final TextEditingController departmentController;
  final TextEditingController officeController;
  final TextEditingController workOrderController;
  final TextEditingController projectCodeController;
  final TextEditingController projectNameController;
  final TextEditingController projectAddressController;
  final TextEditingController latController;
  final TextEditingController lngController;
  final String zeroRoyaltyScheme;
  final ValueChanged<String> onZeroRoyaltyChanged;

  final Map<String, String> errors;
  final VoidCallback onChanged;

  const ExcavationStepWidget({
    super.key,
    required this.applicationType,
    required this.onApplicationTypeChanged,
    required this.proposalLevel,
    required this.onProposalLevelChanged,
    required this.mineralId,
    required this.onMineralChanged,
    required this.quantityController,
    required this.liftingPeriodController,
    required this.reasonController,
    required this.projectType,
    required this.onProjectTypeChanged,
    required this.departmentController,
    required this.officeController,
    required this.workOrderController,
    required this.projectCodeController,
    required this.projectNameController,
    required this.projectAddressController,
    required this.latController,
    required this.lngController,
    required this.zeroRoyaltyScheme,
    required this.onZeroRoyaltyChanged,
    required this.errors,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title & Subtitle
        const Text(
          'What will you extract?',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: AppColors.ink,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Mineral, quantity, method and the period you need.',
          style: TextStyle(
            fontSize: 13,
            color: AppColors.inkSecondary,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 20),

        // Application Type Radio Cards
        Row(
          children: [
            const Text(
              'Application Type',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.ink),
            ),
            const Text(' *', style: TextStyle(color: AppColors.danger600, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: ExcavationRules.proposalApplicationTypes.map((type) {
            final isSelected = applicationType == type.value;
            return Expanded(
              child: GestureDetector(
                onTap: () {
                  onApplicationTypeChanged(type.value);
                  onChanged();
                },
                child: Container(
                  margin: EdgeInsets.only(
                    right: type.value == ExcavationRules.proposalApplicationTypes.first.value ? 6 : 0,
                    left: type.value == ExcavationRules.proposalApplicationTypes.last.value ? 6 : 0,
                  ),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFFEEF4FE) : AppColors.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSelected ? AppColors.primary500 : AppColors.line,
                      width: isSelected ? 1.5 : 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                            size: 18,
                            color: isSelected ? AppColors.primary500 : AppColors.inkMuted,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              type.label,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.ink,
                                height: 1.2,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        type.description ?? '',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.inkMuted,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        if (errors.containsKey('applicationType'))
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(errors['applicationType']!, style: const TextStyle(color: AppColors.danger600, fontSize: 12)),
          ),
        const SizedBox(height: 16),

        // Conditional Project Details (When Self Consumption is selected)
        if (applicationType == 'QUARRY_PROJECT_SELF_CONSUMPTION') ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFDFDF3),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFFCE8B2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Project Details',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF8C4B12)),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF9E7),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFFCE8B2)),
                      ),
                      child: const Text(
                        'Self Consumption',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFFB45309)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Project Type Radio (Government vs Private)
                const Text('Project Type:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.ink)),
                Row(
                  children: [
                    Radio<String>(
                      value: 'GOVERNMENT',
                      groupValue: projectType,
                      activeColor: AppColors.primary600,
                      onChanged: (val) {
                        if (val != null) onProjectTypeChanged(val);
                        onChanged();
                      },
                    ),
                    const Text('Government', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                    const SizedBox(width: 16),
                    Radio<String>(
                      value: 'PRIVATE',
                      groupValue: projectType,
                      activeColor: AppColors.primary600,
                      onChanged: (val) {
                        if (val != null) onProjectTypeChanged(val);
                        onChanged();
                      },
                    ),
                    const Text('Private', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                  ],
                ),

                if (projectType == 'GOVERNMENT') ...[
                  Row(
                    children: [
                      Expanded(
                        child: AppTextField(
                          label: 'Department Name',
                          isRequired: true,
                          controller: departmentController,
                          onChanged: (_) => onChanged(),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: AppTextField(
                          label: 'Office Name',
                          isRequired: true,
                          controller: officeController,
                          onChanged: (_) => onChanged(),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  AppTextField(
                    label: 'Work Order Number',
                    controller: workOrderController,
                    onChanged: (_) => onChanged(),
                  ),
                  const SizedBox(height: 12),
                ],

                Row(
                  children: [
                    Expanded(
                      child: AppTextField(
                        label: 'Project Code',
                        isRequired: true,
                        controller: projectCodeController,
                        onChanged: (_) => onChanged(),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AppTextField(
                        label: 'Project Name',
                        isRequired: true,
                        controller: projectNameController,
                        onChanged: (_) => onChanged(),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                AppTextField(
                  label: 'Project Address',
                  isRequired: true,
                  controller: projectAddressController,
                  onChanged: (_) => onChanged(),
                ),
                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: AppTextField(
                        label: 'Latitude',
                        isRequired: true,
                        controller: latController,
                        keyboardType: TextInputType.number,
                        onChanged: (_) => onChanged(),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AppTextField(
                        label: 'Longitude',
                        isRequired: true,
                        controller: lngController,
                        keyboardType: TextInputType.number,
                        onChanged: (_) => onChanged(),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                const Text('Zero Royalty Scheme', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                Row(
                  children: [
                    Radio<String>(
                      value: 'NO',
                      groupValue: zeroRoyaltyScheme,
                      activeColor: AppColors.primary600,
                      onChanged: (val) {
                        if (val != null) onZeroRoyaltyChanged(val);
                        onChanged();
                      },
                    ),
                    const Text('No', style: TextStyle(fontSize: 13)),
                    const SizedBox(width: 16),
                    Radio<String>(
                      value: 'YES',
                      groupValue: zeroRoyaltyScheme,
                      activeColor: AppColors.primary600,
                      onChanged: (val) {
                        if (val != null) onZeroRoyaltyChanged(val);
                        onChanged();
                      },
                    ),
                    const Text('Yes', style: TextStyle(fontSize: 13)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],

        // Lease Type & Proposal Level (2-column layout)
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text('Lease Type', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.ink)),
                      const Text(' *', style: TextStyle(color: AppColors.danger600, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Container(
                    width: double.infinity,
                    height: 48,
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: AppColors.neutral100,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.line),
                    ),
                    child: const Text(
                      'Temporary',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.ink),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text('Proposal Level', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.ink)),
                      const Text(' *', style: TextStyle(color: AppColors.danger600, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    value: proposalLevel,
                    isExpanded: true,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.line)),
                    ),
                    items: ExcavationRules.proposalLevels.map((lvl) {
                      return DropdownMenuItem(
                        value: lvl.value,
                        child: Text(lvl.label, style: const TextStyle(fontSize: 13), overflow: TextOverflow.ellipsis),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) onProposalLevelChanged(val);
                      onChanged();
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        // Mineral
        Row(
          children: [
            const Text('Mineral', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.ink)),
            const Text(' *', style: TextStyle(color: AppColors.danger600, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          value: mineralId,
          isExpanded: true,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.line)),
          ),
          items: const [
            DropdownMenuItem(value: 'min-3', child: Text('Stone Aggregate 20mm (Basalt)')),
            DropdownMenuItem(value: 'min-1', child: Text('Natural River Sand')),
            DropdownMenuItem(value: 'min-2', child: Text('Manufactured Sand (M-Sand)')),
            DropdownMenuItem(value: 'min-4', child: Text('Murrum / Soil Filling')),
          ],
          onChanged: (val) {
            if (val != null) onMineralChanged(val);
            onChanged();
          },
        ),
        const SizedBox(height: 14),

        // Excavation Quantity & Lifting Period (2-column layout)
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppTextField(
                    label: 'Excavation Quantity',
                    isRequired: true,
                    controller: quantityController,
                    keyboardType: TextInputType.number,
                    onChanged: (_) => onChanged(),
                  ),
                  if (errors.containsKey('quantityBrass'))
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(errors['quantityBrass']!, style: const TextStyle(color: AppColors.danger600, fontSize: 12)),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppTextField(
                    label: 'Lifting Period (Days)',
                    isRequired: true,
                    controller: liftingPeriodController,
                    keyboardType: TextInputType.number,
                    onChanged: (_) => onChanged(),
                  ),
                  if (errors.containsKey('liftingPeriodDays'))
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(errors['liftingPeriodDays']!, style: const TextStyle(color: AppColors.danger600, fontSize: 12)),
                    ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        // Reason For Applying
        AppTextField(
          label: 'Reason For Applying',
          isRequired: true,
          controller: reasonController,
          maxLines: 3,
          hint: 'Provide the purpose and justification for excavation...',
          onChanged: (_) => onChanged(),
        ),
        if (errors.containsKey('reasonForApplying'))
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(errors['reasonForApplying']!, style: const TextStyle(color: AppColors.danger600, fontSize: 12)),
          ),
      ],
    );
  }
}

/* ---------------------------------------------------------------------------
 * STEP 3 · WHERE IS THE QUARRY? (LOCATION & TREASURY OFFICES)
 * ------------------------------------------------------------------------ */

class LocationStepWidget extends StatelessWidget {
  final String category;
  final ValueChanged<String> onCategoryChanged;
  final TextEditingController plotLocationController;
  final TextEditingController districtController;
  final TextEditingController talukaController;
  final TextEditingController villageController;
  final TextEditingController surveyInputController;
  final List<SurveyEntry> surveyEntries;
  final VoidCallback onAddSurvey;
  final ValueChanged<String> onRemoveSurvey;
  final TextEditingController totalAreaController;
  final TextEditingController latController;
  final TextEditingController lngController;
  final VoidCallback onPinOnMap;
  final String demandNoteOffice;
  final ValueChanged<String> onDemandNoteOfficeChanged;
  final String grasOfficeName;
  final ValueChanged<String> onGrasOfficeChanged;
  final VoidCallback onApplySuggestion;
  final Map<String, String> errors;
  final VoidCallback onChanged;

  const LocationStepWidget({
    super.key,
    required this.category,
    required this.onCategoryChanged,
    required this.plotLocationController,
    required this.districtController,
    required this.talukaController,
    required this.villageController,
    required this.surveyInputController,
    required this.surveyEntries,
    required this.onAddSurvey,
    required this.onRemoveSurvey,
    required this.totalAreaController,
    required this.latController,
    required this.lngController,
    required this.onPinOnMap,
    required this.demandNoteOffice,
    required this.onDemandNoteOfficeChanged,
    required this.grasOfficeName,
    required this.onGrasOfficeChanged,
    required this.onApplySuggestion,
    required this.errors,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final currentPlotLoc = ExcavationRules.plotLocations.any((loc) => loc.value == plotLocationController.text)
        ? plotLocationController.text
        : ExcavationRules.plotLocations.first.value;

    final currentDistrict = ExcavationRules.districts.any((d) => d.value == districtController.text)
        ? districtController.text
        : ExcavationRules.districts.first.value;

    final currentTaluka = ExcavationRules.talukas.any((t) => t.value == talukaController.text)
        ? talukaController.text
        : ExcavationRules.talukas.first.value;

    final currentVillage = ExcavationRules.villages.any((v) => v.value == villageController.text)
        ? villageController.text
        : ExcavationRules.villages.first.value;

    final currentDemandOffice = ExcavationRules.demandNoteOffices.any((off) => off.value == demandNoteOffice)
        ? demandNoteOffice
        : ExcavationRules.demandNoteOffices.first.value;

    final currentGrasOffice = ExcavationRules.grasOffices.any((off) => off.value == grasOfficeName)
        ? grasOfficeName
        : ExcavationRules.grasOffices.first.value;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Title & Subtitle
        const Text(
          'Where is the quarry?',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: AppColors.ink,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Pick the village, give the survey number, and mark the site on the map.',
          style: TextStyle(
            fontSize: 13,
            color: AppColors.inkSecondary,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 20),

        // 2. Category Toggle (Rural vs Urban)
        Row(
          children: const [
            Text('Category', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.ink)),
            Text(' *', style: TextStyle(color: AppColors.danger600, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: ExcavationRules.locationCategories.map((cat) {
            final isSelected = category == cat.value;
            return Expanded(
              child: GestureDetector(
                onTap: () {
                  onCategoryChanged(cat.value);
                  onChanged();
                },
                child: Container(
                  height: 44,
                  margin: EdgeInsets.only(
                    right: cat.value == 'RURAL' ? 6 : 0,
                    left: cat.value == 'URBAN' ? 6 : 0,
                  ),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFFEEF4FE) : AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? AppColors.primary500 : AppColors.line,
                      width: isSelected ? 1.5 : 1,
                    ),
                  ),
                  child: Text(
                    cat.label,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected ? AppColors.primary700 : AppColors.inkSecondary,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 14),

        // 3. Plot Location Dropdown (Desktop Prototype Parity)
        Row(
          children: const [
            Text('Plot Location', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.ink)),
            Text(' *', style: TextStyle(color: AppColors.danger600, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          value: currentPlotLoc,
          isExpanded: true,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.line)),
          ),
          items: ExcavationRules.plotLocations.map((loc) {
            return DropdownMenuItem(
              value: loc.value,
              child: Text(loc.label, style: const TextStyle(fontSize: 13), overflow: TextOverflow.ellipsis),
            );
          }).toList(),
          onChanged: (val) {
            if (val != null) {
              plotLocationController.text = val;
              onChanged();
            }
          },
        ),
        const SizedBox(height: 14),

        // 4. District Dropdown
        Row(
          children: const [
            Text('District', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.ink)),
            Text(' *', style: TextStyle(color: AppColors.danger600, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          value: currentDistrict,
          isExpanded: true,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.line)),
          ),
          items: ExcavationRules.districts.map((d) {
            return DropdownMenuItem(
              value: d.value,
              child: Text(d.label, style: const TextStyle(fontSize: 13), overflow: TextOverflow.ellipsis),
            );
          }).toList(),
          onChanged: (val) {
            if (val != null) {
              districtController.text = val;
              onChanged();
            }
          },
        ),
        const SizedBox(height: 14),

        // 5. Taluka / CTSO & Village / City (2-column dropdown layout)
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Text('Taluka / CTSO', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.ink)),
                      Text(' *', style: TextStyle(color: AppColors.danger600, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    value: currentTaluka,
                    isExpanded: true,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.line)),
                    ),
                    items: ExcavationRules.talukas.map((t) {
                      return DropdownMenuItem(
                        value: t.value,
                        child: Text(t.label, style: const TextStyle(fontSize: 13), overflow: TextOverflow.ellipsis),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        talukaController.text = val;
                        onChanged();
                      }
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Text('Village / City', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.ink)),
                      Text(' *', style: TextStyle(color: AppColors.danger600, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    value: currentVillage,
                    isExpanded: true,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.line)),
                    ),
                    items: ExcavationRules.villages.map((v) {
                      return DropdownMenuItem(
                        value: v.value,
                        child: Text(v.label, style: const TextStyle(fontSize: 13), overflow: TextOverflow.ellipsis),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        villageController.text = val;
                        onChanged();
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // 6. ASSIGN SURVEY / CTS NUMBER Card
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.neutral25,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.line),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'ASSIGN SURVEY / CTS NUMBER *',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                  color: AppColors.inkSecondary,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: AppTextField(
                      label: 'Survey No. / CTS No.',
                      isRequired: true,
                      controller: surveyInputController,
                      onChanged: (_) => onChanged(),
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    height: 48,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary700,
                        side: const BorderSide(color: AppColors.primary500),
                        minimumSize: const Size(0, 48),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: onAddSurvey,
                      icon: const Icon(Icons.add, size: 16),
                      label: const Text('Add survey no.', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ),

              if (surveyEntries.isNotEmpty) ...[
                const SizedBox(height: 12),
                const Text('Assigned Survey Plots:', style: TextStyle(fontSize: 12, color: AppColors.inkMuted)),
                const SizedBox(height: 6),
                ...surveyEntries.asMap().entries.map((entry) {
                  final idx = entry.key;
                  final survey = entry.value;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.line),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '#${idx + 1}. Survey ${survey.surveyNumber}',
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.ink),
                            ),
                            const SizedBox(height: 2),
                            const Text(
                              '7/12 Record Verified',
                              style: TextStyle(fontSize: 11, color: AppColors.inkMuted),
                            ),
                          ],
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.inkMuted),
                          onPressed: () => onRemoveSurvey(survey.id),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ],
          ),
        ),
        const SizedBox(height: 14),

        // 7. Total Plot Area in Hectares
        AppTextField(
          label: 'Total Plot Area',
          isRequired: true,
          controller: totalAreaController,
          keyboardType: TextInputType.number,
          onChanged: (_) => onChanged(),
        ),
        const SizedBox(height: 16),

        // 8. PLOT GEO-COORDINATES Card
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.neutral25,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.line),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'PLOT GEO-COORDINATES *',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                      color: AppColors.inkSecondary,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: onPinOnMap,
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primary700,
                      backgroundColor: AppColors.surface,
                      side: const BorderSide(color: AppColors.line),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    ),
                    icon: const Icon(Icons.location_on_outlined, size: 14),
                    label: const Text('Pin on Map', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: AppTextField(
                      label: 'Plot Latitude',
                      isRequired: true,
                      controller: latController,
                      keyboardType: TextInputType.number,
                      onChanged: (_) => onChanged(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppTextField(
                      label: 'Plot Longitude',
                      isRequired: true,
                      controller: lngController,
                      keyboardType: TextInputType.number,
                      onChanged: (_) => onChanged(),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // 9. APPLICATION FEE DEMAND NOTE OFFICE Card
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.neutral25,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.line),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'APPLICATION FEE DEMAND NOTE OFFICE',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                  color: AppColors.inkSecondary,
                ),
              ),
              const SizedBox(height: 12),

              Row(
                children: const [
                  Text('Office For Demand Note', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                  Text(' *', style: TextStyle(color: AppColors.danger600, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                value: currentDemandOffice,
                isExpanded: true,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.line)),
                ),
                items: ExcavationRules.demandNoteOffices.map((off) {
                  return DropdownMenuItem(value: off.value, child: Text(off.label, style: const TextStyle(fontSize: 13), overflow: TextOverflow.ellipsis));
                }).toList(),
                onChanged: (val) {
                  if (val != null) onDemandNoteOfficeChanged(val);
                  onChanged();
                },
              ),
              const SizedBox(height: 12),

              Row(
                children: const [
                  Text('GRAS Office Name', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                  Text(' *', style: TextStyle(color: AppColors.danger600, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                value: currentGrasOffice,
                isExpanded: true,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.line)),
                ),
                items: ExcavationRules.grasOffices.map((off) {
                  return DropdownMenuItem(value: off.value, child: Text(off.label, style: const TextStyle(fontSize: 13), overflow: TextOverflow.ellipsis));
                }).toList(),
                onChanged: (val) {
                  if (val != null) onGrasOfficeChanged(val);
                  onChanged();
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // 10. Location Suggestion Banner
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFEEF4FE),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFBFD5FB)),
          ),
          child: Row(
            children: [
              const Icon(Icons.location_on, color: AppColors.primary700, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('Suggested from pinned location', style: TextStyle(fontSize: 11, color: AppColors.inkMuted)),
                    SizedBox(height: 2),
                    Text('Wagholi, Haveli, Pune', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.ink)),
                  ],
                ),
              ),
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary700,
                  side: const BorderSide(color: AppColors.primary500),
                  minimumSize: const Size(0, 36),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: onApplySuggestion,
                child: const Text('Apply Suggestion', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/* ---------------------------------------------------------------------------
 * STEP 4 · WHAT ARE YOU ATTACHING? (DOCUMENTS & CLEARANCES)
 * ------------------------------------------------------------------------ */

class DocumentsStepWidget extends StatefulWidget {
  final List<ApplicationDocument> attachedDocs;
  final Function(String kind, String fileName, String docType, String? docNum) onUploadDoc;
  final ValueChanged<String> onRemoveDoc;
  final Map<String, String> errors;

  const DocumentsStepWidget({
    super.key,
    required this.attachedDocs,
    required this.onUploadDoc,
    required this.onRemoveDoc,
    required this.errors,
  });

  @override
  State<DocumentsStepWidget> createState() => _DocumentsStepWidgetState();
}

class _DocumentsStepWidgetState extends State<DocumentsStepWidget> {
  String _activeCategory = 'IDENTITY_LAND';
  final Map<String, TextEditingController> _nocNumberControllers = {};

  final categories = const [
    {'id': 'IDENTITY_LAND', 'label': 'Identity & Land'},
    {'id': 'NOC', 'label': 'NOC Documents'},
    {'id': 'PERMISSION', 'label': 'Excavation Permission'},
    {'id': 'OTHER', 'label': 'Other Documents'},
  ];

  @override
  void dispose() {
    for (var c in _nocNumberControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  TextEditingController _getNocController(String kind) {
    if (!_nocNumberControllers.containsKey(kind)) {
      _nocNumberControllers[kind] = TextEditingController(text: 'NOC/2026/PWD/042');
    }
    return _nocNumberControllers[kind]!;
  }

  @override
  Widget build(BuildContext context) {
    final filteredDefs = ExcavationRules.documentDefinitions
        .where((d) => d.category == _activeCategory)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title & Subtitle
        const Text(
          'What are you attaching?',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: AppColors.ink,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'The department needs these before it can review the application.',
          style: TextStyle(
            fontSize: 13,
            color: AppColors.inkSecondary,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 16),

        // Info Callout Box
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFEEF4FE),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFBFD5FB)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 2),
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(
                  color: AppColors.primary700,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.info_outline, size: 14, color: Colors.white),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Mandatory Documents Required (*)',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.ink),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Documents marked with an asterisk (*) are mandatory to submit the application. Optional documents can be uploaded now or provided later during scrutiny.',
                      style: TextStyle(fontSize: 12, color: AppColors.inkSecondary, height: 1.4),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Count Text
        Text(
          '${widget.attachedDocs.length} document${widget.attachedDocs.length == 1 ? '' : 's'} attached',
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.ink),
        ),
        const SizedBox(height: 12),

        // Horizontal Category Tab Pills
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: categories.map((cat) {
              final isSelected = _activeCategory == cat['id'];
              final count = ExcavationRules.documentDefinitions.where((d) => d.category == cat['id']).length;
              final attachedCount = widget.attachedDocs.where((a) {
                final def = ExcavationRules.documentDefinitions.firstWhere((d) => d.kind == a.kind, orElse: () => ExcavationRules.documentDefinitions.last);
                return def.category == cat['id'];
              }).length;

              return Container(
                margin: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text('${cat['label']} ${attachedCount > 0 ? '$attachedCount/$count' : '$count'}'),
                  selected: isSelected,
                  selectedColor: AppColors.primary700,
                  backgroundColor: AppColors.surface,
                  labelStyle: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : AppColors.inkSecondary,
                  ),
                  side: BorderSide(color: isSelected ? AppColors.primary700 : AppColors.line),
                  onSelected: (selected) {
                    if (selected) {
                      setState(() => _activeCategory = cat['id']!);
                    }
                  },
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 16),

        // Document Cards List
        ...filteredDefs.map((doc) {
          final attached = widget.attachedDocs.cast<ApplicationDocument?>().firstWhere(
            (a) => a?.kind == doc.kind,
            orElse: () => null,
          );
          final isUploaded = attached != null;
          final isMandatory = doc.importance == 'MANDATORY';

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isUploaded ? const Color(0xFFF0FDF4) : AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isUploaded ? const Color(0xFF86EFAC) : AppColors.line,
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isUploaded ? const Color(0xFFDCFCE7) : AppColors.neutral100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        isUploaded ? Icons.check_circle : Icons.insert_drive_file_outlined,
                        size: 20,
                        color: isUploaded ? AppColors.success600 : AppColors.inkMuted,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                doc.label,
                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.ink),
                              ),
                              if (isMandatory)
                                const Text(' *', style: TextStyle(color: AppColors.danger600, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            isUploaded
                                ? attached.fileName
                                : isMandatory
                                    ? 'Mandatory document required to proceed'
                                    : 'Optional — can be furnished during scrutiny if required',
                            style: TextStyle(
                              fontSize: 12,
                              color: isUploaded ? AppColors.success700 : AppColors.inkMuted,
                              fontWeight: isUploaded ? FontWeight.w500 : FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isUploaded)
                      IconButton(
                        icon: const Icon(Icons.close, size: 18, color: AppColors.inkMuted),
                        onPressed: () => widget.onRemoveDoc(doc.kind),
                      )
                    else
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary700,
                          side: const BorderSide(color: AppColors.line),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: () {
                          final docNum = doc.requiresDocumentNumber ? _getNocController(doc.kind).text : null;
                          final ext = doc.kind == 'PAN_CARD' ? 'pdf' : 'jpg';
                          widget.onUploadDoc(doc.kind, '${doc.kind.toLowerCase()}.$ext', doc.label, docNum);
                        },
                        icon: const Icon(Icons.upload_outlined, size: 16),
                        label: const Text('Upload', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                      ),
                  ],
                ),

                // Inline Document/Sanction Order Number input for NOCs
                if (doc.requiresDocumentNumber && !isUploaded) ...[
                  const SizedBox(height: 12),
                  const Divider(color: AppColors.line, height: 1),
                  const SizedBox(height: 10),
                  AppTextField(
                    label: 'Document / Sanction Order Number (Optional)',
                    hint: 'e.g. NOC/2026/PWD/042',
                    controller: _getNocController(doc.kind),
                  ),
                ],
              ],
            ),
          );
        }),

        const SizedBox(height: 16),
        const Center(
          child: Text(
            'Accepted formats: PDF, JPG, PNG up to 10 MB per file.',
            style: TextStyle(fontSize: 12, color: AppColors.inkMuted),
          ),
        ),
      ],
    );
  }
}

/* ---------------------------------------------------------------------------
 * STEP 5 · REVIEW SUMMARY & STATUTORY DECLARATION
 * ------------------------------------------------------------------------ */

class ReviewStepWidget extends StatefulWidget {
  final TemporaryExcavationApplication application;
  final bool declarationAccepted;
  final ValueChanged<bool> onDeclarationChanged;
  final ValueChanged<int> onEditStep;

  const ReviewStepWidget({
    super.key,
    required this.application,
    required this.declarationAccepted,
    required this.onDeclarationChanged,
    required this.onEditStep,
  });

  @override
  State<ReviewStepWidget> createState() => _ReviewStepWidgetState();
}

class _ReviewStepWidgetState extends State<ReviewStepWidget> {
  bool _showFeeBreakdown = false;

  @override
  Widget build(BuildContext context) {
    final app = widget.application;
    final breakdown = ExcavationRules.calculateApplicationFeeBreakdown(app.estimatedQuantity.value);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title & Subtitle
        const Text(
          'Review & Statutory Declaration',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: AppColors.ink,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Please review all details carefully before submitting your application.',
          style: TextStyle(
            fontSize: 13,
            color: AppColors.inkSecondary,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 20),

        // Applicant Summary Card
        _buildSummaryCard(
          title: 'Applicant & Identity Details',
          stepIndex: 0,
          items: [
            _SummaryRow('Applicant Name', app.applicant.fullName),
            _SummaryRow('Mobile No.', app.applicant.mobileNumber),
            if (app.applicant.landlineNumber != null) _SummaryRow('Landline No.', app.applicant.landlineNumber!),
            _SummaryRow('Email Id', app.applicant.email ?? '—'),
            _SummaryRow('Registered District', app.applicant.registeredAddress.district),
            _SummaryRow('PIN Code', app.applicant.registeredAddress.pincode),
            _SummaryRow('Registered Address', app.applicant.registeredAddress.line1),
            _SummaryRow('PAN Number', app.applicant.panNumber),
            if (app.applicant.aadhaarNumber != null) _SummaryRow('Aadhaar Number', app.applicant.aadhaarNumber!),
            if (app.applicant.gstNumber != null) _SummaryRow('GST Number', app.applicant.gstNumber!),
          ],
        ),
        const SizedBox(height: 14),

        // Excavation Details Card
        _buildSummaryCard(
          title: 'Proposal & Excavation Details',
          stepIndex: 1,
          items: [
            _SummaryRow('Application Type', app.applicationType == 'QUARRY_PROJECT_SELF_CONSUMPTION' ? 'Quarry For Project - Self Consumption' : 'Quarry – Temporary Plot Proposal'),
            _SummaryRow('Lease Type', 'Temporary'),
            _SummaryRow('Proposal Level', app.proposalLevel),
            _SummaryRow('Mineral', app.mineralName.isNotEmpty ? app.mineralName : 'Stone Aggregate 20mm'),
            _SummaryRow('Excavation Quantity', '${app.estimatedQuantity.value.toInt()} Brass'),
            _SummaryRow('Lifting Period', '${app.liftingPeriodDays} Days'),
            _SummaryRow('Reason For Applying', app.purpose),
          ],
        ),
        const SizedBox(height: 14),

        // Quarry Location Card
        _buildSummaryCard(
          title: 'Quarry Location & Treasury Offices',
          stepIndex: 2,
          items: [
            _SummaryRow('Category', app.category),
            _SummaryRow('Plot Location', app.plotLocationType),
            _SummaryRow('District', app.siteAddress.district),
            _SummaryRow('Taluka / CTSO', app.siteAddress.taluka),
            _SummaryRow('Village / City', app.village),
            _SummaryRow('Survey / CTS No.', app.surveyNumber),
            _SummaryRow('Total Plot Area', '${app.totalPlotAreaHectare} Hectare'),
            _SummaryRow('Geo-Coordinates', '${app.siteGeo.latitude.toStringAsFixed(5)}, ${app.siteGeo.longitude.toStringAsFixed(5)}'),
            _SummaryRow('Demand Note Office', app.demandNoteOffice),
            _SummaryRow('GRAS Office', app.grasOfficeName),
          ],
        ),
        const SizedBox(height: 14),

        // Uploaded Documents Card
        _buildSummaryCard(
          title: 'Uploaded Documents',
          stepIndex: 3,
          items: app.documents.isEmpty
              ? [_SummaryRow('Documents', 'No documents attached yet')]
              : app.documents.map((d) => _SummaryRow(d.documentType.isNotEmpty ? d.documentType : d.kind, d.fileName)).toList(),
        ),
        const SizedBox(height: 20),

        // Application Fee Summary Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.line),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: const [
                  Icon(Icons.receipt_long, color: AppColors.primary700, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Application Fee Summary',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.ink),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(color: AppColors.line, height: 1),
              const SizedBox(height: 12),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Total Fee Payable', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.ink)),
                      Text(
                        'Volume Slab (${breakdown.slabLabel})',
                        style: const TextStyle(fontSize: 12, color: AppColors.inkMuted),
                      ),
                    ],
                  ),
                  Text(
                    breakdown.totalFee.formatted,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Fee Breakdown Toggle
              InkWell(
                onTap: () => setState(() => _showFeeBreakdown = !_showFeeBreakdown),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.neutral100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _showFeeBreakdown ? 'Hide Fee Breakdown' : 'View Fee Breakdown',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary700),
                      ),
                      Icon(
                        _showFeeBreakdown ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                        size: 18,
                        color: AppColors.primary700,
                      ),
                    ],
                  ),
                ),
              ),

              if (_showFeeBreakdown) ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.neutral25,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.line),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Application Fee', style: TextStyle(fontSize: 12, color: AppColors.inkSecondary)),
                          Text(breakdown.baseFee.formatted, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Statutory Stamp Duty', style: TextStyle(fontSize: 12, color: AppColors.inkSecondary)),
                          Text(breakdown.stampDuty.formatted, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Checkbox Statutory Declaration
        CheckboxListTile(
          value: widget.declarationAccepted,
          onChanged: (val) => widget.onDeclarationChanged(val ?? false),
          activeColor: AppColors.primary700,
          contentPadding: EdgeInsets.zero,
          controlAffinity: ListTileControlAffinity.leading,
          title: const Text(
            'I solemnly declare that all particulars entered above are true, and the excavation will be executed strictly within permitted boundaries in compliance with the Maharashtra Minor Mineral Extraction Rules.',
            style: TextStyle(fontSize: 12, height: 1.4, color: AppColors.inkSecondary),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required int stepIndex,
    required List<_SummaryRow> items,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: const BoxDecoration(
              color: AppColors.neutral25,
              borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
              border: Border(bottom: BorderSide(color: AppColors.line)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.ink),
                ),
                TextButton.icon(
                  onPressed: () => widget.onEditStep(stepIndex),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primary700,
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(0, 0),
                  ),
                  icon: const Icon(Icons.edit_outlined, size: 14),
                  label: const Text('Edit', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              children: items.map((item) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(item.label, style: const TextStyle(fontSize: 12, color: AppColors.inkMuted)),
                      Flexible(
                        child: Text(
                          item.value,
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.ink),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryRow {
  final String label;
  final String value;
  const _SummaryRow(this.label, this.value);
}
