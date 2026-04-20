import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

import '../helpers/database_helper.dart';
import '../services/user_skills_service.dart';
import 'service_details_screen.dart';

class ServiceProviderData {
  final String id;
  final String providerName;
  final String title;
  final String location;
  final String serviceType;
  final double rating;
  final String phone;
  final String priceLabel;
  final bool verified;
  final bool availableToday;
  final IconData icon;
  final List<String> workHistory;

  const ServiceProviderData({
    required this.id,
    required this.providerName,
    required this.title,
    required this.location,
    required this.serviceType,
    required this.rating,
    required this.phone,
    required this.priceLabel,
    required this.verified,
    required this.availableToday,
    required this.icon,
    required this.workHistory,
  });
}

class DailyWageScreen extends StatefulWidget {
  const DailyWageScreen({super.key});

  @override
  State<DailyWageScreen> createState() => _DailyWageScreenState();
}

class _DailyWageScreenState extends State<DailyWageScreen> {
  bool _isGridView = false;
  String _selectedCategory = 'All';
  String _searchQuery = '';
  String _sortBy = 'rating';

  final List<ServiceProviderData> _providers = const [
    ServiceProviderData(
      id: 'srv-1',
      providerName: 'Rahul Barber Studio',
      title: 'Barber',
      location: 'Sector 62, Noida',
      serviceType: 'Barber',
      rating: 4.8,
      phone: '+91 98765 11223',
      priceLabel: '?299 / visit',
      verified: true,
      availableToday: true,
      icon: Icons.content_cut,
      workHistory: ['Men\'s haircut', 'Beard trim', 'Home grooming package'],
    ),
    ServiceProviderData(
      id: 'srv-2',
      providerName: 'A1 Electric Works',
      title: 'Electrician',
      location: 'Indiranagar, Bengaluru',
      serviceType: 'Electrician',
      rating: 4.6,
      phone: '+91 99881 23100',
      priceLabel: '?700 / job',
      verified: true,
      availableToday: true,
      icon: Icons.electrical_services,
      workHistory: [
        'Fan repair',
        'Smart switch installation',
        'Wiring diagnostics',
      ],
    ),
    ServiceProviderData(
      id: 'srv-3',
      providerName: 'QuickFlow Plumbing',
      title: 'Plumber',
      location: 'Hinjewadi, Pune',
      serviceType: 'Plumber',
      rating: 4.5,
      phone: '+91 90111 66778',
      priceLabel: '?650 / job',
      verified: false,
      availableToday: true,
      icon: Icons.plumbing,
      workHistory: [
        'Leaky sink repair',
        'Toilet fitting',
        'Kitchen line cleanup',
      ],
    ),
    ServiceProviderData(
      id: 'srv-4',
      providerName: 'BuildRight Carpentry',
      title: 'Carpenter',
      location: 'Andheri, Mumbai',
      serviceType: 'Carpenter',
      rating: 4.7,
      phone: '+91 97654 44332',
      priceLabel: '?900 / job',
      verified: true,
      availableToday: false,
      icon: Icons.handyman,
      workHistory: [
        'Wardrobe repair',
        'Door lock fitting',
        'Wood shelf installation',
      ],
    ),
    ServiceProviderData(
      id: 'srv-5',
      providerName: 'SafeHome Cleaners',
      title: 'Home Cleaning',
      location: 'Dwarka, Delhi',
      serviceType: 'Cleaning',
      rating: 4.3,
      phone: '+91 91234 55577',
      priceLabel: '?1200 / session',
      verified: true,
      availableToday: true,
      icon: Icons.cleaning_services,
      workHistory: [
        'Deep kitchen cleaning',
        'Bathroom sanitization',
        'Move-out cleanup',
      ],
    ),
    ServiceProviderData(
      id: 'srv-6',
      providerName: 'PaintPro Crew',
      title: 'Painter',
      location: 'Alkapuri, Vadodara',
      serviceType: 'Painter',
      rating: 4.4,
      phone: '+91 93221 99881',
      priceLabel: '?800 / day',
      verified: false,
      availableToday: false,
      icon: Icons.format_paint,
      workHistory: [
        'Room painting',
        'Texture wall touch-up',
        'Exterior repaint',
      ],
    ),
  ];

