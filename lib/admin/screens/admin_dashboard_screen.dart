import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'create_news_screen.dart';
import 'create_wishes_screen.dart';
import 'admin_login_screen.dart';
import 'member_requests_screen.dart';
import '../widgets/admin_drawer.dart';
import '../services/auth_service.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  late Future<Map<String, dynamic>> _statsFuture;

  @override
  void initState() {
    super.initState();
    _statsFuture = AuthService.instance.getDashboardStats();
  }

  Future<void> _logout() async {
    await AuthService.instance.logout();
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
        leading: const Padding(
          padding: EdgeInsets.only(left: 16.0),
          child: Icon(Icons.account_balance, color: primaryMaroon),
        ),
        title: const Text(
          'Grampanchayat Portal',
          style: TextStyle(
            color: primaryMaroon,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle, color: primaryMaroon),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
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
                            padding: EdgeInsets.only(bottom: 16),
                            child: LinearProgressIndicator(),
                          );
                        }
                        final Map<String, dynamic> data = snapshot.data ?? <String, dynamic>{};
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 20),
                          child: Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _chip('Users: ${data['total_users'] ?? 0}'),
                              _chip('News: ${data['total_news'] ?? 0}'),
                              _chip('Likes: ${data['total_likes'] ?? 0}'),
                              _chip('Pending: ${data['pending_requests'] ?? 0}'),
                            ],
                          ),
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
                    _buildLikesChart(),
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
              const SizedBox(height: 64),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.account_balance, size: 12, color: textColor.withOpacity(0.5)),
                  const SizedBox(width: 4),
                  Text(
                    'Grampanchayat Administrative Hub',
                    style: TextStyle(
                      fontSize: 12,
                      color: textColor.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                '© 2026 DEPARTMENT OF PANCHAYATI RAJ',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: textColor.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _footerLink('SECURITY PROTOCOL'),
                  const SizedBox(width: 16),
                  _footerLink('PRIVACY POLICY'),
                  const SizedBox(width: 16),
                  _footerLink('SYSTEM STATUS'),
                ],
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLikesChart() {
    const Color primaryMaroon = Color(0xFF8B0000);
    return FutureBuilder<Map<String, dynamic>>(
      future: _statsFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox.shrink();
        
        final List<dynamic> likesPerCategory = snapshot.data!['likes_per_category'] ?? [];
        if (likesPerCategory.isEmpty) return const Center(child: Text("No likes data available"));

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'LIKES PER CATEGORY',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: _getMaxY(likesPerCategory),
                  barTouchData: BarTouchData(enabled: false),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          int index = value.toInt();
                          if (index >= 0 && index < likesPerCategory.length) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                likesPerCategory[index]['category'].toString().substring(0, 3).toUpperCase(),
                                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                              ),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  gridData: const FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  barGroups: likesPerCategory.asMap().entries.map((entry) {
                    return BarChartGroupData(
                      x: entry.key,
                      barRods: [
                        BarChartRodData(
                          toY: (entry.value['likes'] as num).toDouble(),
                          color: primaryMaroon,
                          width: 16,
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  double _getMaxY(List<dynamic> data) {
    double max = 5;
    for (var item in data) {
      if ((item['likes'] as num).toDouble() > max) {
        max = (item['likes'] as num).toDouble();
      }
    }
    return max + 2;
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

  Widget _chip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFFBE7E7),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(text),
    );
  }
}
