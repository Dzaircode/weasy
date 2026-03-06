import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import '../../constants.dart';

class EditItemScreen extends StatefulWidget {
  static const routeName = '/edit-item';
  const EditItemScreen({super.key});

  @override
  State<EditItemScreen> createState() => _EditItemScreenState();
}

class _EditItemScreenState extends State<EditItemScreen> {
  final _formKey   = GlobalKey<FormState>();
  final _nameCtrl  = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _descCtrl  = TextEditingController();
  final _picker    = ImagePicker();

  String _selectedCategory = 'Burgers';
  File?  _newImageFile;
  bool   _isAvailable = true;
  bool   _isLoading   = false;
  bool   _initialized = false;

  final List<String> _categories = [
    'Burgers', 'Pizza', 'Sandwiches', 'Salads',
    'Drinks', 'Desserts', 'Extras', 'Other'
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final item = ModalRoute.of(context)!.settings.arguments
          as Map<String, dynamic>;
      _nameCtrl.text   = item['name']  as String? ?? '';
      _priceCtrl.text  = '${item['price'] ?? ''}';
      _descCtrl.text   = item['desc']  as String? ?? '';
      _selectedCategory = item['category'] as String? ?? _categories.first;
      _isAvailable      = item['available'] as bool? ?? true;
      _initialized      = true;
    }
  }

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
    setState(() => _newImageFile = File(xFile.path));
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    // TODO: call ApiService.putFormData('/menu/:id', formData)
    await Future.delayed(const Duration(seconds: 1));
    setState(() => _isLoading = false);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:         const Text('Item updated!'),
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
      appBar: AppBar(title: const Text('Edit Item')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(kDefaultPadding),
          children: [
            // Image
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 160,
                decoration: BoxDecoration(
                  color:        kBorderColor.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(16),
                  image: _newImageFile != null
                      ? DecorationImage(
                          image: FileImage(_newImageFile!),
                          fit:   BoxFit.cover,
                        )
                      : null,
                ),
                child: _newImageFile == null
                    ? Stack(
                        alignment: Alignment.center,
                        children: [
                          const Icon(Icons.fastfood_rounded,
                              size: 48, color: kBorderColor),
                          Positioned(
                            bottom: 12,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 6),
                              decoration: BoxDecoration(
                                color:        kPrimaryColor,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text(
                                'Change photo',
                                style: TextStyle(
                                    color:      Colors.white,
                                    fontSize:   13,
                                    fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                        ],
                      )
                    : null,
              ),
            ),
            const SizedBox(height: 22),

            TextFormField(
              controller: _nameCtrl,
              decoration: const InputDecoration(labelText: 'Item Name'),
              validator: (v) => v!.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 14),

            TextFormField(
              controller:   _priceCtrl,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(
                  labelText: 'Price (DA)', suffixText: 'DA'),
              validator: (v) => v!.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 14),

            DropdownButtonFormField<String>(
              value:      _selectedCategory,
              decoration: const InputDecoration(labelText: 'Category'),
              items: _categories
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (v) => setState(() => _selectedCategory = v!),
            ),
            const SizedBox(height: 14),

            TextFormField(
              controller: _descCtrl,
              maxLines:   3,
              decoration: const InputDecoration(
                  labelText: 'Description (optional)'),
            ),
            const SizedBox(height: 16),

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
                    child: Text('Available',
                        style: TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 15)),
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
                      height: 22, width: 22,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : const Text('Update Item'),
            ),
          ],
        ),
      ),
    );
  }
}