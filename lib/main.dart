import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'theme/revosilium_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF020202),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  runApp(const RevosiliumApp());
}

class RevosiliumApp extends StatelessWidget {
  const RevosiliumApp({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = GoogleFonts.jetBrainsMonoTextTheme(
      ThemeData.dark().textTheme,
    );

    return MaterialApp(
      title: 'REVOSILIUM v3',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: R.bg,
        colorScheme: const ColorScheme.dark(
          primary: R.pri,
          secondary: R.priD,
          surface: R.srf,
          error: R.err,
        ),
        textTheme: textTheme,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: false,
          iconTheme: IconThemeData(color: R.pri),
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: R.srf.withOpacity(0.8),
          indicatorColor: R.pri.withOpacity(0.15),
          iconTheme: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const IconThemeData(color: R.pri, size: 24);
            }
            return IconThemeData(color: R.txt2.withOpacity(0.5), size: 22);
          }),
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const TextStyle(color: R.pri, fontSize: 10, letterSpacing: 1);
            }
            return TextStyle(color: R.txt2.withOpacity(0.4), fontSize: 10, letterSpacing: 1);
          }),
        ),
        dialogTheme: DialogTheme(
          backgroundColor: R.srf,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        ),
        snackBarTheme: SnackBarThemeData(
          backgroundColor: R.srf,
          contentTextStyle: const TextStyle(color: R.txt),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          behavior: SnackBarBehavior.floating,
        ),
      ),
      home: const HomeScreen(),
    );
  }
}

/// Placeholder Home Screen
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: R.bg,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('REVOSILIUM v3', style: R.h1),
            const SizedBox(height: 10),
            Text('P2P · CHIFFRÉ · INTRAÇABLE', style: TextStyle(color: R.txt2, fontSize: 9, letterSpacing: 4)),
          ],
        ),
      ),
    );
  }
}
