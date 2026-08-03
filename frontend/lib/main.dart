import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'bloc/book_swipe_bloc.dart';
import 'screens/book_swipe_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const seedColor = Color(0xFF673AB7);

    const textTheme = TextTheme(
      headlineMedium: TextStyle(fontWeight: FontWeight.bold, letterSpacing: -0.5, height: 1.2),
      headlineSmall: TextStyle(fontWeight: FontWeight.bold, letterSpacing: -0.25, height: 1.25),
      titleLarge: TextStyle(fontWeight: FontWeight.w700, letterSpacing: 0, height: 1.3),
      titleMedium: TextStyle(fontWeight: FontWeight.w600, letterSpacing: 0.15, height: 1.35),
      titleSmall: TextStyle(fontWeight: FontWeight.w600, letterSpacing: 0.1, height: 1.4),
      bodyLarge: TextStyle(fontWeight: FontWeight.normal, letterSpacing: 0.15, height: 1.5),
      bodyMedium: TextStyle(fontWeight: FontWeight.normal, letterSpacing: 0.25, height: 1.45),
      bodySmall: TextStyle(fontWeight: FontWeight.normal, letterSpacing: 0.4, height: 1.4),
      labelLarge: TextStyle(fontWeight: FontWeight.w700, letterSpacing: 1.2),
      labelMedium: TextStyle(fontWeight: FontWeight.w600, letterSpacing: 1.0),
      labelSmall: TextStyle(fontWeight: FontWeight.w500, letterSpacing: 0.8),
    );

    return MaterialApp(
      title: 'Book Cover Speed Dating',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      theme: ThemeData(
        useMaterial3: true,
        textTheme: textTheme,
        colorScheme: ColorScheme.fromSeed(
          seedColor: seedColor,
          brightness: Brightness.light,
          surface: const Color(0xFFF7F5FA),
          surfaceContainer: const Color(0xFFEEEAF4),
        ),
        cardTheme: CardThemeData(
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        bottomSheetTheme: const BottomSheetThemeData(
          backgroundColor: Color(0xFFF7F5FA),
          surfaceTintColor: Colors.transparent,
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        textTheme: textTheme,
        colorScheme: ColorScheme.fromSeed(
          seedColor: seedColor,
          brightness: Brightness.dark,
          surface: const Color(0xFF120E24),
          surfaceContainer: const Color(0xFF1D1735),
          onSurface: const Color(0xFFF1EEF9),
        ),
        cardTheme: CardThemeData(
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        bottomSheetTheme: const BottomSheetThemeData(
          backgroundColor: Color(0xFF120E24),
          surfaceTintColor: Colors.transparent,
        ),
      ),
      home: BlocProvider(
        create: (context) => BookSwipeBloc()..add(const LoadBooks()),
        child: const BookSwipeScreen(),
      ),
    );
  }
}
