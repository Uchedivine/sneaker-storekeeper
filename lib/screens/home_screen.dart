import 'package:flutter/material.dart';
import '../models/sneaker.dart';
import '../services/database_service.dart';
import '../widgets/sneaker_card.dart';
import 'add_sneaker_screen.dart';
import 'sneaker_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Sneaker> sneakers = [];
  List<Sneaker> filteredSneakers = [];
  final TextEditingController _searchController = TextEditingController();
  String _sortOption = 'Recent'; // Recent, Price Low, Price High, Name

  @override
  void initState() {
    super.initState();
    _loadSneakers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadSneakers() {
    setState(() {
      sneakers = DatabaseService.getAllSneakers();
      _applySortAndFilter();
    });
  }

  void _applySortAndFilter() {
    String query = _searchController.text.toLowerCase();
    
    // Filter by search query
    if (query.isEmpty) {
      filteredSneakers = List.from(sneakers);
    } else {
      filteredSneakers = sneakers.where((sneaker) {
        return sneaker.name.toLowerCase().contains(query) ||
               sneaker.brand.toLowerCase().contains(query);
      }).toList();
    }

    // Apply sorting
    switch (_sortOption) {
      case 'Price Low':
        filteredSneakers.sort((a, b) => a.price.compareTo(b.price));
        break;
      case 'Price High':
        filteredSneakers.sort((a, b) => b.price.compareTo(a.price));
        break;
      case 'Name':
        filteredSneakers.sort((a, b) => a.name.compareTo(b.name));
        break;
      case 'Recent':
      default:
        filteredSneakers.sort((a, b) => b.dateAdded.compareTo(a.dateAdded));
        break;
    }

    setState(() {});
  }

  void _deleteSneaker(int index) {
    // Find the actual index in the main list
    final sneakerToDelete = filteredSneakers[index];
    final actualIndex = sneakers.indexOf(sneakerToDelete);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Sneaker'),
        content: Text('Are you sure you want to delete "${sneakerToDelete.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await DatabaseService.deleteSneaker(actualIndex);
              Navigator.pop(context);
              _loadSneakers();
              
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Sneaker deleted successfully'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _showSortOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Sort By',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _buildSortOption('Recent', Icons.access_time),
              _buildSortOption('Name', Icons.sort_by_alpha),
              _buildSortOption('Price Low', Icons.arrow_upward),
              _buildSortOption('Price High', Icons.arrow_downward),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSortOption(String option, IconData icon) {
    final isSelected = _sortOption == option;
    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? const Color(0xFF9C27B0) : Colors.grey,
      ),
      title: Text(
        option,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? const Color(0xFF9C27B0) : Colors.black,
        ),
      ),
      trailing: isSelected
          ? const Icon(Icons.check, color: Color(0xFF9C27B0))
          : null,
      onTap: () {
        setState(() {
          _sortOption = option;
        });
        Navigator.pop(context);
        _applySortAndFilter();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sneaker Inventory'),
        actions: [
          // Sort button
          IconButton(
            icon: const Icon(Icons.sort),
            onPressed: _showSortOptions,
            tooltip: 'Sort',
          ),
          // Total count badge
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${sneakers.length} items',
                  style: const TextStyle(
                    color: Color(0xFF9C27B0),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search sneakers...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _applySortAndFilter();
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
              onChanged: (value) => _applySortAndFilter(),
            ),
          ),

          // Statistics Row
          if (sneakers.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'Total Value',
                      '\$${_calculateTotalValue().toStringAsFixed(2)}',
                      Icons.attach_money,
                      Colors.green,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      'Low Stock',
                      '${_getLowStockCount()}',
                      Icons.warning,
                      Colors.orange,
                    ),
                  ),
                ],
              ),
            ),
          
          const SizedBox(height: 8),

          // Sneaker List
          Expanded(
            child: filteredSneakers.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.only(top: 8, bottom: 80),
                    itemCount: filteredSneakers.length,
                    itemBuilder: (context, index) {
                      // Find actual index in main list
                      final sneaker = filteredSneakers[index];
                      final displayIndex = index;
                      
                      return SneakerCard(
                        sneaker: sneaker,
                        index: displayIndex,
                        onTap: () async {
                          // Find actual index for detail screen
                          final actualIndex = sneakers.indexOf(sneaker);
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SneakerDetailScreen(
                                sneaker: sneaker,
                                index: actualIndex,
                              ),
                            ),
                          );

                          if (result == true) {
                            _loadSneakers();
                          }
                        },
                        onDelete: () => _deleteSneaker(index),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddSneakerScreen(),
            ),
          );
          
          if (result == true) {
            _loadSneakers();
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Sneaker'),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    final hasSearchQuery = _searchController.text.isNotEmpty;
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            hasSearchQuery ? Icons.search_off : Icons.inventory_2_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            hasSearchQuery ? 'No Sneakers Found' : 'No Sneakers Yet',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            hasSearchQuery
                ? 'Try a different search term'
                : 'Tap the button below to add your first sneaker',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  double _calculateTotalValue() {
    return sneakers.fold(0, (sum, sneaker) => sum + (sneaker.price * sneaker.quantity));
  }

  int _getLowStockCount() {
    return sneakers.where((sneaker) => sneaker.quantity < 5).length;
  }
}