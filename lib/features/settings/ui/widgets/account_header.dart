import 'package:flutter/material.dart';
import '../../../auth/domain/user_profile.dart';

class AccountHeader extends StatelessWidget {
  final UserProfile user;
  const AccountHeader({Key? key, required this.user}) : super(key: key);

  Widget _buildAvatar() {
    final url = user.avatarUrl;
    if (url != null && url.isNotEmpty && (url.startsWith('http://') || url.startsWith('https://'))) {
      return CircleAvatar(
        radius: 48,
        backgroundImage: NetworkImage(url),
      );
    } else {
      return CircleAvatar(
        radius: 48,
        backgroundColor: Colors.grey[300],
        child: Icon(
          Icons.person_outline,
          size: 60,
          color: Colors.grey[600],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(6)),
      ),
      child: Column(
        children: [
          Text('Tài Khoản', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)]),
            child: _buildAvatar(),
          ),
          const SizedBox(height: 12),
          Text(user.fullName, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Text(user.email, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[600])),
          const SizedBox(height: 18),
          Container(height: 8, color: Colors.grey[100]),
        ],
      ),
    );
  }
}