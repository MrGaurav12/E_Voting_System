import 'package:e_voting_system/OnlyVoterServicesScreen/Update_voter_details.dart';
import 'package:e_voting_system/OnlyVoterServicesScreen/Voter_id_card_download_screen.dart';
import 'package:e_voting_system/OnlyVoterServicesScreen/Voter_id_status_Screen.dart';
import 'package:e_voting_system/OnlyVoterServicesScreen/create_voter_id_screen.dart';
import 'package:e_voting_system/Screen/VoterServicesScreen/DownloadV.dart';
import 'package:e_voting_system/Screen/VoterServicesScreen/down.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class VoterServicesScreen extends StatefulWidget {
  const VoterServicesScreen({super.key});

  @override
  State<VoterServicesScreen> createState() => _VoterServicesScreenState();
}

class _VoterServicesScreenState extends State<VoterServicesScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<VoterService> _services = [];
  List<VoterService> _filteredServices = [];
  bool _searchVisible = false;

  @override
  void initState() {
    super.initState();
    _services = _getDummyServices();
    _filteredServices = _services;
    _searchController.addListener(_filterServices);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterServices() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredServices = _services.where((service) {
        return service.title.toLowerCase().contains(query) ||
            service.description.toLowerCase().contains(query);
      }).toList();
    });
  }

  void _toggleSearch() {
    setState(() => _searchVisible = !_searchVisible);
  }

  // Navigation handler based on file names
  void _navigateToServiceScreen(String routeName, BuildContext context) {
    switch (routeName) {
      case 'voter_registration_screen.dart':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => CreateVoterIdScreen()),
        );
        break;
      case 'voter_status_screen.dart':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => VoterStatusScreen()),
        );
        break;
      case 'update_details_screen.dart':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => UpdateVoterDetailsScreen()),
        );
        break;
      case 'download_voter_id_screen.dart':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => DownloadVoterIdScreen()),
        );
        break;
      case 'polling_station_screen.dart':
        _showComingSoonSnackbar(context, 'Polling Station Locator');
        break;
      case 'election_schedule_screen.dart':
        _showComingSoonSnackbar(context, 'Election Schedule');
        break;
      case 'voter_helpline_screen.dart':
        _showComingSoonSnackbar(context, 'Voter Helpline');
        break;
      case 'election_results_screen.dart':
        _showComingSoonSnackbar(context, 'Election Results');
        break;
      default:
        _showComingSoonSnackbar(context, 'This Service');
    }
  }

  void _showComingSoonSnackbar(BuildContext context, String serviceName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$serviceName - Coming Soon!'),
        backgroundColor: Colors.blue[700],
        duration: Duration(seconds: 2),
      ),
    );
  }

  List<VoterService> _getDummyServices() {
    return [
      VoterService(
        title: 'Voter Registration',
        description: 'Register as a new voter or enroll in the electoral roll',
        icon: Icons.how_to_reg,
        routeName: 'voter_registration_screen.dart',
      ),
      VoterService(
        title: 'Check Voter ID Status',
        description: 'Track your voter ID application status',
        icon: Icons.assignment_turned_in,
        routeName: 'voter_status_screen.dart',
      ),
      VoterService(
        title: 'Update Voter Details',
        description: 'Modify your personal information in voter records',
        icon: Icons.update,
        routeName: 'update_details_screen.dart',
      ),
      VoterService(
        title: 'Download Voter ID',
        description: 'Download digital copy of your voter ID card',
        icon: Icons.download,
        routeName: 'download_voter_id_screen.dart',
      ),
      VoterService(
        title: 'Locate Polling Station',
        description: 'Find your designated polling booth location',
        icon: Icons.location_on,
        routeName: 'polling_station_screen.dart',
      ),
      VoterService(
        title: 'Election Schedule',
        description: 'View upcoming election dates and timelines',
        icon: Icons.calendar_today,
        routeName: 'election_schedule_screen.dart',
      ),
      VoterService(
        title: 'Voter Helpline',
        description: 'Contact support for voter-related queries',
        icon: Icons.help,
        routeName: 'voter_helpline_screen.dart',
      ),
      VoterService(
        title: 'Election Results',
        description: 'Check historical and current election results',
        icon: Icons.bar_chart,
        routeName: 'election_results_screen.dart',
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 900;

    return Scaffold(
      appBar: AppBar(
        title: !_searchVisible
            ? Text('Voter Services', style: GoogleFonts.poppins())
            : null,
        actions: [
          if (!_searchVisible)
            IconButton(icon: const Icon(Icons.search), onPressed: _toggleSearch)
          else
            SizedBox(
              width: isDesktop ? 300 : MediaQuery.of(context).size.width * 0.7,
              child: TextField(
                controller: _searchController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Search services...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: _toggleSearch,
                  ),
                  border: InputBorder.none,
                ),
              ),
            ),
        ],
      ),
      drawer: isDesktop ? null : _buildDrawer(context),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CreateVoterIdScreen()),
          );
        },
        icon: const Icon(Icons.person_add),
        label: Text('Register as new Voter', style: GoogleFonts.poppins()),
      ),
      body: Column(
        children: [
          // Banner Section
          Container(
            height: 200,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(
                  'https://images.unsplash.com/photo-1503376780353-7e6692767b70?auto=format&fit=crop&w=1200',
                ),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  Colors.black.withOpacity(0.5),
                  BlendMode.darken,
                ),
              ),
            ),
            child: Center(
              child: Text(
                'Empowering Voters, Strengthening Democracy',
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),

          // Services Grid
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  int crossAxisCount = 1;
                  if (constraints.maxWidth > 1200) {
                    crossAxisCount = 4;
                  } else if (constraints.maxWidth > 800) {
                    crossAxisCount = 3;
                  } else if (constraints.maxWidth > 600) {
                    crossAxisCount = 2;
                  }

                  return GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      childAspectRatio: 1.0,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: _filteredServices.length,
                    itemBuilder: (context, index) {
                      return _buildServiceCard(
                        _filteredServices[index],
                        context,
                      );
                    },
                  );
                },
              ),
            ),
          ),

          // Footer
          Container(
            color: Theme.of(context).primaryColor,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text(
                      'Contact: 1800-123-4567',
                      style: GoogleFonts.poppins(color: Colors.white),
                    ),
                    Text(
                      'Email: info@elections.gov',
                      style: GoogleFonts.poppins(color: Colors.white),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  '© 2023 National Election Commission',
                  style: GoogleFonts.poppins(color: Colors.white70),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: Theme.of(context).primaryColor),
            child: Text(
              'Voter Services',
              style: GoogleFonts.poppins(fontSize: 24, color: Colors.white),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: Text('Home', style: GoogleFonts.poppins()),
            onTap: () {
              Navigator.pop(context); // Close drawer
            },
          ),
          ListTile(
            leading: const Icon(Icons.info),
            title: Text('About', style: GoogleFonts.poppins()),
            onTap: () {
              Navigator.pop(context);
              _showComingSoonSnackbar(context, 'About Page');
            },
          ),
          ListTile(
            leading: const Icon(Icons.contact_page),
            title: Text('Contact', style: GoogleFonts.poppins()),
            onTap: () {
              Navigator.pop(context);
              _showComingSoonSnackbar(context, 'Contact Page');
            },
          ),
          ListTile(
            leading: const Icon(Icons.how_to_vote),
            title: Text('Voter Registration', style: GoogleFonts.poppins()),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CreateVoterIdScreen()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildServiceCard(VoterService service, BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          _navigateToServiceScreen(service.routeName, context);
        },
        onLongPress: () {
          // Show service details on long press
          _showServiceDetails(context, service);
        },
        hoverColor: Colors.blue[50],
        splashColor: Colors.blue[100],
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  shape: BoxShape.circle,
                ),
                child: Icon(service.icon, size: 32, color: Colors.blue[700]),
              ),
              const SizedBox(height: 16),
              Text(
                service.title,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[800],
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Expanded(
                child: Text(
                  service.description,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey[700],
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    _navigateToServiceScreen(service.routeName, context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[700],
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 8),
                  ),
                  child: Text(
                    'Open',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showServiceDetails(BuildContext context, VoterService service) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          service.title,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: Colors.blue[700],
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(service.icon, color: Colors.blue, size: 24),
                SizedBox(width: 10),
                Text(
                  'Service Details',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                ),
              ],
            ),
            SizedBox(height: 10),
            Text(service.description, style: GoogleFonts.poppins()),
            SizedBox(height: 10),
            Text(
              'File: ${service.routeName}',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close', style: GoogleFonts.poppins()),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _navigateToServiceScreen(service.routeName, context);
            },
            child: Text('Open Service', style: GoogleFonts.poppins()),
          ),
        ],
      ),
    );
  }
}

class VoterService {
  final String title;
  final String description;
  final IconData icon;
  final String routeName;

  VoterService({
    required this.title,
    required this.description,
    required this.icon,
    required this.routeName,
  });
}
