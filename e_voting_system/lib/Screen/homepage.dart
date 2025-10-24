import 'package:e_voting_system/ServicesScreen/CandidateScreen.dart';
import 'package:e_voting_system/ServicesScreen/ComplaintScreen.dart';
import 'package:e_voting_system/ServicesScreen/EPICScreen.dart';
import 'package:e_voting_system/ServicesScreen/ElectionResultScreen.dart';
import 'package:e_voting_system/ServicesScreen/ElectionScreen.dart';
import 'package:e_voting_system/ServicesScreen/FormScreen.dart';
import 'package:e_voting_system/ServicesScreen/GalleryScreen.dart';
import 'package:e_voting_system/ServicesScreen/KnowledgeBaseScreen.dart';
import 'package:e_voting_system/ServicesScreen/LatestUpdatesScreen.dart';
import 'package:e_voting_system/ServicesScreen/MenuScreen.dart';
import 'package:e_voting_system/ServicesScreen/VoterRegistrationScreen.dart';
import 'package:e_voting_system/ServicesScreen/VoterServicesScreen.dart' hide ElectionResultsScreen;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ElectionApp extends StatelessWidget {
  const ElectionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Voter Helpline',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.teal,
        colorScheme: ColorScheme.light(
          primary: const Color(0xFF008080),
          secondary: const Color(0xFFFFA000),
          surface: Colors.white,
          // ignore: deprecated_member_use
          background: const Color(0xFFF5F5F5),
        ),
        textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme),
        appBarTheme: AppBarTheme(
          backgroundColor: const Color(0xFF008080),
          elevation: 0,
          centerTitle: true,
          titleTextStyle: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          },
        ),
      ),
      home: const ElectionHomePage(),
    );
  }
}

class ElectionHomePage extends StatefulWidget {
  const ElectionHomePage({super.key});

  @override
  State<ElectionHomePage> createState() => _ElectionHomePageState();
}

