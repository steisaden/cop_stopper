import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/src/ui/components/shadcn_button.dart';

void main() {
  group('ShadcnButton Visual Regression Tests', () {
    testWidgets('primary button visual consistency', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: ShadcnButton.primary(
                text: 'Primary Button',
                onPressed: () {},
              ),
            ),
          ),
        ),
      );

      await expectLater(
        find.byType(ShadcnButton),
        matchesGoldenFile('goldens/shadcn_button_primary.png'),
      );
    });

    testWidgets('secondary button visual consistency', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: ShadcnButton.secondary(
                text: 'Secondary Button',
                onPressed: () {},
              ),
            ),
          ),
        ),
      );

      await expectLater(
        find.byType(ShadcnButton),
        matchesGoldenFile('goldens/shadcn_button_secondary.png'),
      );
    });

    testWidgets('destructive button visual consistency', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: ShadcnButton.destructive(
                text: 'Destructive Button',
                onPressed: () {},
              ),
            ),
          ),
        ),
      );

      await expectLater(
        find.byType(ShadcnButton),
        matchesGoldenFile('goldens/shadcn_button_destructive.png'),
      );
    });

    testWidgets('outline button visual consistency', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: ShadcnButton.outline(
                text: 'Outline Button',
                onPressed: () {},
              ),
            ),
          ),
        ),
      );

      await expectLater(
        find.byType(ShadcnButton),
        matchesGoldenFile('goldens/shadcn_button_outline.png'),
      );
    });

    testWidgets('ghost button visual consistency', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: ShadcnButton.ghost(
                text: 'Ghost Button',
                onPressed: () {},
              ),
            ),
          ),
        ),
      );

      await expectLater(
        find.byType(ShadcnButton),
        matchesGoldenFile('goldens/shadcn_button_ghost.png'),
      );
    });

    testWidgets('link button visual consistency', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: ShadcnButton.link(
                text: 'Link Button',
                onPressed: () {},
              ),
            ),
          ),
        ),
      );

      await expectLater(
        find.byType(ShadcnButton),
        matchesGoldenFile('goldens/shadcn_button_link.png'),
      );
    });
  });
}
