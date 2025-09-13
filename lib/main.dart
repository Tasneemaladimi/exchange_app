import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/item_provider.dart';
import 'screens/splash_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProxyProvider<AuthProvider, ItemProvider>(
          // Provides an initial, empty provider for the logged-out state.
          create: (_) => ItemProvider(currentUserId: null, items: []),
          // When AuthProvider changes, this rebuilds ItemProvider.
          update: (ctx, auth, previousItemProvider) {
            // If the user's login status changes, we create a new provider.
            // This ensures data is cleared upon logout.
            if (auth.currentUser?.id != previousItemProvider?.currentUserId) {
              final newProvider = ItemProvider(currentUserId: auth.currentUser?.id);
              // If the user is logged in, immediately trigger a data fetch.
              if (auth.currentUser != null) {
                newProvider.fetchAndSetItems();
              }
              return newProvider;
            }
            // If the user ID is the same, we can return the previous provider.
            return previousItemProvider!;
          },
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (ctx, themeProv, _) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Exchange App',
            theme: ThemeData(
              primaryColor: const Color(0xFF4E6CFF),
              scaffoldBackgroundColor: Colors.white,
              brightness: Brightness.light,
              appBarTheme: const AppBarTheme(backgroundColor: Color(0xFF4E6CFF)),
            ),
            darkTheme: ThemeData(
              primaryColor: const Color(0xFF4E6CFF),
              scaffoldBackgroundColor: Colors.black,
              brightness: Brightness.dark,
              appBarTheme: const AppBarTheme(backgroundColor: Color(0xFF4E6CFF)),
            ),
            themeMode: themeProv.themeMode,
            home: const SplashScreen(),
            routes: {
              '/login': (ctx) => const LoginScreen(),
              '/onboarding': (ctx) => const OnboardingScreen(),
              '/home': (ctx) => const HomeScreen(),
            },
          );
        },
      ),
    );
  }
}
