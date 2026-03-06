import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import '../../constants.dart';

class AddItemScreen extends StatefulWidget {
  static const routeName = '/add-item';
  const AddItemScreen({super.key});

  @override
  State<AddItemScreen> createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  final _formKey    = GlobalKey<FormState>();
  final _nameCtrl   = TextEditingController();
  final _priceCtrl  = TextEditingController();
  final _descCtrl   = TextEditingController();
  final _picker     = ImagePicker();

  String  _selectedCategory = 'Burgers';
  File?   _imageFile;
  bool    _isAvailable = true;
  bool    _isLoading   = false;

  final List<String> _categories = [
    'Burgers', 'Pizza', 'Sandwiches', 'Salads',
    'Drinks', 'Desserts', 'Extras', 'Other'
  ];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _priceCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final xFile = await _picker.pickImage(
      source: ImageSource.gallery, imageQuality: 80);
    if (xFile == null) return;
    setState(() => _imageFile = File(xFile.path));
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    // TODO: call ApiService to POST /menu with form data
    await Future.delayed(const Duration(seconds: 1)); // simulate API
    setState(() => _isLoading = false);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:         const Text('Item added successfully!'),
        backgroundColor: kSuccessColor,
        behavior:        SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(title: const Text('Add Menu Item')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(kDefaultPadding),
          children: [
            // Image picker
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 180,
                decoration: BoxDecoration(
                  color:        kBorderColor.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(16),
                  image: _imageFile != null
                      ? DecorationImage(
                          image: FileImage(_imageFile!),
                          fit:   BoxFit.cover,
                        )
                      : null,
                ),
                child: _imageFile == null
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.add_photo_alternate_outlined,
                              size: 40, color: kSubTextColor),
                          SizedBox(height: 8),
                          Text('Add item photo',
                              style: TextStyle(
                                  color: kSubTextColor, fontSize: 14)),
                        ],
                      )
                    : null,
              ),
            ),
            const SizedBox(height: 22),

            // Name
            TextFormField(
              controller: _nameCtrl,
              decoration: const InputDecoration(
                labelText: 'Item Name',
                hintText:  'e.g. Classic Burger',
              ),
              validator: (v) => v!.isEmpty ? 'Please enter item name' : null,
            ),
            const SizedBox(height: 14),

            // Price
            TextFormField(
              controller:   _priceCtrl,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(
                labelText:  'Price (DA)',
                hintText:   '450',
                suffixText: 'DA',
              ),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Please enter price';
                if (int.tryParse(v) == null) return 'Invalid price';
                return null;
              },
            ),
            const SizedBox(height: 14),

            // Category
            DropdownButtonFormField<String>(
              value:       _selectedCategory,
              decoration:  const InputDecoration(labelText: 'Category'),
              items: _categories
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (v) => setState(() => _selectedCategory = v!),
            ),
            const SizedBox(height: 14),

            // Description
            TextFormField(
              controller: _descCtrl,
              maxLines:   3,
              decoration: const InputDecoration(
                labelText: 'Description (optional)',
                hintText:  'Describe this item...',
              ),
            ),
            const SizedBox(height: 16),

            // Available toggle
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color:        Colors.white,
                borderRadius: BorderRadius.circular(12),
                border:       Border.all(color: kBorderColor),
              ),
              child: Row(
                children: [
                  const Icon(Icons.visibility_outlined, color: kSubTextColor),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Available',
                            style: TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 15)),
                        Text('Show this item on your menu',
                            style:
                                TextStyle(color: kSubTextColor, fontSize: 12)),
                      ],
                    ),
                  ),
                  Switch.adaptive(
                    value:       _isAvailable,
                    onChanged:   (v) => setState(() => _isAvailable = v),
                    activeColor: kSuccessColor,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            ElevatedButton(
              onPressed: _isLoading ? null : _handleSave,
              child: _isLoading
                  ? const SizedBox(
                      height: 22,
                      width:  22,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('Save Item'),
            ),
          ],
        ),
      ),
    );
  }
}