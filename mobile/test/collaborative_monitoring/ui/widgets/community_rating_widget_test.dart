import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/src/collaborative_monitoring/ui/widgets/community_rating_widget.dart';

void main() {
  testWidgets('CommunityRatingWidget has a message', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: CommunityRatingWidget()));
    final messageFinder = find.text('Community Rating Widget');
    expect(messageFinder, findsOneWidget);
  });
}
