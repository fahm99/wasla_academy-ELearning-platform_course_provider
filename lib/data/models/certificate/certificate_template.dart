import 'certificate_settings.dart';

class CertificateTemplate {
  final String id;
  final String name;
  final String type;
  final String thumbnailPath;
  final bool isAutoIssueEnabled;
  final CertificateSettings settings;

  CertificateTemplate({
    required this.id,
    required this.name,
    required this.type,
    required this.thumbnailPath,
    this.isAutoIssueEnabled = false,
    required this.settings,
  });
}
