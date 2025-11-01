Profile feature UI

Files added:
- ui/profile_page.dart — main "My profile" detail page
- ui/profile_services_page.dart — list of services for the current user
- ui/other_profile_page.dart — view for seeing another user's profile (different actions)
- ui/widgets/profile_header.dart — avatar + name + subtitle header
- ui/widgets/profile_details.dart — "Chi tiết" card with contact and work info
- ui/widgets/reviews_list.dart — simple reviews list

How to use:
- Import and navigate to the pages where appropriate, for example:
  Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfilePage()));

These are lightweight scaffold UIs to match provided screenshots. You can wire data, providers and navigation to the rest of the app as needed.

Providers and data structure
- domain/profile.dart — Profile model
- data/mock_profile_repository.dart — MockProfileRepository with sample data
- providers/providers.dart — Riverpod providers (profileRepositoryProvider, myProfileProvider, profileByIdProvider)

Social network / JSON shape
- The `socialNetwork` field is represented as a JSON-like map in Dart: `Map<String, String>?`.
- Example:

```json
{
  "facebook": "https://facebook.com/lethanhnam",
  "insta": "https://instagram.com/lethanhnam",
  "linkin": "HCM-Q1"
}
```

The mock repository populates `socialNetwork` with the keys `facebook`, `insta`, and `linkin`.

How to use providers in UI
- Wrap your app with Riverpod's ProviderScope (already used in the app). Then in a widget:

```dart
final profile = ref.watch(myProfileProvider);

profile.when(
  data: (p) => Text(p.name),
  loading: () => CircularProgressIndicator(),
  error: (e, st) => Text('Error'),
);
```

You can also fetch other users with `ref.watch(profileByIdProvider('someId'))`.
