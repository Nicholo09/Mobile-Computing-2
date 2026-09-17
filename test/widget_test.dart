import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:mc2_portfolio/main.dart';
import 'package:mc2_portfolio/providers/theme_provider.dart';

void main() {
  testWidgets('Activity 2 opens the Network Monitor dashboard', (tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => ThemeProvider(),
        child: const MyApp(),
      ),
    );

    await tester.tap(find.text('Activity 2'));
    await tester.pumpAndSettle();

    expect(find.text('Network Monitor'), findsOneWidget);
    expect(find.text('Current Network'), findsOneWidget);
    expect(find.text('Queued Requests'), findsOneWidget);
  });
}
