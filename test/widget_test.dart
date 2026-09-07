import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:chroma_lens/core/di/injection_container.dart';
import 'package:chroma_lens/main.dart';

import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    await initDependencies();
  });

  testWidgets(
      'Full ChromaLens Navigation, Home, and Camera Permission Flow smoke test',
          (WidgetTester tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 2.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(const ChromaLensApp());
        await tester.pumpAndSettle();

        // 1. Verify Initial App Render (Splash/Onboarding/App Entry)
        expect(find.byType(MaterialApp), findsOneWidget);

        // 2. Navigate directly to Home
        final navigator = tester.state<NavigatorState>(find.byType(Navigator));
        navigator.pushNamed('/home');
        await tester.pumpAndSettle();

        // Verify Home Screen Elements
        expect(find.textContaining('Selamat Pagi, Jinwoo!'), findsOneWidget);
        expect(find.text('Lihat warna dengan\nlebih jelas'), findsOneWidget);
        expect(find.text('Buka Kamera'), findsOneWidget);
        expect(find.text('Profil Penglihatanmu'), findsOneWidget);
        expect(find.text('Deuteranomaly'), findsOneWidget);
        expect(find.text('Lakukan Tes Buta Warna'), findsOneWidget);

        // Verify Navbar Elements
        expect(find.text('Home'), findsOneWidget);
        expect(find.text('Kamera'), findsOneWidget);
        expect(find.text('Profile'), findsOneWidget);

        // 3. Test Opening Camera & Permission Dialog
        await tester.tap(find.text('Buka Kamera'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));
        await tester.pumpAndSettle();

        // Verify Camera Permission Dialog popup
        expect(find.textContaining('ingin\nmengakses kamera anda'), findsOneWidget);
        expect(find.text('Tolak'), findsOneWidget);
        expect(find.text('Izinkan'), findsOneWidget);

        // 4. Test "Tolak" flow -> Opens "Akses Kamera Diperlukan" Screen
        await tester.tap(find.text('Tolak'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));
        await tester.pumpAndSettle();

        expect(find.text('Akses Kamera Diperlukan'), findsOneWidget);
        expect(find.text('Aman dan Privat'), findsOneWidget);
        expect(find.text('Pengalaman Terbaik'), findsOneWidget);
        expect(find.text('Coba Lagi'), findsOneWidget);

        // 5. Test "Coba Lagi" -> Re-triggers Permission Dialog
        await tester.tap(find.text('Coba Lagi'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));
        await tester.pumpAndSettle();

        expect(find.textContaining('ingin\nmengakses kamera anda'), findsOneWidget);

        // 6. Test "Izinkan" flow -> Dismisses popup and displays camera screen controls
        await tester.tap(find.text('Izinkan'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));
        await tester.pumpAndSettle();

        expect(find.text('Penyesuaian Deuteranomaly'), findsOneWidget);
        expect(find.text('Penyesuaian'), findsOneWidget);
        expect(find.text('Original'), findsOneWidget);
        expect(
            find.text(
                'Kamera Aktif\n(Placeholder siap untuk integrasi prototype)'),
            findsOneWidget);

        // 7. Test Navigation to Profile Screen
        navigator.pushNamed('/home');
        await tester.pumpAndSettle();

        await tester.tap(find.text('Profile'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 200));
        await tester.pumpAndSettle();

        // Verify Profile Screen Elements
        expect(find.text('Profil Pengguna'), findsOneWidget);
        expect(find.text('Sung Jinwoo'), findsOneWidget);
        expect(find.text('jinwoganteng@gmail.com'), findsOneWidget);
        expect(find.text('Tipe Buta Warna'), findsOneWidget);
        expect(find.text('Bergabung Sejak'), findsOneWidget);
        expect(find.text('19 Agt 1999'), findsOneWidget);
        expect(find.text('Mode Buta Warna'), findsOneWidget);
        expect(find.text('Bahasa'), findsOneWidget);
        expect(find.text('Notifikasi'), findsOneWidget);
        expect(find.text('Tentang Aplikasi'), findsOneWidget);
        expect(find.text('Edit Profil'), findsOneWidget);

        // 8. Test Navigation from Profile to "Hasil Tes" Screen
        expect(find.text('Hasil Tes'), findsOneWidget);
        await tester.tap(find.text('Hasil Tes'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 200));
        await tester.pumpAndSettle();

        // Verify Hasil Tes Elements
        expect(find.text('Hasil Terbaru'), findsOneWidget);
        expect(find.text('Warna yang terdampak'), findsOneWidget);
        expect(find.text('Merah dan Hijau'), findsOneWidget);
        expect(find.text('Kategori'), findsOneWidget);
        expect(find.text('Tanggal Tes'), findsOneWidget);
        expect(find.text('Benar-salah'), findsOneWidget);
        expect(find.text('9/12'), findsOneWidget);
        expect(find.text('Warna yang mungkin mirip'), findsOneWidget);
        expect(find.text('Merah'), findsOneWidget);
        expect(find.text('Hijau'), findsOneWidget);
        expect(find.text('Cokelat'), findsOneWidget);
        expect(find.text('Oranye'), findsOneWidget);
        expect(find.text('Ulangi Tes'), findsOneWidget);

        // 9. Test "Ulangi Tes" Button -> Navigates to Colorblind Ishihara Test
        await tester.tap(find.text('Ulangi Tes'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 200));
        await tester.pumpAndSettle();

        expect(find.text('Tes Buta Warna'), findsOneWidget);
        expect(find.text('1 / 12'), findsOneWidget);
        expect(find.text('Angka berapa yang anda lihat?'), findsOneWidget);
      });
}