import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';


class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Color?> _gradientAnimation;
  final TextEditingController _searchController = TextEditingController();
  List<MenuItem> _filteredMenuItems = [];
  final int _notificationCount = 3;

  final List<MenuItem> _menuItems = [
    MenuItem(
      title: 'Home',
      icon: Icons.home,
      color: const Color(0xFF6A1B9A),
    ),
    MenuItem(
      title: 'Voter Registration',
      icon: Icons.how_to_reg,
      color: const Color(0xFF1565C0),
    ),
    MenuItem(
      title: 'Voter Services',
      icon: Icons.people,
      color: const Color(0xFF00838F),
    ),
    MenuItem(
      title: 'Download e-EPIC',
      icon: Icons.download,
      color: const Color(0xFF2E7D32),
    ),
    MenuItem(
      title: 'Elections',
      icon: Icons.how_to_vote,
      color: const Color(0xFFEF6C00),
    ),
    MenuItem(
      title: 'Results',
      icon: Icons.bar_chart,
      color: const Color(0xFFC62828),
    ),
    MenuItem(
      title: 'Knowledge Base',
      icon: Icons.menu_book,
      color: const Color(0xFF4527A0),
    ),
    MenuItem(
      title: 'Latest Updates',
      icon: Icons.update,
      color: const Color(0xFF0277BD),
    ),
    MenuItem(
      title: 'Complaints',
      icon: Icons.report_problem,
      color: const Color(0xFFD84315),
    ),
    MenuItem(
      title: 'Settings',
      icon: Icons.settings,
      color: const Color(0xFF37474F),
    ),
    MenuItem(
      title: 'Profile',
      icon: Icons.person,
      color: const Color(0xFF5D4037),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _filteredMenuItems = _menuItems;
    
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat(reverse: true);
    
    _gradientAnimation = ColorTween(
      begin: const Color(0xFF4A148C),
      end: const Color(0xFF880E4F),
    ).animate(_animationController);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _filterMenuItems(String query) {
    setState(() {
      _filteredMenuItems = _menuItems.where((item) {
        return item.title.toLowerCase().contains(query.toLowerCase());
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 600;
    final isTablet = size.width >= 600 && size.width < 1200;
    final crossAxisCount = isMobile ? 2 : isTablet ? 3 : 4;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Menu',
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications, color: Colors.black),
                onPressed: () {},
              ),
              if (_notificationCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      '$_notificationCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  _gradientAnimation.value!,
                  const Color(0xFF2196F3),
                  const Color(0xFF64B5F6),
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
            child: child,
          );
        },
        child: Padding(
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + kToolbarHeight,
            left: isMobile ? 16 : 32,
            right: isMobile ? 16 : 32,
            bottom: 16,
          ),
          child: Column(
            children: [
              // User Profile Section
              _buildUserProfile(),
              
              const SizedBox(height: 20),
              
              // Search Bar
              _buildSearchBar(),
              
              const SizedBox(height: 20),
              
              // Menu Grid
              Expanded(
                child: _buildMenuGrid(crossAxisCount),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserProfile() {
    return Row(
      children: [
        Hero(
          tag: 'profile-picture',
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white,
                width: 2,
              ),
              image: const DecorationImage(
                image: NetworkImage('https://randomuser.me/api/portraits/men/1.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Good Morning,',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.black54,
              ),
            ),
            Text(
              'John Doe',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        color: Colors.white.withOpacity(0.8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: _filterMenuItems,
        decoration: InputDecoration(
          hintText: 'Search menu items...',
          hintStyle: GoogleFonts.poppins(
            color: Colors.black54,
          ),
          prefixIcon: const Icon(
            Icons.search,
            color: Colors.black54,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        ),
        style: GoogleFonts.poppins(
          color: Colors.black,
        ),
      ),
    );
  }

  Widget _buildMenuGrid(int crossAxisCount) {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
        childAspectRatio: 1.0,
      ),
      itemCount: _filteredMenuItems.length,
      itemBuilder: (context, index) {
        final item = _filteredMenuItems[index];
        return _buildMenuItemCard(item);
      },
    );
  }

  Widget _buildMenuItemCard(MenuItem item) {
    return Hero(
      tag: item.title,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            Navigator.push(
              context,
              PageRouteBuilder(
                transitionDuration: const Duration(milliseconds: 500),
                pageBuilder: (context, animation, secondaryAnimation) {
                  return FadeTransition(
                    opacity: animation,
                    child: MenuDetailPage(menuItem: item),
                  );
                },
              ),
            );
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Colors.white.withOpacity(0.7),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
              border: Border.all(
                color: Colors.white.withOpacity(0.5),
                width: 1,
              ),
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: constraints.maxWidth * 0.4,
                        height: constraints.maxWidth * 0.4,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              item.color.withOpacity(0.8),
                              item.color.withOpacity(0.4),
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: item.color.withOpacity(0.3),
                              blurRadius: 10,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Center(
                          child: Icon(
                            item.icon,
                            size: constraints.maxWidth * 0.25,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        item.title,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: constraints.maxWidth * 0.08,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class MenuItem {
  final String title;
  final IconData icon;
  final Color color;

  MenuItem({
    required this.title,
    required this.icon,
    required this.color,
  });
}

class MenuDetailPage extends StatelessWidget {
  final MenuItem menuItem;

  const MenuDetailPage({
    super.key,
    required this.menuItem,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              menuItem.color.withOpacity(0.2),
              Colors.white,
            ],
          ),
        ),
        child: Center(
          child: Hero(
            tag: menuItem.title,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        menuItem.color.withOpacity(0.8),
                        menuItem.color.withOpacity(0.4),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: menuItem.color.withOpacity(0.3),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Icon(
                      menuItem.icon,
                      size: 60,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  menuItem.title,
                  style: GoogleFonts.poppins(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'This is a placeholder page for ${menuItem.title}',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}