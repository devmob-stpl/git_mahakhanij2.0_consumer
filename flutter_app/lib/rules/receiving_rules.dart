import '../domain/delivery.dart';
import '../domain/order.dart';

enum VerificationCheck {
  transactionFound('TRANSACTION_FOUND'),
  permitValid('PERMIT_VALID'),
  vehicleMatched('VEHICLE_MATCHED'),
  destinationMatched('DESTINATION_MATCHED');

  final String value;
  const VerificationCheck(this.value);
}

class CheckResult {
  final VerificationCheck check;
  final String label;
  final bool passed;
  final String detail;

  const CheckResult({
    required this.check,
    required this.label,
    required this.passed,
    required this.detail,
  });
}

class ReceiptVerification {
  final bool qrScanned;
  final bool permitValid;
  final bool vehicleMatched;
  final bool destinationMatched;

  const ReceiptVerification({
    required this.qrScanned,
    required this.permitValid,
    required this.vehicleMatched,
    required this.destinationMatched,
  });

  factory ReceiptVerification.fromJson(Map<String, dynamic> json) {
    return ReceiptVerification(
      qrScanned: json['qrScanned'] ?? false,
      permitValid: json['permitValid'] ?? false,
      vehicleMatched: json['vehicleMatched'] ?? false,
      destinationMatched: json['destinationMatched'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'qrScanned': qrScanned,
    'permitValid': permitValid,
    'vehicleMatched': vehicleMatched,
    'destinationMatched': destinationMatched,
  };
}

class VerificationOutcome {
  final List<CheckResult> results;
  final ReceiptVerification verification;
  final bool valid;

  const VerificationOutcome({
    required this.results,
    required this.verification,
    required this.valid,
  });
}

/// Verifies a scanned permit against the delivery in front of the receiver.
VerificationOutcome verifyTransport(
  Delivery delivery,
  String scannedPayload, {
  DateTime? now,
}) {
  now ??= DateTime.now();
  final permit = delivery.transportPermit;

  final transactionFound = scannedPayload.trim() == permit.qrPayload.trim() ||
      scannedPayload.trim().toUpperCase() == permit.etpNumber.trim().toUpperCase();

  DateTime? validUntilDate;
  try {
    validUntilDate = DateTime.parse(permit.validUntil);
  } catch (_) {
    validUntilDate = now.add(const Duration(hours: 12));
  }

  final permitValid = validUntilDate.isAfter(now) || validUntilDate.isAtSameMomentAs(now);
  final vehicleMatched = permit.vehicleNumber.trim().toUpperCase() ==
      delivery.vehicle.registrationNumber.trim().toUpperCase();
  final destinationMatched = permit.destinationLabel.trim() ==
      delivery.transportPermit.destinationLabel.trim();

  final results = [
    CheckResult(
      check: VerificationCheck.transactionFound,
      label: 'Transport permit',
      passed: transactionFound,
      detail: transactionFound
          ? permit.etpNumber
          : 'This code does not match any permit for this delivery.',
    ),
    CheckResult(
      check: VerificationCheck.permitValid,
      label: 'Permit validity',
      passed: permitValid,
      detail: permitValid
          ? 'Valid until ${_formatDateTime(validUntilDate)}'
          : 'Expired on ${_formatDateTime(validUntilDate)}',
    ),
    CheckResult(
      check: VerificationCheck.vehicleMatched,
      label: 'Vehicle',
      passed: vehicleMatched,
      detail: vehicleMatched
          ? delivery.vehicle.registrationNumber
          : 'Permit names ${permit.vehicleNumber}, vehicle is ${delivery.vehicle.registrationNumber}',
    ),
    CheckResult(
      check: VerificationCheck.destinationMatched,
      label: 'Destination',
      passed: destinationMatched,
      detail: destinationMatched
          ? permit.destinationLabel
          : 'Permit names ${permit.destinationLabel}',
    ),
  ];

  return VerificationOutcome(
    results: results,
    verification: ReceiptVerification(
      qrScanned: true,
      permitValid: permitValid,
      vehicleMatched: vehicleMatched,
      destinationMatched: destinationMatched,
    ),
    valid: results.every((r) => r.passed),
  );
}

/// Resolves a scanned or typed value to a permit payload.
String permitPayloadFor(String input, Delivery delivery) {
  final trimmed = input.trim();
  final upper = trimmed.toUpperCase();

  if (upper == delivery.transportPermit.etpNumber.toUpperCase()) {
    return delivery.transportPermit.qrPayload;
  }

  final otp = trimmed.replaceAll(RegExp(r'\s+'), '');
  final digitsOnly = delivery.transportPermit.etpNumber.replaceAll(RegExp(r'\D'), '');
  final otpCandidate = digitsOnly.length >= 6 ? digitsOnly.substring(digitsOnly.length - 6) : digitsOnly;

  if (RegExp(r'^\d{6}$').hasMatch(otp) && otp == otpCandidate) {
    return delivery.transportPermit.qrPayload;
  }

  return trimmed;
}

/// Recomputes an order's receiving status from its deliveries.
OrderStatus deriveReceivingStatus(Order order, List<Delivery> deliveries) {
  final receipts = deliveries.where((d) => d.status == DeliveryStatus.received || d.status == DeliveryStatus.receivedWithDiscrepancy).toList();

  if (receipts.isEmpty) {
    final hasArrived = deliveries.any((d) => d.status == DeliveryStatus.arrivedAtDestination);
    return hasArrived ? OrderStatus.partiallyDelivered : OrderStatus.processing;
  }

  final anyDiscrepancy = receipts.any((d) => d.status == DeliveryStatus.receivedWithDiscrepancy);
  final totalReceived = receipts.fold<double>(
    0.0,
    (sum, d) => sum + (d.discrepancyReport?.actualReceivedQuantity.value ?? d.transportPermit.permittedQuantity.value),
  );

  if (totalReceived >= order.orderedQuantity.value) {
    return anyDiscrepancy ? OrderStatus.partiallyDelivered : OrderStatus.completed;
  }

  return OrderStatus.partiallyDelivered;
}

String _formatDateTime(DateTime dt) {
  final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
  final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
  final period = dt.hour >= 12 ? 'PM' : 'AM';
  final minute = dt.minute.toString().padLeft(2, '0');
  return '${dt.day} ${months[dt.month - 1]}, $hour:$minute $period';
}
