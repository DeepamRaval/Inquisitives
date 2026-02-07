import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'ui/home_screen.dart';
import 'core/constants.dart';

void main() {
  runApp(const SafeScanApp());
}

class SafeScanApp extends StatelessWidget {
  const SafeScanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: AppConstants.backgroundColor,
        colorScheme: const ColorScheme.dark(
          primary: AppConstants.primaryColor,
          secondary: AppConstants.secondaryColor,
          surface: AppConstants.surfaceColor,
          error: AppConstants.errorColor,
        ),
        textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme)
            .apply(
              bodyColor: AppConstants.textPrimary,
              displayColor: AppConstants.textPrimary,
            ),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
