import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart'; // Added for external links


class KnowledgeBaseApp extends StatelessWidget {
  const KnowledgeBaseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Knowledge Base',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 1,
        ),
      ),
      home: const KnowledgeBaseScreen(),
    );
  }
}

class KnowledgeBaseScreen extends StatefulWidget {
  const KnowledgeBaseScreen({super.key});

  @override
  State<KnowledgeBaseScreen> createState() => _KnowledgeBaseScreenState();
}

class _KnowledgeBaseScreenState extends State<KnowledgeBaseScreen> {
  final List<Category> categories = [
    Category('Voting Process', Icons.how_to_vote),
    Category('Voter ID', Icons.badge),
    Category('Candidate Info', Icons.person),
    Category('Election Rules', Icons.rule),
    Category('FAQs', Icons.question_answer),
  ];

  final List<Article> articles = [
    Article(
      id: '1',
      title: 'How to Register for Voting',
      description: 'Step-by-step guide to voter registration process and requirements for eligibility in upcoming elections.',
      category: 'Voting Process',
      content: '''
# Voter Registration Process
To participate in elections, you must be registered. Here's how:

## Eligibility Requirements
- Must be 18+ years old
- Citizen of the country
- Resident of the constituency

## Steps to Register
1. Visit the election commission website
2. Fill Form 6 with personal details
3. Submit proof of identity and address
4. Track application status online

[Official Registration Portal](https://electioncommission.gov/registration)
''',
      related: ['2', '3'],
    ),
    Article(
      id: '2',
      title: 'Checking Your Voter Status',
      description: 'Learn how to verify your voter registration status online and what to do if your name is missing.',
      category: 'Voting Process',
      content: '''
# Checking Voter Status
Verify your registration status through these methods:

## Online Check
1. Visit the National Voter Portal
2. Enter your ID number
3. View your registration details

## SMS Service
Send SMS: VOTE<space>ID Number to 12345

## Helpline
Call 1-800-ELECTION for assistance
''',
      related: ['1', '4'],
    ),
    Article(
      id: '3',
      title: 'Voting ID Requirements',
      description: 'What identification documents are acceptable at polling stations.',
      category: 'Voter ID',
      content: '''
# Acceptable Identification
Bring one of these to the polling station:

## Primary Documents
- National ID Card
- Passport
- Driver's License

## Secondary Documents
- Utility bill with address
- Bank statement with photo
- Government employee ID
''',
      related: ['1', '2'],
    ),
  ];

  String? _selectedCategory;
  String _searchQuery = '';
  bool _showSearchBar = false;

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    final isTablet = MediaQuery.of(context).size.width >= 600 && 
                    MediaQuery.of(context).size.width < 1024;
    final isDesktop = MediaQuery.of(context).size.width >= 1024;

    return Scaffold(
      appBar: AppBar(
        title: _showSearchBar ? null : const Text('Knowledge Base'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => setState(() => _showSearchBar = !_showSearchBar),
          )
        ],
      ),
      body: Column(
        children: [
          if (_showSearchBar) _buildSearchBar(),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Sidebar for tablet/desktop
                if (isDesktop || isTablet) _buildCategorySidebar(isTablet),
                // Main content area
                Expanded(
                  child: _buildArticleGrid(isMobile, isTablet, isDesktop),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search articles, FAQs, or guides...',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
        onChanged: (value) => setState(() => _searchQuery = value),
      ),
    );
  }

