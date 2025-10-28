import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'onboarding_providers.dart';
import '../domain/models/models.dart';

/// ----- Selections (id) -----

/// Province (Tỉnh/TP) được chọn
final selectedProvinceIdProvider = StateProvider<String?>((_) => null);

/// District (Quận/Huyện) được chọn
final selectedDistrictIdProvider = StateProvider<String?>((_) => null);

/// Ward (Xã/Phường) được chọn
final selectedWardIdProvider = StateProvider<String?>((_) => null);

/// ----- Lists -----

/// Danh sách Province (Tỉnh/TP)
final provincesProvider = FutureProvider<List<Region>>((ref) async {
  final repo = ref.read(onboardingRepoProvider);
  final items = await repo.getProvinces(); // alias fetchProvinces()
  items.sort((a, b) => a.name.compareTo(b.name));
  // Giữ cache sau khi rời màn để quay lại không refetch
  ref.keepAlive();
  return items;
});

/// Danh sách District theo Province
final districtsProvider = FutureProvider.autoDispose<List<Region>>((ref) async {
  final provinceId = ref.watch(selectedProvinceIdProvider);
  if (provinceId == null) return <Region>[];
  final repo = ref.read(onboardingRepoProvider);
  final items = await repo.getDistricts(provinceId); // alias fetchDistricts()
  items.sort((a, b) => a.name.compareTo(b.name));
  return items;
});

/// Danh sách Ward theo District
final wardsProvider = FutureProvider.autoDispose<List<Region>>((ref) async {
  final districtId = ref.watch(selectedDistrictIdProvider);
  if (districtId == null) return <Region>[];
  final repo = ref.read(onboardingRepoProvider);
  final items = await repo.getWards(districtId); // alias fetchWards()
  items.sort((a, b) => a.name.compareTo(b.name));
  return items;
});

/// ----- Helpers: Region theo id đã chọn (lookup nhanh từ list hiện có) -----

final selectedProvinceProvider = Provider<Region?>((ref) {
  final id = ref.watch(selectedProvinceIdProvider);
  final listAsync = ref.watch(provincesProvider);
  return listAsync.maybeWhen(
    data: (items) => items.firstWhere(
          (e) => e.id == id,
      orElse: () => null as Region,
    ),
    orElse: () => null,
  );
});

final selectedDistrictProvider = Provider<Region?>((ref) {
  final id = ref.watch(selectedDistrictIdProvider);
  final listAsync = ref.watch(districtsProvider);
  return listAsync.maybeWhen(
    data: (items) => items.firstWhere(
          (e) => e.id == id,
      orElse: () => null as Region,
    ),
    orElse: () => null,
  );
});

final selectedWardProvider = Provider<Region?>((ref) {
  final id = ref.watch(selectedWardIdProvider);
  final listAsync = ref.watch(wardsProvider);
  return listAsync.maybeWhen(
    data: (items) => items.firstWhere(
          (e) => e.id == id,
      orElse: () => null as Region,
    ),
    orElse: () => null,
  );
});

/// ----- Full address text (từ wardId → district → province) -----
final fullAddressTextProvider = FutureProvider<String?>((ref) async {
  final wardId = ref.watch(selectedWardIdProvider);
  if (wardId == null) return null;

  final repo = ref.read(onboardingRepoProvider);

  // ward detail
  final ward = await repo.getRegionDetail(wardId);
  if (ward.parentId == null) return ward.name;

  // district detail
  final district = await repo.getRegionDetail(ward.parentId!);
  // province detail
  Region? province;
  if (district.parentId != null) {
    province = await repo.getRegionDetail(district.parentId!);
  }

  final parts = <String>[
    ward.name,
    district.name,
    if (province != null) province.name,
  ];
  return parts.join(', ');
});


void selectProvince(WidgetRef ref, String? provinceId) {
  ref.read(selectedProvinceIdProvider.notifier).state = provinceId;
  ref.read(selectedDistrictIdProvider.notifier).state = null;
  ref.read(selectedWardIdProvider.notifier).state = null;
}

void selectDistrict(WidgetRef ref, String? districtId) {
  ref.read(selectedDistrictIdProvider.notifier).state = districtId;
  ref.read(selectedWardIdProvider.notifier).state = null;
}

void selectWard(WidgetRef ref, String? wardId) {
  ref.read(selectedWardIdProvider.notifier).state = wardId;
}
