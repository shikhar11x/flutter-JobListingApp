import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/api_service.dart';
import 'providers/job_provider.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const JobListApp());
}

class JobListApp extends StatelessWidget {
  const JobListApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<ApiService>(create: (_) => ApiService()),
        ChangeNotifierProvider<ActiveJobProvider>(
          create: (context) =>
              ActiveJobProvider(context.read<ApiService>())..fetchJobs(),
        ),
        ChangeNotifierProvider<ArchivedJobProvider>(
          create: (context) =>
              ArchivedJobProvider(context.read<ApiService>())..fetchJobs(),
        ),
      ],
      child: MaterialApp(
        title: 'Job Listings',
        debugShowCheckedModeBanner: false,
        theme: _buildTheme(),
        home: const HomeScreen(),
      ),
    );
  }

  ThemeData _buildTheme() {
    const primaryColor = Color(0xFF4F46E5); // indigo
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: const Color(0xFFF7F7FB),
      primaryColor: primaryColor,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.light,
      ),
      fontFamily: 'Roboto',
      textTheme: const TextTheme(
        titleLarge: TextStyle(fontWeight: FontWeight.w700, letterSpacing: -0.3),
        titleMedium: TextStyle(fontWeight: FontWeight.w600),
        bodyMedium: TextStyle(color: Color(0xFF6B7280), height: 1.4),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black87,
        centerTitle: false,
      ),
    );
  }
}