  Widget _buildCategorySidebar(bool isTablet) {
    return Container(
      width: isTablet ? 200 : 250,
      decoration: BoxDecoration(
        border: Border(right: BorderSide(color: Colors.grey.shade300)),
      ),
      child: ListView(
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('Categories', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          ...categories.map((category) {
            return ListTile(
              leading: Icon(category.icon),
              title: Text(category.name),
              selected: _selectedCategory == category.name,
              onTap: () => setState(() => _selectedCategory = 
                  _selectedCategory == category.name ? null : category.name),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildArticleGrid(bool isMobile, bool isTablet, bool isDesktop) {
    // Filter articles based on search and category
    final filteredArticles = articles.where((article) {
      final matchesSearch = article.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                            article.description.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesCategory = _selectedCategory == null || 
                             article.category == _selectedCategory;
      return matchesSearch && matchesCategory;
    }).toList();

    if (isMobile) {
      return Column(
        children: [
          // Horizontal category chips for mobile
          SizedBox(
            height: 50,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                const SizedBox(width: 16),
                ...categories.map((category) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: ChoiceChip(
                      label: Text(category.name),
                      selected: _selectedCategory == category.name,
                      onSelected: (selected) => setState(() => _selectedCategory = 
                          selected ? category.name : null),
                    ),
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Article list
          Expanded(
            child: ListView.builder(
              itemCount: filteredArticles.length,
              itemBuilder: (context, index) => _buildArticleItem(filteredArticles[index], isMobile),
            ),
          ),
        ],
      );
    } else {
      return GridView.builder(
        padding: const EdgeInsets.all(16.0),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: isDesktop ? 3 : 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.5,
        ),
        itemCount: filteredArticles.length,
        itemBuilder: (context, index) => _buildArticleItem(filteredArticles[index], isMobile),
      );
    }
  }

  Widget _buildArticleItem(Article article, bool isMobile) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _navigateToArticle(article),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.article, color: Colors.blue),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      article.category,
                      style: TextStyle(
                        color: Colors.blue.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                article.title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: Text(
                  article.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToArticle(Article article) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => 
            ArticleDetailScreen(article: article, allArticles: articles),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(0.0, 0.1);
          const end = Offset.zero;
          const curve = Curves.easeOut;

          var tween = Tween(begin: begin, end: end).chain(
            CurveTween(curve: curve),
          );

          return SlideTransition(
            position: animation.drive(tween),
            child: FadeTransition(
              opacity: animation,
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }
}

class ArticleDetailScreen extends StatelessWidget {
  final Article article;
  final List<Article> allArticles;

  const ArticleDetailScreen({
    super.key,
    required this.article,
    required this.allArticles,
  });

  @override
  Widget build(BuildContext context) {
    final relatedArticles = allArticles.where(
      (a) => article.related.contains(a.id) && a.id != article.id
    ).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(article.title),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Article content
            _buildArticleContent(context),
            
            // Related articles
            if (relatedArticles.isNotEmpty) ...[
              const SizedBox(height: 32),
              const Divider(),
              const SizedBox(height: 16),
              const Text(
                'Related Articles',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 180,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: relatedArticles.length,
                  itemBuilder: (context, index) => _buildRelatedArticleCard(
                    context, relatedArticles[index]),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildArticleContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Simulated formatted content
        ...article.content.split('\n').map((line) {
          if (line.startsWith('#')) {
            final level = line.split(' ')[0].length;
            return Padding(
              padding: EdgeInsets.only(
                top: level == 1 ? 8.0 : 16.0,
                bottom: 8.0,
              ),
              child: Text(
                line.replaceAll('#', ''),
                style: TextStyle(
                  fontSize: level == 1 ? 24 : level == 2 ? 20 : 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          } else if (line.startsWith('-')) {
            return Padding(
              padding: const EdgeInsets.only(left: 16.0, bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('•  ', style: TextStyle(fontSize: 16)),
                  Expanded(
                    child: Text(
                      line.substring(1).trim(),
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            );
          } else if (line.startsWith('[')) {
            // Handle markdown links
            final regex = RegExp(r'\[(.*?)\]\((.*?)\)');
            final match = regex.firstMatch(line);
            if (match != null) {
              final text = match.group(1);
              final url = match.group(2);
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: InkWell(
                  onTap: () => _launchUrl(url!),
                  child: Text(
                    text ?? 'Link',
                    style: const TextStyle(
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                      fontSize: 16,
                    ),
                  ),
                ),
              );
            }
            return Text(line, style: const TextStyle(fontSize: 16));
          } else if (line.trim().isEmpty) {
            return const SizedBox(height: 16);
          } else if (line.startsWith(r'[0-9]+\.')) {
            // Numbered lists
            return Padding(
              padding: const EdgeInsets.only(left: 16.0, bottom: 8),
              child: Text(line, style: const TextStyle(fontSize: 16)),
            );
          } else {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                line,
                style: const TextStyle(fontSize: 16),
              ),
            );
          }
        }),
      ],
    );
  }

  Widget _buildRelatedArticleCard(BuildContext context, Article article) {
    return SizedBox(
      width: 280,
      child: Card(
        margin: const EdgeInsets.only(right: 16),
        child: InkWell(
          onTap: () => _navigateToDetail(context, article),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  article.category,
                  style: TextStyle(
                    color: Colors.blue.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  article.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Text(
                  article.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _navigateToDetail(BuildContext context, Article article) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ArticleDetailScreen(
          article: article,
          allArticles: allArticles,
        ),
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      debugPrint('Could not launch $url');
    }
  }
}

// Data Models
class Category {
  final String name;
  final IconData icon;

  Category(this.name, this.icon);
}

class Article {
  final String id;
  final String title;
  final String description;
  final String category;
  final String content;
  final List<String> related;

  Article({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.content,
    required this.related,
  });
}