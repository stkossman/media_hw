import 'package:flutter_test/flutter_test.dart';

import 'package:media_hw/main.dart';

void main() {
  testWidgets('Photo gallery shows empty state', (WidgetTester tester) async {
    await tester.pumpWidget(const PhotoGalleryApp());
    await tester.pump();

    expect(find.text('MY PHOTOS'), findsOneWidget);
    expect(find.text('NO PHOTOS YET'), findsOneWidget);
  });
}
