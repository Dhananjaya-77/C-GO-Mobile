enum UserRole {
  driver,
  inspector,
  owner,
}

extension UserRoleExtension on UserRole {
  String get title {
    switch (this) {
      case UserRole.driver:
        return 'Truck Driver';
      case UserRole.inspector:
        return 'Customs Inspector';
      case UserRole.owner:
        return 'Cargo Owner';
    }
  }

  String get subtitle {
    switch (this) {
      case UserRole.driver:
        return 'Mobile Navigation & Corridor Compliance';
      case UserRole.inspector:
        return 'Checkpoint Inspection & Seal Management';
      case UserRole.owner:
        return 'Real-Time Consignment & Security Visibility';
    }
  }

  String get defaultName {
    switch (this) {
      case UserRole.driver:
        return 'Kasun Perera';
      case UserRole.inspector:
        return 'Insp. Kamal Wickramasinghe';
      case UserRole.owner:
        return 'Lanka Global Logistics & Exports';
    }
  }

  String get defaultId {
    switch (this) {
      case UserRole.driver:
        return 'DRV-WP-4821';
      case UserRole.inspector:
        return 'SL-CUS-0884';
      case UserRole.owner:
        return 'CGO-OWN-2026-99';
    }
  }
}
