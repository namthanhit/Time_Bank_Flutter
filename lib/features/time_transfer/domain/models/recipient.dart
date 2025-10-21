class Recipient {
  final String accountNumber;
  final String name;

  const Recipient({required this.accountNumber, required this.name});

  Map<String, dynamic> toJson() => {
    'accountNumber': accountNumber,
    'name': name,
  };

  factory Recipient.fromJson(Map<String, dynamic> json) => Recipient(
    accountNumber: json['accountNumber'] as String,
    name: json['name'] as String,
  );
}
