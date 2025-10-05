import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart'; // file bạn gửi ở trên
import 'core/app_config.dart';
import 'features/auth/providers/auth_providers.dart';
import 'features/auth/data/mock_auth_repository.dart';

void main() {
  runApp(
    ProviderScope(
      overrides: [
        if (AppConfig.useMock) authRepoProvider.overrideWithValue(MockAuthRepository()),
      ],
      child: const App(),
    ),
  );
}
