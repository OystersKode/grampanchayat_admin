import 'package:flutter/material.dart';

import '../services/member_requests_service.dart';
import '../widgets/admin_drawer.dart';
import 'member_request_details_screen.dart';

class MemberRequestsScreen extends StatefulWidget {
  const MemberRequestsScreen({super.key});

  @override
  State<MemberRequestsScreen> createState() => _MemberRequestsScreenState();
}

class _MemberRequestsScreenState extends State<MemberRequestsScreen> {
  late Future<List<Map<String, dynamic>>> _requestsFuture;

  @override
  void initState() {
    super.initState();
    _requestsFuture = MemberRequestsService.instance.fetchRequests();
  }

  void _refreshRequests() {
    setState(() {
      _requestsFuture = MemberRequestsService.instance.fetchRequests();
    });
  }

  Future<void> _navigateToDetails(Map<String, dynamic> request) async {
    final bool? updated = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MemberRequestDetailsScreen(request: request),
      ),
    );
    if (updated == true) {
      _refreshRequests();
    }
  }

  Future<void> _deleteRequest(String id) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text('Are you sure you want to delete this member request?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await MemberRequestsService.instance.deleteRequest(id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Request deleted successfully')),
          );
          _refreshRequests();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to delete: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryMaroon = Color(0xFF8B0000);
    return Scaffold(
      drawer: const AdminDrawer(),
      appBar: AppBar(
        title: const Text('Member Requests'),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _requestsFuture,
        builder: (BuildContext context, AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text('Unable to load requests: ${snapshot.error}'),
            );
          }

          final List<Map<String, dynamic>> rows = snapshot.data ?? <Map<String, dynamic>>[];
          if (rows.isEmpty) {
            return const Center(child: Text('No pending requests'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: rows.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (BuildContext context, int index) {
              final Map<String, dynamic> row = rows[index];
              final String id = row['id'].toString();
              final String name = '${row['name'] ?? '-'}';
              final String phone = '${row['mobile_number'] ?? '-'}';
              final String address = '${row['address'] ?? '-'}';
              final String status = '${row['status'] ?? 'pending'}';

              return Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.grey.withOpacity(0.2)),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: CircleAvatar(
                    backgroundColor: primaryMaroon.withOpacity(0.1),
                    child: const Icon(Icons.person, color: primaryMaroon),
                  ),
                  title: Text(
                    name,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text('Phone: $phone'),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Text('Status: '),
                          Text(
                            status.toUpperCase(),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: status.toLowerCase() == 'pending' 
                                ? Colors.orange 
                                : (status.toLowerCase() == 'approved' ? Colors.green : Colors.red),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.red),
                        onPressed: () => _deleteRequest(id),
                      ),
                      const Icon(Icons.chevron_right),
                    ],
                  ),
                  onTap: () => _navigateToDetails(row),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
