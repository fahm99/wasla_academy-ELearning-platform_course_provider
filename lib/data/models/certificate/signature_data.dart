class SignatureData {
  final String name;
  final String title;

  const SignatureData({
    required this.name,
    required this.title,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'title': title,
    };
  }

  factory SignatureData.fromJson(Map<String, dynamic> json) {
    return SignatureData(
      name: json['name'] ?? '',
      title: json['title'] ?? '',
    );
  }

  SignatureData copyWith({
    String? name,
    String? title,
  }) {
    return SignatureData(
      name: name ?? this.name,
      title: title ?? this.title,
    );
  }
}
