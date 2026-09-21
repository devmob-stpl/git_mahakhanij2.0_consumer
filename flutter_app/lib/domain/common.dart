/// Common Value Objects across the Mahakhanij domain
class GeoPoint {
  final double latitude;
  final double longitude;

  const GeoPoint({
    required this.latitude,
    required this.longitude,
  });

  factory GeoPoint.fromJson(Map<String, dynamic> json) {
    return GeoPoint(
      latitude: (json['latitude'] as num?)?.toDouble() ?? (json['lat'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? (json['lng'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() => {
    'latitude': latitude,
    'longitude': longitude,
  };
}

class Address {
  final String line1;
  final String? line2;
  final String village;
  final String taluka;
  final String district;
  final String pincode;
  final String state;
  final String? city;
  final GeoPoint? geo;

  const Address({
    required this.line1,
    this.line2,
    this.village = '',
    required this.taluka,
    required this.district,
    required this.pincode,
    this.state = 'Maharashtra',
    this.city,
    this.geo,
  });

  String get formattedAddress {
    final parts = [line1, if (line2 != null && line2!.isNotEmpty) line2, village, taluka, district, pincode, state];
    return parts.where((p) => p != null && p.toString().isNotEmpty).join(', ');
  }

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      line1: json['line1'] ?? '',
      line2: json['line2'],
      village: json['village'] ?? '',
      taluka: json['taluka'] ?? '',
      district: json['district'] ?? '',
      pincode: json['pincode'] ?? '',
      state: json['state'] ?? 'Maharashtra',
    );
  }

  Map<String, dynamic> toJson() => {
    'line1': line1,
    if (line2 != null) 'line2': line2,
    'village': village,
    'taluka': taluka,
    'district': district,
    'pincode': pincode,
    'state': state,
  };
}

class Money {
  final double amount;
  final String currency;

  const Money({
    required this.amount,
    this.currency = 'INR',
  });

  String get formatted {
    return '₹${amount.toStringAsFixed(2)}';
  }

  factory Money.fromJson(dynamic json) {
    if (json is num) {
      return Money(amount: json.toDouble());
    }
    if (json is Map<String, dynamic>) {
      return Money(
        amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
        currency: json['currency'] ?? 'INR',
      );
    }
    return const Money(amount: 0.0);
  }

  Map<String, dynamic> toJson() => {
    'amount': amount,
    'currency': currency,
  };
}

class Quantity {
  final double value;
  final String unit; // 'BRASS' | 'METRIC_TONNE' | 'CUBIC_METER'

  const Quantity({
    required this.value,
    this.unit = 'BRASS',
  });

  String get formatted {
    return '${value.toStringAsFixed(1)} $unit';
  }

  factory Quantity.fromJson(dynamic json) {
    if (json is num) {
      return Quantity(value: json.toDouble());
    }
    if (json is Map<String, dynamic>) {
      return Quantity(
        value: (json['value'] as num?)?.toDouble() ?? 0.0,
        unit: json['unit'] ?? 'BRASS',
      );
    }
    return const Quantity(value: 0.0);
  }

  Map<String, dynamic> toJson() => {
    'value': value,
    'unit': unit,
  };
}
