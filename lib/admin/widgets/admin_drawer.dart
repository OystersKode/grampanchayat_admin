import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
    const Color backgroundColor = Color(0xFFFFF8F7);
    const Color textColor = Color(0xFF5A403C);
    final firebase_auth_service.AuthService authService = firebase_auth_service.AuthService.instance;
    final user = authService.getCurrentUser();

    return Drawer(
      backgroundColor: backgroundColor,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.only(top: 60, bottom: 32, left: 24, right: 24),
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFFFFEAEA), // Slightly more maroon-tinted background
              borderRadius: const BorderRadius.only(
                bottomRight: Radius.circular(32),
              ),
              border: Border(
                bottom: BorderSide(color: primaryMaroon.withOpacity(0.1), width: 1),
                right: BorderSide(color: primaryMaroon.withOpacity(0.1), width: 1),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: primaryMaroon.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const CircleAvatar(
                    radius: 36,
                    backgroundColor: backgroundColor,
                    child: Icon(Icons.admin_panel_settings, color: primaryMaroon, size: 40),
                  ),
                ),
                const SizedBox(height: 20),
                FutureBuilder<DocumentSnapshot>(
                  future: FirebaseFirestore.instance.collection('admins').doc(user?.uid).get(),
                  builder: (context, snapshot) {
                    String name = 'Admin User';
                    if (snapshot.hasData && snapshot.data!.exists) {
                      name = snapshot.data!.get('village_name') ?? 'Admin User';
                    }
                    return Text(
                      name,
                      style: const TextStyle(
                        color: primaryMaroon, // Darker text for contrast on light bg
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 4),
                Text(
                  user?.email ?? 'admin@grampanchayat.gov.in',
                  style: TextStyle(
                    color: textColor.withOpacity(0.7),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _drawerItem(
                  context,
                  icon: Icons.dashboard_outlined,
                  label: 'Dashboard',
                  onTap: () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const AdminDashboardScreen()),
                  ),
                ),
                _drawerItem(
                  context,
                  icon: Icons.newspaper_outlined,
                  label: 'News Management',
                  onTap: () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const CreateNewsScreen()),
                  ),
                ),
                _drawerItem(
                  context,
                  icon: Icons.auto_awesome_outlined,
                  label: 'Village Wishes',
                  onTap: () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const CreateWishesScreen()),
                  ),
                ),
                _drawerItem(
                  context,
                  icon: Icons.people_outline,
                  label: 'Membership Requests',
                  onTap: () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const MemberRequestsScreen()),
                  ),
                ),
              ],
            ),
          ),
          const Divider(indent: 24, endIndent: 24),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            child: _drawerItem(
              context,
              icon: Icons.logout,
              label: 'Logout',
              color: Colors.red,
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
          ),
        ],
      ),
    );
  }

  Widget _drawerItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? color,
  }) {
    const Color textColor = Color(0xFF5A403C);
    const Color primaryMaroon = Color(0xFF8B0000);
    final isSelected = ModalRoute.of(context)?.settings.name == label; // Simplified check

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: color ?? textColor.withOpacity(0.7)),
        title: Text(
          label,
          style: TextStyle(
            color: color ?? textColor,
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        hoverColor: (color ?? primaryMaroon).withOpacity(0.1),
        tileColor: isSelected ? (color ?? primaryMaroon).withOpacity(0.1) : Colors.transparent,
      ),
    );
  }
}
