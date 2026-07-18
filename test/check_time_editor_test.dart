import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:piyasa_radar/shared/widgets/check_time_editor.dart';

class _CheckTimeEditorHarness extends StatefulWidget {
  const _CheckTimeEditorHarness({
    required this.initialTimes,
    this.initialPickerTime,
    this.errorText,
  });

  final List<String> initialTimes;
  final TimeOfDay? initialPickerTime;
  final String? errorText;

  @override
  State<_CheckTimeEditorHarness> createState() =>
      _CheckTimeEditorHarnessState();
}

class _CheckTimeEditorHarnessState extends State<_CheckTimeEditorHarness> {
  late List<String> times = widget.initialTimes;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: CheckTimeEditor(
          times: times,
          errorText: widget.errorText,
          initialPickerTime: widget.initialPickerTime,
          onChanged: (value) => setState(() => times = value),
        ),
      ),
    );
  }
}

void main() {
  testWidgets('adds check times sorted and prevents duplicates', (
    tester,
  ) async {
    await tester.pumpWidget(
      const _CheckTimeEditorHarness(
        initialTimes: ['14:00'],
        initialPickerTime: TimeOfDay(hour: 8, minute: 5),
      ),
    );

    await tester.tap(find.text('Kontrol saati ekle'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    var state = tester.state<_CheckTimeEditorHarnessState>(
      find.byType(_CheckTimeEditorHarness),
    );
    expect(state.times, const ['08:05', '14:00']);

    await tester.tap(find.text('Kontrol saati ekle'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    state = tester.state<_CheckTimeEditorHarnessState>(
      find.byType(_CheckTimeEditorHarness),
    );
    expect(state.times, const ['08:05', '14:00']);
  });

  testWidgets('removes check times from chips', (tester) async {
    await tester.pumpWidget(
      const _CheckTimeEditorHarness(initialTimes: ['09:00', '14:00']),
    );

    await tester.tap(find.byIcon(Icons.cancel).first);
    await tester.pumpAndSettle();

    final state = tester.state<_CheckTimeEditorHarnessState>(
      find.byType(_CheckTimeEditorHarness),
    );
    expect(state.times, const ['14:00']);
    expect(find.text('09:00'), findsNothing);
  });

  testWidgets('shows an optional validation message', (tester) async {
    await tester.pumpWidget(
      const _CheckTimeEditorHarness(
        initialTimes: [],
        errorText: 'En az bir kontrol saati seçmelisiniz.',
      ),
    );

    expect(find.text('En az bir kontrol saati seçmelisiniz.'), findsOneWidget);
  });
}
