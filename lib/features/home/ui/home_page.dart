import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'sections/hero_section_container.dart';
import 'sections/activities_section_container.dart';
import 'widgets/shadow_separator.dart';
import 'widgets/quick_actions.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const HeroSectionContainer(), // lo fetch + error/loading
          Transform.translate(
            offset: const Offset(0, -26),
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(topLeft: Radius.circular(18), topRight: Radius.circular(18)),
                boxShadow: [BoxShadow(color: Color(0x14000000), blurRadius: 12, offset: Offset(0, -2))],
              ),
              child: const Column(
                children: [
                  SizedBox(height: 18),
                  QuickActions(),
                  ShadowSeparator(),
                  ActivitiesSectionContainer(), // lo fetch + error/loading
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
