import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/product_provider.dart';
import 'providers/exchange_provider.dart';
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
        ChangeNotifierProxyProvider<AuthProvider, ProductProvider>(
          create: (_) => ProductProvider(currentUserId: null, products: []),
          update: (ctx, auth, previousProductProvider) {
            if (auth.currentUser?.id != previousProductProvider?.currentUserId) {
              final newProvider = ProductProvider(currentUserId: auth.currentUser?.id);
              if (auth.currentUser != null) {
                newProvider.fetchMyProducts();
              }
              return newProvider;
            }
            return previousProductProvider!;
          },
        ),
        ChangeNotifierProxyProvider<AuthProvider, ExchangeProvider>(
          create: (_) => ExchangeProvider(null),
          update: (ctx, auth, previousExchangeProvider) {
            return ExchangeProvider(auth.currentUser?.id);
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
