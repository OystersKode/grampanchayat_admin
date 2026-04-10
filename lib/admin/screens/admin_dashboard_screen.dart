import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'manage_announcements_screen.dart';
import 'manage_news_screen.dart';
import 'create_wishes_screen.dart';
import 'admin_login_screen.dart';
import 'member_requests_screen.dart';
import 'manage_vehicles_screen.dart';
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
    _refreshStats();
  }

  void _refreshStats() {
    setState(() {
      _statsFuture = _fetchDashboardStats();
    });
  }

  Future<Map<String, dynamic>> _fetchDashboardStats() async {
    try {
      final usersQuery = await _db.collection('guest_users').get();
      final newsQuery = await _db.collection('news').get();
      final announcementsQuery = await _db.collection('announcements').get();
      final pendingRequestsQuery = await _db.collection('member_requests')
          .where('status', isEqualTo: 'pending')
          .get();
      final vehiclesQuery = await _db.collection('vehicles').get();

      return {
        'total_users': usersQuery.size,
        'total_news': newsQuery.size,
        'total_announcements': announcementsQuery.size,
        'pending_requests': pendingRequestsQuery.size,
        'total_vehicles': vehiclesQuery.size,
      };
    } catch (e) {
      debugPrint('Error fetching stats: $e');
      return {
        'total_users': 0,
        'total_news': 0,
        'total_announcements': 0,
        'pending_requests': 0,
        'total_vehicles': 0,
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
          'Kagwad Admin',
          style: TextStyle(
            color: primaryMaroon,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: primaryMaroon),
            onPressed: _refreshStats,
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
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
                  padding: const EdgeInsets.all(20),
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
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          color: primaryMaroon,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: const Color(0xFFD9A5A5),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(height: 30),
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
                          return GridView.count(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisCount: 2,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                            childAspectRatio: 2.3, 
                            children: [
                              _statCard('Total Users', '${data['total_users'] ?? 0}', Icons.people_outline),
                              _statCard('News', '${data['total_news'] ?? 0}', Icons.newspaper),
                              _statCard('Vehicles', '${data['total_vehicles'] ?? 0}', Icons.directions_car),
                              _statCard('Announce.', '${data['total_announcements'] ?? 0}', Icons.campaign),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 24),
                      _buildDashboardItem(
                        context,
                        title: 'Village News',
                        subtitle: 'Create and manage general news articles',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const ManageNewsScreen()),
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildDashboardItem(
                        context,
                        title: 'Official Announcements',
                        subtitle: 'Post official alerts and government notices',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const ManageAnnouncementsScreen()),
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildDashboardItem(
                        context,
                        title: 'Member Requests',
                        subtitle: 'Review and approve membership requests',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const MemberRequestsScreen()),
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildDashboardItem(
                        context,
                        title: 'Create Wishes',
                        subtitle: 'Post wishes, events, and achievements',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const CreateWishesScreen()),
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildDashboardItem(
                        context,
                        title: 'Manage Vehicles',
                        subtitle: 'Add/Edit/Delete vehicle and driver details',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const ManageVehiclesScreen()),
                        ),
                      ),
                      const SizedBox(height: 32),
                      const Divider(color: Color(0xFFF1F1F1)),
                      const SizedBox(height: 8),
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
                const SizedBox(height: 20),
                const Text(
                  'MANAGE VILLAGE CONTENT EFFICIENTLY',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                    color: Color(0xFFB09491),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: primaryMaroon,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 11,
                    color: textColor.withOpacity(0.8),
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: onTap,
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryMaroon,
              foregroundColor: Colors.white,
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            child: const Text(
              'Open',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statCard(String label, String value, IconData icon) {
    const Color color = Color(0xFF5A403C);
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                  maxLines: 1,
                ),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: color.withOpacity(0.7),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
