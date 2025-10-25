import 'package:hive/hive.dart';
import '../models/sneaker.dart';

class DatabaseService {
  // Get the sneakers box
  static Box<Sneaker> getSneakersBox() {
    return Hive.box<Sneaker>('sneakers');
  }

  // CREATE - Add a new sneaker
  static Future<void> addSneaker(Sneaker sneaker) async {
    final box = getSneakersBox();
    await box.add(sneaker);
  }

  // READ - Get all sneakers
  static List<Sneaker> getAllSneakers() {
    final box = getSneakersBox();
    return box.values.toList();
  }

  // READ - Get a single sneaker by index
  static Sneaker? getSneaker(int index) {
    final box = getSneakersBox();
    return box.getAt(index);
  }

  // UPDATE - Update a sneaker at a specific index
  static Future<void> updateSneaker(int index, Sneaker sneaker) async {
    final box = getSneakersBox();
    await box.putAt(index, sneaker);
  }

  // DELETE - Delete a sneaker at a specific index
  static Future<void> deleteSneaker(int index) async {
    final box = getSneakersBox();
    await box.deleteAt(index);
  }

  // UTILITY - Get total number of sneakers
  static int getSneakerCount() {
    final box = getSneakersBox();
    return box.length;
  }

  // UTILITY - Search sneakers by name or brand
  static List<Sneaker> searchSneakers(String query) {
    final box = getSneakersBox();
    final allSneakers = box.values.toList();
    
    return allSneakers.where((sneaker) {
      final nameLower = sneaker.name.toLowerCase();
      final brandLower = sneaker.brand.toLowerCase();
      final searchLower = query.toLowerCase();
      
      return nameLower.contains(searchLower) || brandLower.contains(searchLower);
    }).toList();
  }

  // UTILITY - Get sneakers sorted by price
  static List<Sneaker> getSneakersSortedByPrice({bool ascending = true}) {
    final sneakers = getAllSneakers();
    sneakers.sort((a, b) {
      return ascending 
          ? a.price.compareTo(b.price)
          : b.price.compareTo(a.price);
    });
    return sneakers;
  }

  // UTILITY - Get low stock sneakers (quantity < 5)
  static List<Sneaker> getLowStockSneakers() {
    final box = getSneakersBox();
    return box.values.where((sneaker) => sneaker.quantity < 5).toList();
  }

  // UTILITY - Clear all sneakers (use carefully!)
  static Future<void> clearAllSneakers() async {
    final box = getSneakersBox();
    await box.clear();
  }
}