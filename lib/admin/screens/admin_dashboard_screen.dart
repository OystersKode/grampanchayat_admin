import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'create_news_screen.dart';
import 'create_wishes_screen.dart';
import 'admin_login_screen.dart';
import 'member_requests_screen.dart';
import '../widgets/admin_drawer.dart';
import '../services/auth_service.dart' as firebase_auth_service;

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  late Future<Map<String, dynamic>> _statsFuture;
  final firebase_auth_service.AuthService _authService = firebase_auth_service.AuthService.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _statsFuture = _fetchDashboardStats();
  }

  Future<Map<String, dynamic>> _fetchDashboardStats() async {
    try {
      final usersQuery = await _db.collection('guest_users').get();
      final newsQuery = await _db.collection('news').get();
      final likesQuery = await _db.collection('likes').get();
      final pendingRequestsQuery = await _db.collection('member_requests')
          .where('status', isEqualTo: 'pending')
          .get();

      return {
        'total_users': usersQuery.size,
        'total_news': newsQuery.size,
        'total_likes': likesQuery.size,
        'pending_requests': pendingRequestsQuery.size,
      };
    } catch (e) {
      print('Error fetching stats: $e');
      return {
        'total_users': 0,
        'total_news': 0,
        'total_likes': 0,
        'pending_requests': 0,
      };
    }
  }

  Future<void> _logout() async {
    await _authService.logout();
    if (!mounted) {
      return;
    }
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute<void>(builder: (BuildContext context) => const AdminLoginScreen()),
      (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryMaroon = Color(0xFF8B0000);
    const Color backgroundColor = Color(0xFFFFF8F7);
    const Color textColor = Color(0xFF5A403C);

    return Scaffold(
      backgroundColor: backgroundColor,
      drawer: const AdminDrawer(),
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: primaryMaroon),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: const Text(
          'Kagwad Grampanchayat Admin',
          style: TextStyle(
            color: primaryMaroon,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const Text(
                      'OFFICIAL GOVERNANCE GATEWAY',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                        color: Color(0xFF9E7E7A),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Admin Dashboard',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: primaryMaroon,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0xFFD9A5A5),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 40),
                    FutureBuilder<Map<String, dynamic>>(
                      future: _statsFuture,
                      builder: (BuildContext context, AsyncSnapshot<Map<String, dynamic>> snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 20),
                            child: LinearProgressIndicator(),
                          );
                        }
                        final Map<String, dynamic> data = snapshot.data ?? <String, dynamic>{};
                        return Column(
                          children: [
                            GridView.count(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              crossAxisCount: 2,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                              childAspectRatio: 2.2,
                              children: [
                                _statCard('Total Users', '${data['total_users'] ?? 0}', Icons.people_outline, primaryMaroon),
                                _statCard('Total News', '${data['total_news'] ?? 0}', Icons.newspaper, const Color(0xFF5A403C)),
                                _statCard('Total Likes', '${data['total_likes'] ?? 0}', Icons.favorite_border, primaryMaroon),
                                _statCard('Pending', '${data['pending_requests'] ?? 0}', Icons.pending_actions, const Color(0xFF5A403C)),
                              ],
                            ),
                            const SizedBox(height: 32),
                          ],
                        );
                      },
                    ),
                    _buildDashboardItem(
                      context,
                      title: 'Create News',
                      subtitle: 'Add village announcements and updates',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const CreateNewsScreen()),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildDashboardItem(
                      context,
                      title: 'Member Requests',
                      subtitle: 'Review and approve/reject membership requests',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const MemberRequestsScreen()),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildDashboardItem(
                      context,
                      title: 'Create Wishes',
                      subtitle: 'Add wishes, events, and achievements',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const CreateWishesScreen()),
                      ),
                    ),
                    const SizedBox(height: 48),
                    const Divider(color: Color(0xFFF1F1F1)),
                    const SizedBox(height: 24),
                    TextButton.icon(
                      onPressed: _logout,
                      icon: const Icon(Icons.logout, color: primaryMaroon, size: 20),
                      label: const Text(
                        'LOGOUT',
                        style: TextStyle(
                          color: primaryMaroon,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'MANAGE VILLAGE CONTENT EFFICIENTLY',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  color: Color(0xFFB09491),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDashboardItem(
    BuildContext context, {
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    const Color primaryMaroon = Color(0xFF8B0000);
    const Color textColor = Color(0xFF5A403C);

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFFF1F0),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: primaryMaroon,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 13,
                    color: textColor.withOpacity(0.8),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: onTap,
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryMaroon,
              foregroundColor: Colors.white,
              elevation: 4,
              shadowColor: primaryMaroon.withOpacity(0.4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Open',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(width: 4),
                Icon(Icons.arrow_forward, size: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _footerLink(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.bold,
        color: Color(0xFF5A403C),
      ),
    );
  }

  Widget _statCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color.withOpacity(0.8),
                  ),
                ),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: color.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
