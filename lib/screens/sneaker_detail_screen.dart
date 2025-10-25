import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import '../models/sneaker.dart';
import '../services/database_service.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class SneakerDetailScreen extends StatefulWidget {
  final Sneaker sneaker;
  final int index;

  const SneakerDetailScreen({
    super.key,
    required this.sneaker,
    required this.index,
  });

  @override
  State<SneakerDetailScreen> createState() => _SneakerDetailScreenState();
}

class _SneakerDetailScreenState extends State<SneakerDetailScreen> {
  bool _isEditing = false;
  late TextEditingController _nameController;
  late TextEditingController _brandController;
  late TextEditingController _priceController;
  late TextEditingController _quantityController;
  late TextEditingController _descriptionController;
  
  File? _selectedImage;
  String? _currentImagePath;
  final ImagePicker _picker = ImagePicker();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.sneaker.name);
    _brandController = TextEditingController(text: widget.sneaker.brand);
    _priceController = TextEditingController(text: widget.sneaker.price.toString());
    _quantityController = TextEditingController(text: widget.sneaker.quantity.toString());
    _descriptionController = TextEditingController(text: widget.sneaker.description ?? '');
    _currentImagePath = widget.sneaker.imagePath;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _brandController.dispose();
    _priceController.dispose();
    _quantityController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1800,
        maxHeight: 1800,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

 void _showImageSourceDialog() {
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
          children: [
            const Text(
              'Change Image',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            // Only show camera on mobile
            if (!kIsWeb)
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Color(0xFF9C27B0)),
                title: const Text('Camera'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: Color(0xFF9C27B0)),
              title: const Text('Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            if (_currentImagePath != null || _selectedImage != null)
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Remove Image'),
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    _selectedImage = null;
                    _currentImagePath = null;
                  });
                },
              ),
          ],
        ),
      ),
    ),
  );
}

  Future<String?> _saveImagePermanently(File imageFile) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final fileName = '${DateTime.now().millisecondsSinceEpoch}${path.extension(imageFile.path)}';
      final savedImage = await imageFile.copy('${appDir.path}/$fileName');
      return savedImage.path;
    } catch (e) {
      print('Error saving image: $e');
      return null;
    }
  }

  Future<void> _saveChanges() async {
    if (_nameController.text.trim().isEmpty ||
        _brandController.text.trim().isEmpty ||
        _priceController.text.trim().isEmpty ||
        _quantityController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all required fields'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final price = double.tryParse(_priceController.text);
    final quantity = int.tryParse(_quantityController.text);

    if (price == null || price < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid price'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (quantity == null || quantity < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid quantity'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      String? finalImagePath = _currentImagePath;

      if (_selectedImage != null) {
        finalImagePath = await _saveImagePermanently(_selectedImage!);
      }

      final updatedSneaker = Sneaker(
        name: _nameController.text.trim(),
        brand: _brandController.text.trim(),
        price: price,
        quantity: quantity,
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        imagePath: finalImagePath,
        dateAdded: widget.sneaker.dateAdded,
      );

      await DatabaseService.updateSneaker(widget.index, updatedSneaker);

      if (mounted) {
        setState(() {
          _isEditing = false;
          _currentImagePath = finalImagePath;
          _selectedImage = null;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sneaker updated successfully! ✅'),
            backgroundColor: Colors.green,
          ),
        );

        // Return true to indicate changes were made
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating sneaker: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  void _cancelEdit() {
    setState(() {
      _isEditing = false;
      _nameController.text = widget.sneaker.name;
      _brandController.text = widget.sneaker.brand;
      _priceController.text = widget.sneaker.price.toString();
      _quantityController.text = widget.sneaker.quantity.toString();
      _descriptionController.text = widget.sneaker.description ?? '';
      _selectedImage = null;
      _currentImagePath = widget.sneaker.imagePath;
    });
  }

 void _showFullImage() {
  if (_currentImagePath == null || kIsWeb) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Image viewing not available on web'),
        backgroundColor: Colors.orange,
      ),
    );
    return;
  }

  showDialog(
    context: context,
    builder: (context) => Dialog(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppBar(
            title: const Text('Sneaker Image'),
            automaticallyImplyLeading: false,
            actions: [
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          InteractiveViewer(
            child: Image.file(
              File(_currentImagePath!),
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Sneaker' : 'Sneaker Details'),
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                setState(() {
                  _isEditing = true;
                });
              },
              tooltip: 'Edit',
            ),
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: _cancelEdit,
              tooltip: 'Cancel',
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image Section
            GestureDetector(
              onTap: _isEditing ? _showImageSourceDialog : _showFullImage,
              child: Hero(
                tag: 'sneaker_${widget.index}',
                child: Container(
                  height: 300,
                  color: Colors.grey[200],
                  child: _selectedImage != null && !kIsWeb
    ? Image.file(_selectedImage!, fit: BoxFit.cover)
    : _currentImagePath != null && !kIsWeb
        ? Image.file(
                              File(_currentImagePath!),
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return _buildPlaceholder();
                              },
                            )
                          : _buildPlaceholder(),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name Field
                  if (_isEditing)
                    TextField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Sneaker Name',
                        border: OutlineInputBorder(),
                      ),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  else
                    Text(
                      widget.sneaker.name,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  const SizedBox(height: 12),

                  // Brand Field
                  if (_isEditing)
                    TextField(
                      controller: _brandController,
                      decoration: const InputDecoration(
                        labelText: 'Brand',
                        border: OutlineInputBorder(),
                      ),
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey[700],
                      ),
                    )
                  else
                    Text(
                      widget.sneaker.brand,
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey[700],
                      ),
                    ),
                  const SizedBox(height: 20),

                  // Price and Quantity
                  Row(
                    children: [
                      Expanded(
                        child: _isEditing
                            ? TextField(
                                controller: _priceController,
                                decoration: const InputDecoration(
                                  labelText: 'Price',
                                  border: OutlineInputBorder(),
                                  prefixText: '\$',
                                ),
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              )
                            : _buildInfoCard(
                                icon: Icons.attach_money,
                                label: 'Price',
                                value: '\$${widget.sneaker.price.toStringAsFixed(2)}',
                                color: const Color(0xFF9C27B0),
                              ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _isEditing
                            ? TextField(
                                controller: _quantityController,
                                decoration: const InputDecoration(
                                  labelText: 'Quantity',
                                  border: OutlineInputBorder(),
                                ),
                                keyboardType: TextInputType.number,
                              )
                            : _buildInfoCard(
                                icon: Icons.inventory,
                                label: 'In Stock',
                                value: '${widget.sneaker.quantity} pairs',
                                color: widget.sneaker.quantity < 5
                                    ? Colors.red
                                    : Colors.green,
                              ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Description
                  const Text(
                    'Description',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (_isEditing)
                    TextField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        hintText: 'Add description...',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 4,
                    )
                  else
                    Text(
                      widget.sneaker.description ?? 'No description available',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        height: 1.5,
                      ),
                    ),
                  const SizedBox(height: 20),

                  // Date Added
                  _buildInfoRow(
                    icon: Icons.calendar_today,
                    label: 'Added',
                    value: _formatDate(widget.sneaker.dateAdded),
                  ),

                  // Save Button (only in edit mode)
                  if (_isEditing) ...[
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _isSaving ? null : _saveChanges,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: const Color(0xFF9C27B0),
                        foregroundColor: Colors.white,
                      ),
                      child: _isSaving
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text(
                              'Save Changes',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_bag,
            size: 80,
            color: Colors.grey[400],
          ),
          if (_isEditing) ...[
            const SizedBox(height: 8),
            Text(
              'Tap to add image',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}