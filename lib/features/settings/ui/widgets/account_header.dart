import 'package:flutter/material.dart';
import '../../domain/user.dart';

class AccountHeader extends StatelessWidget {
  final UserProfile user;
  const AccountHeader({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(6)),
      ),
      child: Column(
        children: [
          Text('Tài Khoản', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
          SizedBox(height: 16),
          Container(
            padding: EdgeInsets.all(6),
            decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)]),
            child: CircleAvatar(
              radius: 48,
              backgroundImage: AssetImage(user.avatarUrl),
            ),
          ),
          SizedBox(height: 12),
          Text(user.name, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
          SizedBox(height: 6),
          Text(user.email, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[600])),
          SizedBox(height: 18),
          // subtle divider to visually join header and list
          Container(height: 8, color: Colors.grey[100]),
        ],
      ),
    );
  }
}
