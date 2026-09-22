import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:surakshit_mobile/app.dart';
import 'package:surakshit_mobile/providers/auth_provider.dart';
import 'package:surakshit_mobile/providers/scheme_provider.dart';
import 'package:surakshit_mobile/providers/partner_provider.dart';
import 'package:surakshit_mobile/providers/application_provider.dart';
import 'package:surakshit_mobile/utils/i18n.dart';

void main() {
  testWidgets('App builds and shows the login screen', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => LanguageManager()),
          ChangeNotifierProvider(create: (_) => AuthProvider()),
          ChangeNotifierProvider(create: (_) => SchemeProvider()),
          ChangeNotifierProvider(create: (_) => PartnerProvider()),
          ChangeNotifierProvider(create: (_) => ApplicationProvider()),
        ],
        child: const SurakshitApp(),
      ),
    );
    await tester.pump(const Duration(milliseconds: 500));

    // Login screen essentials
    expect(find.text('Welcome to'), findsOneWidget);
    expect(find.text('Surakshit'), findsWidgets);
  });
}
