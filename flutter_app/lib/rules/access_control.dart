import '../domain/user.dart';

enum Capability {
  viewProjects,
  viewPackages,
  useOrganizationContext,
  temporaryExcavation,
  viewMineralTab,
  viewOrganization,
  scanQrReceiving,
  recordConsumption,
}

class AccessControl {
  AccessControl._();

  static const Map<UserType, Set<Capability>> _capabilitiesByType = {
    UserType.organization: {
      Capability.viewProjects,
      Capability.viewPackages,
      Capability.useOrganizationContext,
      Capability.temporaryExcavation,
      Capability.viewOrganization,
      Capability.scanQrReceiving,
      Capability.recordConsumption,
    },
    UserType.supervisor: {
      Capability.scanQrReceiving,
      Capability.recordConsumption,
      Capability.viewPackages,
    },
    UserType.normalConsumer: {
      Capability.viewMineralTab,
    },
  };

  static bool hasCapability(UserType userType, Capability capability) {
    return _capabilitiesByType[userType]?.contains(capability) ?? false;
  }

  static bool userCan(User? user, Capability capability) {
    if (user == null) return false;
    return hasCapability(user.userType, capability);
  }
}