class _ElectionHomePageState extends State<ElectionHomePage>
    with TickerProviderStateMixin {
  int _currentIndex = 0;
  late AnimationController _navController;

  final List<Widget> _bottomNavScreens = [
    const HomeScreen(),
    const ModernFormScreen(),
    const MenuScreen(),
    const GalleryScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _navController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _navController.forward();
  }

  @override
  void dispose() {
    _navController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 500),
        transitionBuilder: (Widget child, Animation<double> animation) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.2, 0),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            ),
          );
        },
        child: _bottomNavScreens[_currentIndex],
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black,
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
        gradient: const LinearGradient(
          colors: [Color(0xFF008080), Color(0xFF00695C)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
              _navController.reset();
              _navController.forward();
            });
          },
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white,
          selectedLabelStyle: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
          unselectedLabelStyle: GoogleFonts.poppins(
            fontWeight: FontWeight.w500,
            fontSize: 12,
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          items: [
            _buildNavItem(Icons.home_outlined, Icons.home, 'Home'),
            _buildNavItem(Icons.assignment_outlined, Icons.assignment, 'Forms'),
            _buildNavItem(Icons.menu_outlined, Icons.menu, 'Menu'),
            _buildNavItem(
              Icons.photo_library_outlined,
              Icons.photo_library,
              'Gallery',
            ),
          ],
        ),
      ),
    );
  }

  BottomNavigationBarItem _buildNavItem(
    IconData icon,
    IconData activeIcon,
    String label,
  ) {
    return BottomNavigationBarItem(
      icon: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (Widget child, Animation<double> animation) {
          return ScaleTransition(scale: animation, child: child);
        },
        child: Icon(icon, key: ValueKey('${label}_inactive')),
      ),
      activeIcon: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (Widget child, Animation<double> animation) {
          return ScaleTransition(scale: animation, child: child);
        },
        child: Icon(activeIcon, key: ValueKey('${label}_active')),
      ),
      label: label,
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  late AnimationController _marqueeController;
  bool _isBannerVisible = true;
  double _lastScrollPosition = 0;

  @override
  void initState() {
    super.initState();
    _marqueeController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();

    _scrollController.addListener(() {
      final currentScrollPosition = _scrollController.position.pixels;
      if (currentScrollPosition > _lastScrollPosition && !_isBannerVisible) {
        setState(() => _isBannerVisible = true);
      } else if (currentScrollPosition < _lastScrollPosition &&
          _isBannerVisible) {
        setState(() => _isBannerVisible = false);
      }
      _lastScrollPosition = currentScrollPosition;
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _marqueeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    final isDesktop = screenWidth > 900;

    return SafeArea(
      child: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverToBoxAdapter(child: _buildTopBar(isTablet, isDesktop)),
          SliverToBoxAdapter(child: _buildSearchBar(isTablet, isDesktop)),
          SliverToBoxAdapter(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: _isBannerVisible ? (isTablet ? 220 : 180) : 0,
              child: _isBannerVisible
                  ? _buildMarqueeBanner(isTablet, isDesktop)
                  : null,
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.symmetric(
              horizontal: isDesktop
                  ? 40
                  : isTablet
                  ? 30
                  : 20,
              vertical: 10,
            ),
            sliver: _buildGridTiles(isTablet, isDesktop),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar(bool isTablet, bool isDesktop) {
    return Container(
      height: isTablet ? 120 : 100,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF008080), Color(0xFF00695C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black,
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop
            ? 40
            : isTablet
            ? 30
            : 24,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Hero(
            tag: 'eci_logo',
            child: Material(
              color: Colors.transparent,
              child: Container(
                width: isTablet ? 60 : 50,
                height: isTablet ? 60 : 50,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.account_balance,
                  color: const Color(0xFF008080),
                  size: isTablet ? 36 : 30,
                ),
              ),
            ),
          ),
          SizedBox(width: isTablet ? 20 : 15),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Election Commission',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: isTablet ? 24 : 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                'of India',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: isTablet ? 20 : 16,
                ),
              ),
            ],
          ),
          const Spacer(),
          IconButton(
            icon: Icon(
              Icons.notifications,
              color: Colors.white,
              size: isTablet ? 32 : 28,
            ),
            onPressed: () {
              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      const NotificationScreen(),
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) {
                        return SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0, 1),
                            end: Offset.zero,
                          ).animate(animation),
                          child: child,
                        );
                      },
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(bool isTablet, bool isDesktop) {
    return Padding(
      padding: EdgeInsets.all(isTablet ? 24 : 20),
      child: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(30),
        shadowColor: const Color(0xFF008080),
        child: TextField(
          decoration: InputDecoration(
            hintText: 'Search Your Name in Electoral Roll',
            hintStyle: GoogleFonts.poppins(
              color: Colors.grey[600],
              fontSize: isTablet ? 16 : null,
            ),
            prefixIcon: Icon(
              Icons.search,
              color: const Color(0xFF008080),
              size: isTablet ? 30 : 26,
            ),
            suffixIcon: Padding(
              padding: const EdgeInsets.only(right: 8),
              child: IconButton(
                icon: Icon(
                  Icons.mic,
                  color: const Color(0xFF008080),
                  size: isTablet ? 30 : 26,
                ),
                onPressed: () {},
              ),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: EdgeInsets.symmetric(
              vertical: isTablet ? 18 : 0,
              horizontal: 20,
            ),
          ),
          style: GoogleFonts.poppins(),
        ),
      ),
    );
  }

  Widget _buildMarqueeBanner(bool isTablet, bool isDesktop) {
    const bannerText =
        'Main Bharat Hoon, Hum Bharat ke Matdata Hain • '
        'Register to Vote - Shape the Future of India • '
        'Your Vote is Your Voice - Exercise Your Right • ';

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: isDesktop
            ? 40
            : isTablet
            ? 30
            : 20,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
        image: const DecorationImage(
          image: AssetImage('assets/images/background1.jpg'),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            // ignore: deprecated_member_use
            Colors.black,
            BlendMode.darken,
          ),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            // Gradient overlay
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    // ignore: deprecated_member_use
                    Colors.black.withOpacity(0.3),
                    Colors.transparent,
                    Colors.transparent,
                    // ignore: deprecated_member_use
                    Colors.black.withOpacity(0.3),
                  ],
                ),
              ),
            ),
            // Marquee text
            Center(
              child: AnimatedBuilder(
                animation: _marqueeController,
                builder: (context, child) {
                  final value = _marqueeController.value;
                  return Transform.translate(
                    offset: Offset(-value * 500, 0),
                    child: Text(
                      bannerText * 3, // Repeat to ensure continuous text
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: isTablet ? 20 : 16,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.visible,
                      softWrap: false,
                    ),
                  );
                },
              ),
            ),
            // Clickable overlay
            Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () {
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) =>
                          const BannerInfoScreen(),
                      transitionsBuilder:
                          (context, animation, secondaryAnimation, child) {
                            return FadeTransition(
                              opacity: animation,
                              child: child,
                            );
                          },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGridTiles(bool isTablet, bool isDesktop) {
    final tiles = [
      _buildGridTile(
        title: 'Voter Registration',
        icon: Icons.how_to_reg,
        color: const Color(0xFFFF7043),
        screen:  VoterRegistrationScreen(),
        isTablet: isTablet,
        isDesktop: isDesktop,
      ),
      _buildGridTile(
        title: 'Voter Services',
        icon: Icons.people,
        color: const Color(0xFFAB47BC),
        screen: const VoterServicesScreen(),
        isTablet: isTablet,
        isDesktop: isDesktop,
      ),
      _buildGridTile(
        title: 'Download e-EPIC',
        icon: Icons.download,
        color: const Color(0xFF008080),
        screen: const EPICApp(),
        isTablet: isTablet,
        isDesktop: isDesktop,
      ),
      _buildGridTile(
        title: 'Elections',
        icon: Icons.how_to_vote,
        color: const Color(0xFF42A5F5),
        screen:  VotingScreen(),
        isTablet: isTablet,
        isDesktop: isDesktop,
      ),
      _buildGridTile(
        title: 'Candidate Info',
        icon: Icons.info,
        color: const Color(0xFF26C6DA),
        screen: const CandidateApp(),
        isTablet: isTablet,
        isDesktop: isDesktop,
      ),
      _buildGridTile(
        title: 'Election Results',
        icon: Icons.bar_chart,
        color: const Color(0xFF5C6BC0),
        screen: const ElectionResultsScreen(),
        isTablet: isTablet,
        isDesktop: isDesktop,
      ),
      _buildGridTile(
        title: 'Knowledge Base',
        icon: Icons.library_books,
        color: const Color(0xFF66BB6A),
        screen: const KnowledgeBaseScreen(),
        isTablet: isTablet,
        isDesktop: isDesktop,
      ),
      _buildGridTile(
        title: 'Latest Updates',
        icon: Icons.new_releases,
        color: const Color(0xFFFFA726),
        screen: const LatestUpdatesScreen(),
        isTablet: isTablet,
        isDesktop: isDesktop,
      ),
      _buildGridTile(
        title: 'Complaint',
        icon: Icons.feedback,
        color: const Color(0xFFEC407A),
        screen: const ComplaintScreen(),
        isTablet: isTablet,
        isDesktop: isDesktop,
      ),
    ];

    return SliverGrid(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isDesktop
            ? 4
            : isTablet
            ? 3
            : 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: isDesktop
            ? 1.2
            : isTablet
            ? 1.1
            : 0.9,
      ),
      delegate: SliverChildBuilderDelegate(
        (context, index) => tiles[index],
        childCount: tiles.length,
      ),
    );
  }

  Widget _buildGridTile({
    required String title,
    required IconData icon,
    required Color color,
    required Widget screen,
    required bool isTablet,
    required bool isDesktop,
  }) {
    return AnimatedScale(
      duration: const Duration(milliseconds: 200),
      scale: 1,
      curve: Curves.easeOut,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) => screen,
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                    return FadeTransition(
                      opacity: animation,
                      child: ScaleTransition(
                        scale: Tween<double>(
                          begin: 0.9,
                          end: 1.0,
                        ).animate(animation),
                        child: child,
                      ),
                    );
                  },
            ),
          );
        },
        child: Card(
          elevation: 6,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [color.withOpacity(0.15), color.withOpacity(0.05)],
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                // ignore: deprecated_member_use
                splashColor: color.withOpacity(0.2),
                // ignore: deprecated_member_use
                highlightColor: color.withOpacity(0.1),
                onTap: () {
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) =>
                          screen,
                      transitionsBuilder:
                          (context, animation, secondaryAnimation, child) {
                            return SlideTransition(
                              position: Tween<Offset>(
                                begin: const Offset(0, 0.5),
                                end: Offset.zero,
                              ).animate(animation),
                              child: child,
                            );
                          },
                    ),
                  );
                },
                child: Padding(
                  padding: EdgeInsets.all(isTablet ? 16 : 12),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: isTablet ? 50 : 40,
                        height: isTablet ? 50 : 40,
                        decoration: BoxDecoration(
                          // ignore: deprecated_member_use
                          color: color.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          icon,
                          size: isTablet ? 28 : 24,
                          color: color,
                        ),
                      ),
                      SizedBox(height: isTablet ? 16 : 12),
                      Text(
                        title,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: isTablet ? 14 : 12,
                          fontWeight: FontWeight.w600,
                          color: color,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// All other screen classes remain the same as in the previous code

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFF5F5F5), Colors.white],
          ),
        ),
        child: const Center(child: Text('Notification Screen Content')),
      ),
    );
  }
}

class BannerInfoScreen extends StatelessWidget {
  const BannerInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Banner Information')),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFF5F5F5), Colors.white],
          ),
        ),
        child: const Center(
          child: Text('Detailed banner information goes here'),
        ),
      ),
    );
  }
}
