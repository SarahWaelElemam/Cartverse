import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fedis/main.dart'; // Import your main app file

void main() {
  testWidgets('MyApp widget test', (WidgetTester tester) async {
    // Build our app and trigger a frame
    await tester.pumpWidget(MyApp());

    // Verify the HomeScreen is loaded by default
    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.text('Cartverse'), findsOneWidget); // Assuming HomeScreen has this text
  });

  testWidgets('Navigation to LoginScreen test', (WidgetTester tester) async {
    await tester.pumpWidget(MyApp());

    // Tap on a button that should navigate to LoginScreen
    // (You'll need to add a login button to your HomeScreen or trigger navigation)
    await tester.tap(find.byKey(Key('loginButton')));
    await tester.pumpAndSettle();

    // Verify LoginScreen is shown
    expect(find.byType(LoginScreen), findsOneWidget);
  });

  testWidgets('Navigation to all views test', (WidgetTester tester) async {
    await tester.pumpWidget(MyApp());

    // Test navigation to each screen
    final routes = {
      '/login': LoginScreen,
      '/register': RegisterScreen,
      '/categories': CategoriesScreen,
      '/about': AboutScreen,
      '/contact': ContactScreen,
      '/cart': CartScreen,
      '/wishlist': WishlistScreen,
    };

    for (final route in routes.entries) {
      // Use Navigator to push each route
      final navigator = tester.state<NavigatorState>(find.byType(Navigator));
      navigator.pushNamed(route.key);
      await tester.pumpAndSettle();

      // Verify the correct screen is shown
      expect(find.byType(route.value), findsOneWidget);

      // Go back to home for next test
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();
    }
  });

  testWidgets('Theme verification test', (WidgetTester tester) async {
    await tester.pumpWidget(MyApp());

    // Verify theme properties
    final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.theme?.primarySwatch, Colors.blue);
    expect(app.debugShowCheckedModeBanner, false);
  });

  testWidgets('System UI overlay style test', (WidgetTester tester) async {
    await tester.pumpWidget(MyApp());

    // Verify system UI style
    final systemUiOverlayStyle = SystemChrome.latestStyle;
    expect(systemUiOverlayStyle?.statusBarColor, Colors.transparent);
  });
}