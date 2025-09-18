import 'certifier.dart';
import 'user.dart';

class CertifierWithUser {
  final Certifier certifier;
  final User? user;

  CertifierWithUser({
    required this.certifier,
    this.user,
  });

  factory CertifierWithUser.fromJson(Map<String, dynamic> json) {
    return CertifierWithUser(
      certifier: Certifier.fromJson(json),
      user: json['user'] != null ? User.fromJson(json['user']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    final data = certifier.toJson();
    if (user != null) {
      data['user'] = user!.toJson();
    }
    return data;
  }

  // Getters utili
  bool get hasUser => user != null;
  String get userName => user?.name ?? 'N/A';
  String get userEmail => user?.email ?? 'N/A';
  String get roleName => certifier.roleDisplayName;
  String get statusName => certifier.statusDisplayName;
  bool get isActive => certifier.active;
  bool get hasKyc => certifier.hasKyc;
  bool get isKycPassed => certifier.isKycPassed;
}
