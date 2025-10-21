class Thread {
  final String id;
  final String name;
  final String subtitle;
  final bool online;
  final String avatar;

  const Thread({required this.id, required this.name, required this.subtitle, this.online = false, required this.avatar});

  factory Thread.fromJson(Map<String, dynamic> j) => Thread(
        id: j['id'] as String,
        name: j['name'] as String,
        subtitle: j['subtitle'] as String,
        online: j['online'] as bool? ?? false,
        avatar: j['avatar'] as String,
      );
}
