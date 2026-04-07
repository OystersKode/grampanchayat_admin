import 'package:flutter/material.dart';
import '../screens/admin_dashboard_screen.dart';
import '../screens/create_news_screen.dart';
import '../screens/create_wishes_screen.dart';
import '../screens/member_requests_screen.dart';
import '../screens/admin_login_screen.dart';
import '../services/auth_service.dart' as firebase_auth_service;

class AdminDrawer extends StatelessWidget {
  const AdminDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    const Color primaryMaroon = Color(0xFF8B0000);
    final firebase_auth_service.AuthService authService = firebase_auth_service.AuthService.instance;

    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(color: primaryMaroon),
            currentAccountPicture: const CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.person, color: primaryMaroon, size: 40),
            ),
            accountName: const Text(
              'Admin User',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            accountEmail: Text(authService.getCurrentUser()?.email ?? 'admin@grampanchayat.gov.in'),
          ),
          ListTile(
            leading: const Icon(Icons.dashboard),
            title: const Text('Dashboard'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const AdminDashboardScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.newspaper),
            title: const Text('News Management'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const CreateNewsScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.card_giftcard),
            title: const Text('Village Wishes'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const CreateWishesScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.people),
            title: const Text('Membership Requests'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const MemberRequestsScreen()),
              );
            },
          ),
          const Spacer(),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout', style: TextStyle(color: Colors.red)),
            onTap: () async {
              await authService.logout();
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const AdminLoginScreen()),
                  (route) => false,
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
