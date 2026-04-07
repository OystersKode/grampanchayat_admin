import 'package:flutter/material.dart';
import '../services/member_requests_service.dart';

class MemberRequestDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> request;

  const MemberRequestDetailsScreen({super.key, required this.request});

  @override
  State<MemberRequestDetailsScreen> createState() => _MemberRequestDetailsScreenState();
}

class _MemberRequestDetailsScreenState extends State<MemberRequestDetailsScreen> {
  bool _isProcessing = false;

  Future<void> _handleStatusUpdate(String status) async {
    final String id = widget.request['id'].toString();

    setState(() => _isProcessing = true);

    try {
      await MemberRequestsService.instance.updateStatus(id: id, status: status);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Application $status successfully'),
            backgroundColor: status == 'approved' ? Colors.green : Colors.red,
          ),
        );
        Navigator.pop(context, true); // Return true to trigger refresh
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryMaroon = Color(0xFF8B0000);
    final String status = (widget.request['status'] ?? 'pending').toString().toLowerCase();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Application Details'),
        backgroundColor: Colors.white,
        foregroundColor: primaryMaroon,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: CircleAvatar(
                radius: 50,
                backgroundColor: primaryMaroon.withOpacity(0.1),
                child: const Icon(Icons.person, size: 50, color: primaryMaroon),
              ),
            ),
            const SizedBox(height: 24),
            _buildSectionTitle('PERSONAL INFORMATION'),
            _buildDetailTile(Icons.badge, 'Full Name', widget.request['name']),
            _buildDetailTile(Icons.phone, 'Mobile Number', widget.request['mobile_number']),
            _buildDetailTile(Icons.home, 'Address', widget.request['address']),
            _buildDetailTile(Icons.info_outline, 'Current Status', status.toUpperCase(), 
                valueColor: _getStatusColor(status)),
            
            const SizedBox(height: 32),
            if (status == 'pending') ...[
              const Divider(),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isProcessing ? null : () => _handleStatusUpdate('rejected'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('REJECT', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isProcessing ? null : () => _handleStatusUpdate('approved'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: _isProcessing 
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text('APPROVE', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, top: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget _buildDetailTile(IconData icon, String label, String? value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: const Color(0xFF8B0000).withOpacity(0.7)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 4),
                Text(
                  value ?? 'N/A',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: valueColor ?? const Color(0xFF5A403C),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'approved': return Colors.green;
      case 'rejected': return Colors.red;
      default: return Colors.orange;
    }
  }
}
