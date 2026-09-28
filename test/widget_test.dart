import 'package:flutter_test/flutter_test.dart';

import 'package:erp/main.dart';

void main() {
  testWidgets('Login demo carrega perfis', (tester) async {
    await tester.pumpWidget(const ErpAgroApp());
    await tester.pump();

    expect(find.text('ERP Agro'), findsWidgets);
    expect(find.text('Acesso à demonstração'), findsOneWidget);
    expect(find.text('Tiago Admin'), findsOneWidget);
    expect(find.text('Carlos Mendes'), findsOneWidget);
    expect(find.text('Marina Costa'), findsOneWidget);
  });
}
