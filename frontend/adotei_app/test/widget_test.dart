import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:adotei_app/main.dart';
import 'package:adotei_app/providers/auth_provider.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => AuthProvider(),
        child: const AdoteiApp(),
      ),
    );
    expect(find.byType(AdoteiApp), findsOneWidget);
  });
}
