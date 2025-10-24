import 'package:flutter/material.dart';
import 'package:intl/intl.dart';


class LatestUpdatesScreen extends StatefulWidget {
  const LatestUpdatesScreen({super.key});

  @override
  State<LatestUpdatesScreen> createState() => _LatestUpdatesScreenState();
}

class _LatestUpdatesScreenState extends State<LatestUpdatesScreen> {
  final List<String> categories = [
    'All',
    'Announcements',
    'Results',
    'Guidelines',
  ];
  String selectedCategory = 'All';
  bool showBreakingNews = true;
  final List<Update> updates = [];
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadInitialUpdates();
  }

  void _loadInitialUpdates() {
    updates.addAll([
      Update(
        id: '1',
        title: 'Voter Registration Deadline Extended',
        description:
            'The election commission has extended voter registration until Friday.',
        timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
        category: 'Announcements',
        urgent: true,
      ),
      Update(
        id: '2',
        title: 'Preliminary Results for District 5',
        description: 'Initial counts show a close race between candidates.',
        timestamp: DateTime.now().subtract(const Duration(minutes: 25)),
        category: 'Results',
        imageUrl: 'assets/results.jpg',
      ),
      Update(
        id: '3',
        title: 'New Voting Guidelines Issued',
        description:
            'Updated safety protocols for polling stations have been released.',
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        category: 'Guidelines',
        imageUrl: 'assets/guidelines.jpg',
      ),
      Update(
        id: '4',
        title: 'Polling Station Changes',
        description:
            'Three polling stations have been relocated due to construction.',
        timestamp: DateTime.now().subtract(const Duration(hours: 5)),
        category: 'Announcements',
      ),
      Update(
        id: '5',
        title: 'Final Election Results Coming Soon',
        description: 'The final tally will be announced tomorrow morning.',
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
        category: 'Results',
        urgent: true,
      ),
    ]);
  }

  Future<void> _refreshUpdates() async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      // Add new update at the top
      updates.insert(
        0,
        Update(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: 'Live Update: ${DateTime.now().hour}:${DateTime.now().minute}',
          description:
              'New information just arrived from the election commission',
          timestamp: DateTime.now(),
          category: 'Announcements',
        ),
      );
    });
  }

  List<Update> get _filteredUpdates {
    if (selectedCategory == 'All') return updates;
    return updates
        .where((update) => update.category == selectedCategory)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 900;
    final isTablet = MediaQuery.of(context).size.width >= 600;
    final columnCount = isDesktop ? 3 : (isTablet ? 2 : 1);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Latest Updates'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshUpdates,
            tooltip: 'Refresh updates',
          ),
        ],
      ),
      body: Column(
        children: [
          // Breaking News Banner
          if (showBreakingNews)
            _BreakingNewsBanner(
              text:
                  'URGENT: Final voter turnout reaches 78%, highest in 20 years',
              onClose: () => setState(() => showBreakingNews = false),
            ),

          // Main Content
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Sidebar (for desktop)
                if (isDesktop)
                  _CategorySidebar(
                    categories: categories,
                    selectedCategory: selectedCategory,
                    onCategorySelected: (category) {
                      setState(() => selectedCategory = category);
                    },
                  ),

                // Updates List/Grid
                Expanded(
                  child: isDesktop || isTablet
                      ? _buildUpdatesGrid(columnCount)
                      : _buildMobileUpdatesList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileUpdatesList() {
    return Column(
      children: [
        // Category Chips (mobile)
        _CategoryChips(
          categories: categories,
          selectedCategory: selectedCategory,
          onCategorySelected: (category) {
            setState(() => selectedCategory = category);
          },
        ),

        // Updates List
        Expanded(
          child: RefreshIndicator(
            onRefresh: _refreshUpdates,
            child: ListView.builder(
              controller: _scrollController,
              itemCount: _filteredUpdates.length,
              itemBuilder: (context, index) {
                return _UpdateItem(
                  update: _filteredUpdates[index],
                  isMobile: true,
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUpdatesGrid(int columnCount) {
    return RefreshIndicator(
      onRefresh: _refreshUpdates,
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: columnCount,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.8,
        ),
        itemCount: _filteredUpdates.length,
        itemBuilder: (context, index) {
          return _UpdateItem(update: _filteredUpdates[index], isMobile: false);
        },
      ),
    );
  }
}

// Models
class Update {
  final String id;
  final String title;
  final String description;
  final DateTime timestamp;
  final String category;
  final bool urgent;
  final String? imageUrl;

  Update({
    required this.id,
    required this.title,
    required this.description,
    required this.timestamp,
    required this.category,
    this.urgent = false,
    this.imageUrl,
  });
}

// Widgets
class _BreakingNewsBanner extends StatelessWidget {
  final String text;
  final VoidCallback onClose;

  const _BreakingNewsBanner({required this.text, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.red[800]!, Colors.orange[700]!],
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber, color: Colors.white),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: onClose,
          ),
        ],
      ),
    );
  }
}

class _CategorySidebar extends StatelessWidget {
  final List<String> categories;
  final String selectedCategory;
  final Function(String) onCategorySelected;

  const _CategorySidebar({
    required this.categories,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 180,
      padding: const EdgeInsets.only(top: 16),
      decoration: BoxDecoration(
        border: Border(right: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Column(  // FIXED: Moved Column to child parameter
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'Categories',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
          ...categories.map((category) {
            return ListTile(
              title: Text(category),
              selected: category == selectedCategory,
              selectedTileColor: Colors.blue[50],
              onTap: () => onCategorySelected(category),
            );
          }),
        ],
      ),
    );
  }
}

class _CategoryChips extends StatelessWidget {
  final List<String> categories;
  final String selectedCategory;
  final Function(String) onCategorySelected;

  const _CategoryChips({
    required this.categories,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        children: categories.map((category) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: ChoiceChip(
              label: Text(category),
              selected: category == selectedCategory,
              onSelected: (selected) => onCategorySelected(category),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _UpdateItem extends StatefulWidget {
  final Update update;
  final bool isMobile;

  const _UpdateItem({required this.update, required this.isMobile});

  @override
  State<_UpdateItem> createState() => _UpdateItemState();
}

class _UpdateItemState extends State<_UpdateItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final timeAgo = _formatTimeAgo(widget.update.timestamp);

    return FadeTransition(
      opacity: _animation,
      child: Card(
        margin: widget.isMobile
            ? const EdgeInsets.symmetric(horizontal: 16, vertical: 8)
            : const EdgeInsets.all(0),
        elevation: 1,
        child: InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with urgent badge
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (widget.update.urgent)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'URGENT',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    Expanded(
                      child: Text(
                        widget.update.title,
                        style: Theme.of(context).textTheme.titleLarge,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // Optional thumbnail with error handling
                if (widget.update.imageUrl != null)
                  ...[
                    if (!widget.isMobile)
                      AspectRatio(
                        aspectRatio: 16 / 9,
                        child: _buildImage(),
                      )
                    else
                      SizedBox(
                        height: 150,
                        width: double.infinity,
                        child: _buildImage(),
                      ),
                    const SizedBox(height: 8),
                  ],

                // Description
                Text(
                  widget.update.description,
                  style: Theme.of(context).textTheme.bodyMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                const Spacer(),

                // Timestamp
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      timeAgo,
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                    Text(
                      widget.update.category,
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImage() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: Image.asset(
        widget.update.imageUrl!,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          color: Colors.grey[200],
          child: const Center(
            child: Icon(Icons.broken_image, color: Colors.grey),
          ),
        ),
      ),
    );
  }

  String _formatTimeAgo(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) return 'Just now';
    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'} ago';
    }
    if (difference.inHours < 24) {
      return '${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} ago';
    }
    if (difference.inDays < 7) {
      return '${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'} ago';
    }
    return DateFormat.yMMMd().format(timestamp); // Fixed date format
  }
}