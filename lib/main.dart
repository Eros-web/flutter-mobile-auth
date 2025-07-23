import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

import 'provider/cart_provider.dart';
import 'provider/location_provider.dart';
import 'provider/voucher_provider.dart';
import 'provider/order_provider.dart';

import 'login-sigin/log_screen.dart';
import 'login-sigin/signin_screen.dart';
import 'page/home_screen.dart';
import 'page/combined_menu_page.dart';
import 'page/cart_page.dart';
import 'page/history_page.dart';
import 'page/promo_page.dart';
import 'page/profile_page.dart';
import 'page/checkout_page.dart';
import 'page/search_location_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => LocationProvider()),
        ChangeNotifierProvider(create: (_) => VoucherProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'E-Commerce App',
      debugShowCheckedModeBanner: false,
      home: const AuthChecker(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignupScreen(),
        '/main': (context) => const MainPage(),
        '/checkout': (context) => const CheckoutPage(),
        '/search_location': (context) => Builder(
              builder: (ctx) {
                final args =
                    ModalRoute.of(ctx)?.settings.arguments as Map<String, dynamic>?;
                return SearchLocationPage(initialSearchQuery: args?['query']);
              },
            ),
      },
    );
  }
}

class AuthChecker extends StatefulWidget {
  const AuthChecker({super.key});

  @override
  State<AuthChecker> createState() => _AuthCheckerState();
}

class _AuthCheckerState extends State<AuthChecker> {
  bool _loading = true;
  Widget _targetScreen = const LoginScreen();

  @override
  void initState() {
    super.initState();
    checkLoginStatus();
  }

  Future<void> checkLoginStatus() async {
    final currentUser = FirebaseAuth.instance.currentUser;

    debugPrint('✅ AuthChecker: currentUser = ${currentUser?.uid}');

    if (!mounted) return;

    setState(() {
      _targetScreen = (currentUser != null)
          ? const MainPage()
          : const LoginScreen();
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return _targetScreen;
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const HomeScreen(),
    CombinedMenuPage(),
    const HistoryPage(),
    const ProfilePage(),
  ];

  final List<String> _titles = const [
    '', 'Menu', 'Riwayat', 'Profil',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _currentIndex == 0
            ? GestureDetector(
                onTap: () async {
                  final result = await Navigator.pushNamed(
                    context,
                    '/search_location',
                  ) as Map<String, dynamic>?;

                  if (!mounted) return;

                  if (result != null) {
                    final locProvider =
                        Provider.of<LocationProvider>(context, listen: false);
                    locProvider.updateSafe(
                      result['location'],
                      result['method'],
                      outlet: result['outlet'],
                    );
                  }
                },
                child: Container(
                  height: 40,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.search, color: Colors.grey),
                      const SizedBox(width: 8),
                      Consumer<LocationProvider>(
                        builder: (context, loc, _) {
                          final method = loc.method;
                          final detail = method.toLowerCase() == 'delivery'
                              ? loc.address
                              : loc.outlet;
                          return Text(
                            detail != null
                                ? '$method di $detail'
                                : 'Cari outlet atau produk...',
                            style: const TextStyle(
                                color: Colors.grey, fontSize: 14),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              )
            : Text(_titles[_currentIndex]),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.local_offer),
            tooltip: 'Promo',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PromoPage()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            tooltip: 'Keranjang',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CartPage()),
              );
            },
          ),
        ],
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (int index) {
          setState(() {
            _currentIndex = index;
          });
        },
        selectedItemColor: Colors.deepPurple,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Beranda'),
          BottomNavigationBarItem(
              icon: Icon(Icons.restaurant_menu), label: 'Menu'),
          BottomNavigationBarItem(
              icon: Icon(Icons.history), label: 'Riwayat'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }
}
