import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/sneaker.dart';
import 'screens/home_screen.dart';

void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive
  await Hive.initFlutter();
  
  // Register our Sneaker adapter
  Hive.registerAdapter(SneakerAdapter());
  
  // Open our sneakers box
  await Hive.openBox<Sneaker>('sneakers');
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sneaker Storekeeper',
 theme: ThemeData(
  colorScheme: ColorScheme.fromSeed(
    seedColor: const Color(0xFF9C27B0), // Purple
    brightness: Brightness.light,
  ),
  useMaterial3: true,
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFF9C27B0), // Purple
    foregroundColor: Colors.white,
  ),
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: Color(0xFF9C27B0), // Purple
    foregroundColor: Colors.white,
  ),
),
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}