// Simple in-memory authentication service with recent login tracking
class LoginRecord {
  final String email;
  final String roleName;
  final String userName;
  final DateTime loginTime;
  final String deviceInfo;

  const LoginRecord({
    required this.email,
    required this.roleName,
    required this.userName,
    required this.loginTime,
    this.deviceInfo = 'Mobile App • Sri Lanka (Active)',
  });

  String get timeAgo {
    final diff = DateTime.now().difference(loginTime);
    if (diff.inSeconds < 60) {
      return 'Just now';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else {
      return '${diff.inDays}d ago';
    }
  }

  String get formattedTime {
    final hourNum = loginTime.hour;
    final hour = hourNum > 12
        ? (hourNum - 12).toString().padLeft(2, '0')
        : (hourNum == 0 ? '12' : hourNum.toString().padLeft(2, '0'));
    final minute = loginTime.minute.toString().padLeft(2, '0');
    final period = hourNum >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period ($timeAgo)';
  }
}

class AuthService {
  // Singleton pattern
  AuthService._privateConstructor();
  static final AuthService instance = AuthService._privateConstructor();

  // Map of email to password (plain text for demo only)
  final Map<String, String> _users = {
    // Pre-registered users
    'dhananjaya1@gmail.com': '12345',
    'dhananjaya2@gmail.com': '12345',
    'dhananjaya3@gmail.com': '12345',
  };

  // Saved recent logins history
  final List<LoginRecord> _recentLogins = [
    LoginRecord(
      email: 'dhananjaya1@gmail.com',
      roleName: 'Truck Driver',
      userName: 'Kasun Perera',
      loginTime: DateTime.now().subtract(const Duration(minutes: 15)),
    ),
  ];

  /// Returns unmodifiable list of saved recent logins.
  List<LoginRecord> get recentLogins => List.unmodifiable(_recentLogins);

  /// Returns the most recent login record, if any.
  LoginRecord? get lastLogin =>
      _recentLogins.isNotEmpty ? _recentLogins.first : null;

  /// Saves a recent login detail.
  void recordLogin(String email) {
    final normalized = email.trim().toLowerCase();
    String roleName = 'Authorized User';
    String userName = 'User';

    if (normalized == 'dhananjaya1@gmail.com') {
      roleName = 'Truck Driver';
      userName = 'Kasun Perera';
    } else if (normalized == 'dhananjaya2@gmail.com') {
      roleName = 'Customs Inspector';
      userName = 'Insp. Kamal Wickramasinghe';
    } else if (normalized == 'dhananjaya3@gmail.com') {
      roleName = 'Container Owner';
      userName = 'David Silva';
    }

    _recentLogins.removeWhere(
        (item) => item.email.toLowerCase() == normalized);
    _recentLogins.insert(
      0,
      LoginRecord(
        email: normalized,
        roleName: roleName,
        userName: userName,
        loginTime: DateTime.now(),
      ),
    );

    // Keep up to 5 recent logins
    if (_recentLogins.length > 5) {
      _recentLogins.removeLast();
    }
  }

  /// Removes a specific email from recent logins.
  void removeRecentLogin(String email) {
    _recentLogins.removeWhere(
        (item) => item.email.toLowerCase() == email.trim().toLowerCase());
  }

  /// Clears all recent logins.
  void clearRecentLogins() {
    _recentLogins.clear();
  }

  /// Returns true if the email is an authorized user account.
  bool isAuthorizedEmail(String email) {
    return _users.containsKey(email.trim().toLowerCase());
  }

  /// Attempts to sign in with the given credentials.
  /// Saves the recent login if sign in succeeds and remember is true.
  bool signIn(String email, String password, {bool remember = true}) {
    final stored = _users[email.trim().toLowerCase()];
    final isValid = stored != null && stored == password;
    if (isValid && remember) {
      recordLogin(email);
    }
    return isValid;
  }

  /// Registers a new user. Returns true if registration succeeded,
  /// false if the email already exists.
  bool signUp(String email, String password) {
    final normalized = email.trim().toLowerCase();
    if (_users.containsKey(normalized)) {
      return false; // user already exists
    }
    _users[normalized] = password;
    return true;
  }
}
