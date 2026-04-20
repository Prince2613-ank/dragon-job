import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class ServiceDetailsScreen extends StatelessWidget {
  final String title;
  final IconData icon;
  final double rating;
  final List<String> workHistory;
  final String providerName;
  final String phoneNumber;
  final String serviceArea;
  final String priceLabel;
  final bool verified;

  const ServiceDetailsScreen({
    super.key,
    required this.title,
    required this.icon,
    required this.rating,
    required this.workHistory,
    required this.providerName,
    required this.phoneNumber,
    required this.serviceArea,
    required this.priceLabel,
    required this.verified,
  });

  void _showAction(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  void _showBookingSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Book $title',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: ['Today 4 PM', 'Today 6 PM', 'Tomorrow 10 AM', 'Tomorrow 2 PM']
                    .map(
                      (slot) => ActionChip(
                        label: Text(slot),
                        onPressed: () {
                          Navigator.pop(context);
                          _showAction(context, 'Booking requested for $slot');
                        },
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 12),
              Text(
                'Provider will confirm availability on call/chat.',
                style: TextStyle(color: Colors.grey[700]),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoCard({required IconData iconData, required String label, required String value}) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(iconData, color: Colors.blue),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                  Text(
                    value,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title, style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 900;

          final profileSection = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 34,
                        backgroundColor: Colors.blue.withOpacity(0.1),
                        child: Icon(icon, size: 34, color: Colors.blue),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    providerName,
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                if (verified)
                                  const Icon(Icons.verified, color: Colors.green),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(title, style: TextStyle(color: Colors.grey[700])),
                            const SizedBox(height: 8),
                            RatingBarIndicator(
                              rating: rating,
                              itemBuilder: (context, _) =>
                                  const Icon(Icons.star, color: Colors.amber),
                              itemCount: 5,
                              itemSize: 18,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _buildInfoCard(iconData: Icons.call, label: 'Phone', value: phoneNumber),
              _buildInfoCard(iconData: Icons.location_on, label: 'Service Area', value: serviceArea),
              _buildInfoCard(iconData: Icons.currency_rupee, label: 'Pricing', value: priceLabel),
              _buildInfoCard(iconData: Icons.schedule, label: 'Response Time', value: 'Usually within 15 mins'),
            ],
          );

          final historySection = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Recent Work History',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              ...workHistory.map((jobTitle) {
                return Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(color: Colors.grey[300]!),
                  ),
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: const Icon(Icons.check_circle, color: Colors.green),
                    title: Text(jobTitle),
                    subtitle: const Text('Completed successfully'),
                  ),
                );
              }),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _showAction(context, 'Calling $phoneNumber...'),
                      icon: const Icon(Icons.call, color: Colors.green),
                      label: const Text('Call'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _showAction(context, 'Opening chat with $providerName...'),
                      icon: const Icon(Icons.chat_bubble_outline, color: Colors.blue),
                      label: const Text('Chat'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _showAction(context, 'Quote request sent to $providerName'),
                  icon: const Icon(Icons.request_quote, color: Colors.deepPurple),
                  label: const Text('Request Quote'),
                ),
              ),
            ],
          );

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: isWide
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: profileSection),
                            const SizedBox(width: 16),
                            Expanded(child: historySection),
                          ],
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            profileSection,
                            const SizedBox(height: 16),
                            historySection,
                          ],
                        ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 10,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () => _showBookingSheet(context),
                    icon: const Icon(Icons.calendar_month, color: Colors.white),
                    label: const Text(
                      'Book Service',
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
