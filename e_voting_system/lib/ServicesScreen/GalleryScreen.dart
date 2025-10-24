import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:cached_network_image/cached_network_image.dart';

class GalleryScreen extends StatefulWidget {
  const GalleryScreen({super.key});

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  final List<String> imageUrls = [
    'https://images.unsplash.com/photo-1682686580391-615bd0548540?w=800&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1695653422903-7a1a8d5b3e1f?w=800&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1695720207515-8b6a0a8f1d8c?w=800&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1694465499115-9a8b0a8f1d8c?w=800&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1694897735576-3a2e1b5b5b5b?w=800&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1694897735576-3a2e1b5b5b5b?w=800&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1694897735576-3a2e1b5b5b5b?w=800&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1694897735576-3a2e1b5b5b5b?w=800&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1694897735576-3a2e1b5b5b5b?w=800&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1694897735576-3a2e1b5b5b5b?w=800&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1694897735576-3a2e1b5b5b5b?w=800&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1694897735576-3a2e1b5b5b5b?w=800&auto=format&fit=crop',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'My Gallery',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.search, size: 28),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, size: 28),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // Categories Tab Bar
          SizedBox(
            height: 50,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: const [
                SizedBox(width: 16),
                CategoryChip(label: 'All', isSelected: true),
                CategoryChip(label: 'Nature'),
                CategoryChip(label: 'Portrait'),
                CategoryChip(label: 'Travel'),
                CategoryChip(label: 'Food'),
                CategoryChip(label: 'Animals'),
                SizedBox(width: 16),
              ],
            ),
          ),
          
          // Grid View
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.8,
                ),
                itemCount: imageUrls.length,
                itemBuilder: (context, index) {
                  return GalleryImageCard(imageUrl: imageUrls[index]);
                },
              ),
            ),
          ),
        ],
      ),
      
      // Floating Action Button
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: Colors.deepPurple,
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
    );
  }
}

class GalleryImageCard extends StatelessWidget {
  final String imageUrl;
  
  const GalleryImageCard({
    super.key,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Stack(
        children: [
          // Image
          CachedNetworkImage(
            imageUrl: imageUrl,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
            placeholder: (context, url) => Container(
              color: Colors.grey[300],
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
            errorWidget: (context, url, error) => const Icon(Icons.error),
          ),
          
          // Gradient Overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.7),
                ],
              ),
            ),
          ),
          
          // Bottom Content
          Positioned(
            bottom: 12,
            left: 12,
            right: 12,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Beautiful Sunset',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: const [
                    Icon(Icons.location_on, color: Colors.white, size: 16),
                    SizedBox(width: 4),
                    Text(
                      'Bali, Indonesia',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                    Spacer(),
                    Icon(Icons.favorite_border, color: Colors.white, size: 16),
                    SizedBox(width: 8),
                    Icon(Icons.share, color: Colors.white, size: 16),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CategoryChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  
  const CategoryChip({
    super.key,
    required this.label,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Chip(
        label: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: isSelected ? Colors.deepPurple : Colors.grey[300],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }
}