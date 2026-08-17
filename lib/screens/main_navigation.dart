import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'home/dashboard_screen.dart';
import 'control/control_screen.dart';
import 'history/history_screen.dart';
import 'settings/settings_screen.dart';
import 'alerts/alerts_screen.dart';
import 'device_status/device_status_screen.dart';
import 'device_status/multi_device_screen.dart';
import 'profile/profile_screen.dart';
import '../utils/theme.dart'; // Imported AppTheme correctly to fetch palette variables

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    DashboardScreen(),
    ControlScreen(),
    HistoryScreen(),
    SettingsScreen(),
  ];

  // Utility to determine inner page names smoothly for non-home destinations
  String _getPageTitle() {
    switch (_currentIndex) {
      case 1:
        return 'Device Control';
      case 2:
        return 'History Analytics';
      case 3:
        return 'System Settings';
      default:
        return '';
    }
  }

  void _openScreen(Widget screen) {
    Navigator.of(context).pop(); // close drawer
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    final user = authService.currentUser;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      // FIXED DUAL TITLE: Unified parent appbar using dynamic styling conditions
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        // 1. Made the drawer trigger menu button symbol icon slightly bigger
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu_rounded, size: 28),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        // 2. Brought title closely packed directly beside the drawer icon symbol (Facebook-style)
        titleSpacing: 0,
        title: _currentIndex == 0
            ? Text(
                'Smart Habitat',
                style: TextStyle(
                  fontSize: 27, // 3. Scaled up text layout size on main home tab
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                  // 4. Custom Tealish White for Dark Mode, vibrant primary teal for Light Mode
                  color: isDarkMode ? const Color(0xFFE0F2F1) : AppTheme.brandTeal,
                ),
              )
            : Text(
                _getPageTitle(),
                style: TextStyle(
                  fontSize: 20, // Lower page headers dynamically scale back down smoothly
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? const Color(0xFFE0F2F1) : AppTheme.brandTeal,
                ),
              ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            // FIXED DRAWER COLOR: Synced upper background layer exactly with splash colors
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF00A294), Color(0xFF00897B)], // Splash gradient tones
                ),
              ),
              accountName: Text(
                user?.displayName ?? 'User',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              accountEmail: Text(user?.email ?? ''),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(
                  Icons.person, 
                  color: AppTheme.brandTeal, 
                  size: 36,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.notifications_active_outlined),
              title: const Text('Alerts & Notifications'),
              onTap: () => _openScreen(const AlertsScreen()),
            ),
            ListTile(
              leading: const Icon(Icons.wifi_tethering),
              title: const Text('Device Status'),
              onTap: () => _openScreen(const DeviceStatusScreen()),
            ),
            ListTile(
              leading: const Icon(Icons.devices_other),
              title: const Text('My Devices'),
              onTap: () => _openScreen(const MultiDeviceScreen()),
            ),
            ListTile(
              leading: const Icon(Icons.account_circle_outlined),
              title: const Text('Profile'),
              onTap: () => _openScreen(const ProfileScreen()),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () async {
                Navigator.of(context).pop();
                await authService.signOut();
              },
            ),
          ],
        ),
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() => _currentIndex = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.tune_outlined),
            selectedIcon: Icon(Icons.tune),
            label: 'Control',
          ),
          NavigationDestination(
            icon: Icon(Icons.show_chart_outlined),
            selectedIcon: Icon(Icons.show_chart),
            label: 'History',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
