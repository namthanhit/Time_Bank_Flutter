class RecipientInfo {
  final String id;
  final String fullName;

  RecipientInfo({required this.id, required this.fullName});

  factory RecipientInfo.fromJson(Map<String, dynamic> json) {
    return RecipientInfo(
      id: json['id'],
      fullName: json['full_name'],
    );
  }
}