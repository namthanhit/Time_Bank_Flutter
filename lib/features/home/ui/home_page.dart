import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:time_bank_flutter/features/time_transfer/ui/transfer_page.dart';
import 'sections/hero_section_container.dart';
import 'sections/activities_section_container.dart';
import 'widgets/shadow_separator.dart';
import 'widgets/quick_actions.dart';
import 'widgets/promo_banners.dart';
import 'package:time_bank_flutter/features/qr/ui/qr_scanner_page.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    void _openQrScanner(BuildContext context) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (pageContext) => QrScannerPage(
            onScanSuccess: (scannedPhone) {
              Navigator.of(pageContext).pushReplacement(
                MaterialPageRoute(
                  builder: (_) => TransferPage(
                    prefilledPhoneNumber: scannedPhone,
                  ),
                ),
              );
            },
          ),
        ),
      );
    }

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
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(18),
                    topRight: Radius.circular(18)),
                boxShadow: [
                  BoxShadow(
                      color: Color(0x14000000),
                      blurRadius: 12,
                      offset: Offset(0, -2))
                ],
              ),
              child: Column(
                children: [
                  SizedBox(height: 18),
                  QuickActions(
                    onTransfer: () {
                      Navigator.push(
                        context,
                        // Mở trang Transfer không có SĐT
                        MaterialPageRoute(builder: (_) => const TransferPage()),
                      );
                    },
                    onQr: () => _openQrScanner(context),
                  ),
                  const SizedBox(height: 12),
                  // new promo banners section between QuickActions and Activities
                  const PromoBanners(),
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
