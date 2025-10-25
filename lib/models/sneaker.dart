import 'package:hive/hive.dart';

 part 'sneaker.g.dart'; // This will be auto-generated

@HiveType(typeId: 0)
class Sneaker extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  String brand;

  @HiveField(2)
  double price;

  @HiveField(3)
  int quantity;

  @HiveField(4)
  String? imagePath; // Optional - path to the sneaker image

  @HiveField(5)
  String? description; // Optional - sneaker description

  @HiveField(6)
  DateTime dateAdded;

  Sneaker({
    required this.name,
    required this.brand,
    required this.price,
    required this.quantity,
    this.imagePath,
    this.description,
    required this.dateAdded,
  });
}