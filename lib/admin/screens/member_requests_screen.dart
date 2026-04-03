import 'package:flutter/material.dart';

import '../services/member_requests_service.dart';

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

  Future<void> _updateStatus(int id, String status) async {
    try {
      await MemberRequestsService.instance.updateStatus(id: id, status: status);
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Request marked as $status')),
      );
      setState(() {
        _requestsFuture = MemberRequestsService.instance.fetchRequests();
      });
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Update failed: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Member Requests')),
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
              final int id = (row['id'] is int)
                  ? row['id'] as int
                  : int.tryParse('${row['id']}') ?? 0;
              final String name = '${row['name'] ?? '-'}';
              final String phone = '${row['mobile_number'] ?? '-'}';
              final String address = '${row['address'] ?? '-'}';
              final String status = '${row['status'] ?? 'pending'}';

              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text('Phone: $phone'),
                      Text('Address: $address'),
                      Text('Status: $status'),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          ElevatedButton(
                            onPressed: id == 0 ? null : () => _updateStatus(id, 'approved'),
                            child: const Text('Approve'),
                          ),
                          const SizedBox(width: 8),
                          OutlinedButton(
                            onPressed: id == 0 ? null : () => _updateStatus(id, 'rejected'),
                            child: const Text('Reject'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
