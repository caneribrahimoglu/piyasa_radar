import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:piyasa_radar/app/app.dart';
import 'package:piyasa_radar/features/watchlist/domain/models/product_watch_item.dart';
import 'package:piyasa_radar/features/watchlist/presentation/pages/add_product_watch_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _AddProductHarness extends StatefulWidget {
  const _AddProductHarness();

  @override
  State<_AddProductHarness> createState() => _AddProductHarnessState();
}

class _AddProductHarnessState extends State<_AddProductHarness> {
  ProductWatchItem? result;

  Future<void> _openForm() async {
    final item = await Navigator.of(context).push<ProductWatchItem>(
      MaterialPageRoute(builder: (context) => const AddProductWatchPage()),
    );
    if (item != null) setState(() => result = item);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          FilledButton(onPressed: _openForm, child: const Text('Formu aç')),
          if (result != null)
            Text(
              'tracking:${result!.stockTrackingEnabled},stock:${result!.inStock}',
            ),
        ],
      ),
    );
  }
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('disabled form switch does not change initial stock status', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: _AddProductHarness()));
    await tester.tap(find.text('Formu aç'));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Ürün adı'),
      'Test Ürünü',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Ürün linki'),
      'https://example.com/product',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Pazaryeri/Site'),
      'Test Pazarı',
    );
    await tester.tap(find.byType(Switch));
    await tester.tap(find.widgetWithText(FilledButton, 'Kaydet'));
    await tester.pumpAndSettle();

    expect(find.text('tracking:false,stock:true'), findsOneWidget);
  });

  testWidgets('disabled stock tracking is neutral on card and detail', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const PiyasaRadarApp());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ürün Takibi'));
    await tester.pumpAndSettle();

    expect(find.text('Stok takibi kapalı'), findsOneWidget);

    await tester.tap(find.text('iPhone 15 128GB'));
    await tester.pumpAndSettle();

    expect(find.text('Stok takibi'), findsOneWidget);
    expect(find.text('Kapalı'), findsOneWidget);
    expect(find.text('Stok durumu'), findsOneWidget);
    expect(find.text('Kontrol edilmiyor'), findsOneWidget);
  });
}