  List<String> get _categories {
    final categories = _providers
        .map((provider) => provider.serviceType)
        .toSet()
        .toList();
    categories.sort();
    return ['All', ...categories];
  }

  List<ServiceProviderData> get _filteredProviders {
    Iterable<ServiceProviderData> data = _providers;

    if (_selectedCategory != 'All') {
      data = data.where(
        (provider) => provider.serviceType == _selectedCategory,
      );
    }

    if (_searchQuery.trim().isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      data = data.where((provider) {
        return provider.title.toLowerCase().contains(query) ||
            provider.providerName.toLowerCase().contains(query) ||
            provider.location.toLowerCase().contains(query);
      });
    }

    final list = data.toList();
    if (_sortBy == 'price') {
      list.sort(
        (a, b) => _extractNumericPrice(
          a.priceLabel,
        ).compareTo(_extractNumericPrice(b.priceLabel)),
      );
    } else {
      list.sort((a, b) => b.rating.compareTo(a.rating));
    }

    return list;
  }

  int _extractNumericPrice(String priceLabel) {
    final digitsOnly = priceLabel.replaceAll(RegExp(r'[^0-9]'), '');
    return int.tryParse(digitsOnly) ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.pushNamed(context, '/post_job');
          },
          backgroundColor: Colors.blue,
          child: const Icon(Icons.add, color: Colors.white),
          tooltip: 'Post a Job',
        ),
        body: Column(
          children: [
            _buildSearchAndActions(),
            _buildCategoryFilters(),
            Container(
              color: Colors.white,
              child: const TabBar(
                tabs: [
                  Tab(text: 'Find Services'),
                  Tab(text: 'Find Job Postings'),
                ],
                labelColor: Colors.blue,
                unselectedLabelColor: Colors.grey,
                indicatorColor: Colors.blue,
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [_buildServicesTab(), _buildCustomerJobsTab()],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchAndActions() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Search providers, service, location...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              IconButton(
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                icon: Icon(
                  _isGridView ? Icons.view_list : Icons.grid_view,
                  color: Colors.blue,
                ),
                tooltip: _isGridView ? 'List view' : 'Grid view',
                onPressed: () {
                  setState(() {
                    _isGridView = !_isGridView;
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Text(
                'Sort by:',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(width: 8),
              DropdownButton<String>(
                value: _sortBy,
                items: const [
                  DropdownMenuItem(value: 'rating', child: Text('Top Rated')),
                  DropdownMenuItem(value: 'price', child: Text('Lowest Price')),
                ],
                onChanged: (value) {
                  if (value == null) return;
                  setState(() {
                    _sortBy = value;
                  });
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilters() {
    return SizedBox(
      height: 46,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = category == _selectedCategory;
          return ChoiceChip(
            label: Text(category),
            selected: isSelected,
            onSelected: (_) {
              setState(() {
                _selectedCategory = category;
              });
            },
          );
        },
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemCount: _categories.length,
      ),
    );
  }

  Widget _buildServicesTab() {
    final providers = _filteredProviders;

    if (providers.isEmpty) {
      return const Center(child: Text('No providers match your filters'));
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final wideScreen = constraints.maxWidth >= 780;
        final useGrid = _isGridView || wideScreen;

        if (!useGrid) {
          return RefreshIndicator(
            onRefresh: () async {
              await Future.delayed(const Duration(milliseconds: 300));
            },
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              itemCount: providers.length,
              itemBuilder: (context, index) =>
                  _buildProviderCard(providers[index]),
            ),
          );
        }

        int crossAxisCount = 2;
        if (constraints.maxWidth >= 1200) {
          crossAxisCount = 4;
        } else if (constraints.maxWidth >= 950) {
          crossAxisCount = 3;
        }

        return RefreshIndicator(
          onRefresh: () async {
            await Future.delayed(const Duration(milliseconds: 300));
          },
          child: GridView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            itemCount: providers.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.75,
            ),
            itemBuilder: (context, index) =>
                _buildProviderCard(providers[index]),
          ),
        );
      },
    );
  }

  Widget _buildProviderCard(ServiceProviderData provider) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _openServiceDetails(provider),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(provider.icon, size: 28, color: Colors.blue),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      provider.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (provider.verified)
                    const Icon(Icons.verified, color: Colors.green, size: 16),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                provider.providerName,
                style: TextStyle(color: Colors.grey[700], fontSize: 11),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  const Icon(Icons.location_on, size: 12, color: Colors.grey),
                  const SizedBox(width: 3),
                  Expanded(
                    child: Text(
                      provider.location,
                      style: TextStyle(color: Colors.grey[700], fontSize: 10),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              RatingBarIndicator(
                rating: provider.rating,
                itemBuilder: (context, _) =>
                    const Icon(Icons.star, color: Colors.amber),
                itemCount: 5,
                itemSize: 14,
              ),
              const SizedBox(height: 2),
              Text(
                '${provider.rating.toStringAsFixed(1)} · ${provider.priceLabel}',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 11,
                ),
              ),
              const SizedBox(height: 4),
              SizedBox(
                height: 24,
                child: Chip(
                  visualDensity: VisualDensity.compact,
                  label: Text(
                    provider.availableToday
                        ? 'Available today'
                        : 'Next slot tomorrow',
                    style: const TextStyle(fontSize: 10),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _showContactOptions(provider),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        visualDensity: VisualDensity.compact,
                      ),
                      child: const Text(
                        'Contact',
                        style: TextStyle(fontSize: 11),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        visualDensity: VisualDensity.compact,
                      ),
                      onPressed: () => _openServiceDetails(provider),
                      child: const Text(
                        'Details',
                        style: TextStyle(color: Colors.white, fontSize: 11),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showContactOptions(ServiceProviderData provider) {
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
                provider.providerName,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(provider.phone, style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 14),
              ListTile(
                leading: const Icon(Icons.call, color: Colors.green),
                title: const Text('Call Provider'),
                onTap: () {
                  Navigator.pop(context);
                  _showActionMessage('Calling ${provider.phone}...');
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.chat_bubble_outline,
                  color: Colors.blue,
                ),
                title: const Text('Start Chat'),
                onTap: () {
                  Navigator.pop(context);
                  _showActionMessage(
                    'Opening chat with ${provider.providerName}...',
                  );
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.calendar_month,
                  color: Colors.deepPurple,
                ),
                title: const Text('Request Booking Slot'),
                onTap: () {
                  Navigator.pop(context);
                  _showActionMessage(
                    'Booking request sent to ${provider.providerName}.',
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showActionMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _openServiceDetails(ServiceProviderData provider) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ServiceDetailsScreen(
          title: provider.title,
          icon: provider.icon,
          rating: provider.rating,
          workHistory: provider.workHistory,
          providerName: provider.providerName,
          phoneNumber: provider.phone,
          serviceArea: provider.location,
          priceLabel: provider.priceLabel,
          verified: provider.verified,
        ),
      ),
    );
  }

  Widget _buildCustomerJobsTab() {
    return FutureBuilder<List<AdminPost>>(
      future: DatabaseHelper.instance.getPostsByType('daily_wage'),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No daily wage jobs available'));
        }

        final posts = snapshot.data!;

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: posts.length,
          itemBuilder: (context, index) {
            final post = posts[index];
            return _buildCustomerJobCard(
              title: post.role,
              location: post.location,
              time: post.company,
              skill: post.role,
            );
          },
        );
      },
    );
  }

  Widget _buildCustomerJobCard({
    required String title,
    required String location,
    required String time,
    required String skill,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.only(bottom: 12.0),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.location_on, size: 16),
                const SizedBox(width: 4),
                Text(location),
              ],
            ),
            const SizedBox(height: 4),
            Text('Company: $time'),
            const SizedBox(height: 10),
            SizedBox(
              width: 220,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[50],
                  elevation: 0,
                ),
                onPressed: () async {
                  try {
                    await UserSkillsService.instance.addSkill(skill);
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Job completed! "$skill" added to profile',
                        ),
                      ),
                    );
                  } catch (_) {
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Failed to save skill to your profile'),
                      ),
                    );
                  }
                },
                child: const Text(
                  'Mark as Complete',
                  style: TextStyle(color: Colors.green),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
