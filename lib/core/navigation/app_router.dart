import 'package:flutter/material.dart';
import '../../auth/login_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/bimbingan/bimbingan_screen.dart';
import '../../features/logbook/logbook_screen.dart';
import '../../features/milestone/milestone_screen.dart';
import '../../features/profile/profile_screen.dart';
import '../../splash_screen.dart';

class AppRouter {
  static const String splashRoute = '/splash';
  static const String loginRoute = '/login';
  static const String homeRoute = '/home';
  static const String mainRoute = '/main';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
      return MaterialPageRoute(builder: (_) => const SplashScreen()); // Tambahkan splash screen sebagai rute default
      case splashRoute:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case loginRoute:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case homeRoute:
      case mainRoute:
        return MaterialPageRoute(builder: (_) => const MainScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('Route not found: ${settings.name}'),
            ),
          ),
        );
    }
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const BimbinganScreen(),
    const MilestoneScreen(),
    const LogbookScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month),
            label: 'Bimbingan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.flag),
            label: 'Milestone',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: 'Logbook',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}