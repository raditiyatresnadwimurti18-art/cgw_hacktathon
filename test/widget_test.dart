import 'package:flutter_test/flutter_test.dart';
import 'package:cgw_hacktathon/main.dart';

void main() {
  testWidgets('Login screen smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    // Kita masukkan isLoggedIn: false karena kita ingin mengetes layar login
    await tester.pumpWidget(const MyApp(isLoggedIn: false));

    // Cek apakah teks 'Login' ada di layar
    expect(find.text('Login'), findsAtLeast(1));
    
    // Cek apakah ada input untuk Phone Number
    expect(find.text('Phone Number'), findsOneWidget);
  });
}
