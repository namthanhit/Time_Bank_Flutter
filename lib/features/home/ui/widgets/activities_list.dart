import 'package:flutter/material.dart';
import '../../domain/models/home_models.dart';
import 'activity_card.dart';

class ActivitiesList extends StatelessWidget {
  const ActivitiesList({super.key, required this.items});
  final List<Activity> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            children: const [
              Text('Hoạt Động', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              Spacer(),
              Padding(
                padding: EdgeInsets.all(6.0),
                child: Icon(Icons.menu_rounded, size: 22, color: Colors.black87),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        for (final a in items)
          ActivityCard(
            activity: a,
          ),
      ],
    );
  }
}
