import 'package:equatable/equatable.dart';

class CertificateTemplate extends Equatable {
  final String id;
  final String providerId;
  final String? courseId;
  final String name;
  final bool isDefault;
  final bool isAutoIssueEnabled;
  final String type;
  final TemplateData templateData;
  final DateTime createdAt;
  final DateTime updatedAt;

  const CertificateTemplate({
    required this.id,
    required this.providerId,
    this.courseId,
    required this.name,
    this.isDefault = false,
    this.isAutoIssueEnabled = false,
    this.type = 'classic',
    required this.templateData,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        providerId,
        courseId,
        name,
        isDefault,
        isAutoIssueEnabled,
        type,
        templateData,
        createdAt,
        updatedAt,
      ];

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'provider_id': providerId,
      'course_id': courseId,
      'name': name,
      'is_default': isDefault,
      'is_auto_issue_enabled': isAutoIssueEnabled,
      'type': type,
      'template_data': templateData.toJson(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory CertificateTemplate.fromJson(Map<String, dynamic> json) {
    return CertificateTemplate(
      id: json['id'] ?? '',
      providerId: json['provider_id'] ?? '',
      courseId: json['course_id'],
      name: json['name'] ?? '',
      isDefault: json['is_default'] ?? false,
      isAutoIssueEnabled: json['is_auto_issue_enabled'] ?? false,
      type: json['type'] ?? 'classic',
      templateData: TemplateData.fromJson(json['template_data'] ?? {}),
      createdAt: DateTime.parse(
          json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(
          json['updated_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  CertificateTemplate copyWith({
    String? id,
    String? providerId,
    String? courseId,
    String? name,
    bool? isDefault,
    bool? isAutoIssueEnabled,
    String? type,
    TemplateData? templateData,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CertificateTemplate(
      id: id ?? this.id,
      providerId: providerId ?? this.providerId,
      courseId: courseId ?? this.courseId,
      name: name ?? this.name,
      isDefault: isDefault ?? this.isDefault,
      isAutoIssueEnabled: isAutoIssueEnabled ?? this.isAutoIssueEnabled,
      type: type ?? this.type,
      templateData: templateData ?? this.templateData,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class TemplateData extends Equatable {
  final String primaryColor;
  final String secondaryColor;
  final String? logoUrl;
  final String? signatureUrl;
  final String headerText;
  final String bodyText;
  final String footerText;
  final String layout;
  final Map<String, dynamic>? customFields;

  const TemplateData({
    this.primaryColor = '#1E3A8A',
    this.secondaryColor = '#FCD34D',
    this.logoUrl,
    this.signatureUrl,
    this.headerText = 'شهادة إتمام',
    this.bodyText =
        'نشهد بأن {{student_name}} قد أكمل بنجاح الدورة التدريبية {{course_name}}',
    this.footerText = 'تاريخ الإصدار: {{completion_date}}',
    this.layout = 'classic',
    this.customFields,
  });

  @override
  List<Object?> get props => [
        primaryColor,
        secondaryColor,
        logoUrl,
        signatureUrl,
        headerText,
        bodyText,
        footerText,
        layout,
        customFields,
      ];

  Map<String, dynamic> toJson() {
    return {
      'primary_color': primaryColor,
      'secondary_color': secondaryColor,
      'logo_url': logoUrl,
      'signature_url': signatureUrl,
      'header_text': headerText,
      'body_text': bodyText,
      'footer_text': footerText,
      'layout': layout,
      'custom_fields': customFields,
    };
  }

  factory TemplateData.fromJson(Map<String, dynamic> json) {
    return TemplateData(
      primaryColor: json['primary_color'] ?? '#1E3A8A',
      secondaryColor: json['secondary_color'] ?? '#FCD34D',
      logoUrl: json['logo_url'],
      signatureUrl: json['signature_url'],
      headerText: json['header_text'] ?? 'شهادة إتمام',
      bodyText: json['body_text'] ??
          'نشهد بأن {{student_name}} قد أكمل بنجاح الدورة التدريبية {{course_name}}',
      footerText: json['footer_text'] ?? 'تاريخ الإصدار: {{completion_date}}',
      layout: json['layout'] ?? 'classic',
      customFields: json['custom_fields'],
    );
  }

  TemplateData copyWith({
    String? primaryColor,
    String? secondaryColor,
    String? logoUrl,
    String? signatureUrl,
    String? headerText,
    String? bodyText,
    String? footerText,
    String? layout,
    Map<String, dynamic>? customFields,
  }) {
    return TemplateData(
      primaryColor: primaryColor ?? this.primaryColor,
      secondaryColor: secondaryColor ?? this.secondaryColor,
      logoUrl: logoUrl ?? this.logoUrl,
      signatureUrl: signatureUrl ?? this.signatureUrl,
      headerText: headerText ?? this.headerText,
      bodyText: bodyText ?? this.bodyText,
      footerText: footerText ?? this.footerText,
      layout: layout ?? this.layout,
      customFields: customFields ?? this.customFields,
    );
  }

  String replaceVariables(String text, Map<String, String> variables) {
    String result = text;
    variables.forEach((key, value) {
      result = result.replaceAll('{{$key}}', value);
    });
    return result;
  }
}
