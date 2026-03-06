import 'package:flutter/material.dart';
import '../../constants.dart';
import 'add_item_screen.dart';
import 'edit_item_screen.dart';

class MenuScreen extends StatefulWidget {
  static const routeName = '/menu';
  final bool embedded;
  const MenuScreen({super.key, this.embedded = false});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<String> _categories = [
    'All', 'Burgers', 'Pizza', 'Drinks', 'Desserts'
  ];

  // Demo data — replace with API call
  final List<Map<String, dynamic>> _items = [
    {'id': '1', 'name': 'Classic Burger',  'price': 450,  'category': 'Burgers', 'available': true,  'image': null},
    {'id': '2', 'name': 'Double Smash',    'price': 650,  'category': 'Burgers', 'available': true,  'image': null},
    {'id': '3', 'name': 'Margherita',      'price': 900,  'category': 'Pizza',   'available': true,  'image': null},
    {'id': '4', 'name': 'Coca Cola 33cl',  'price': 120,  'category': 'Drinks',  'available': true,  'image': null},
    {'id': '5', 'name': 'Chocolate Lava',  'price': 280,  'category': 'Desserts','available': false, 'image': null},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _categories.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> _filteredItems(String category) {
    if (category == 'All') return _items;
    return _items.where((i) => i['category'] == category).toList();
  }

  void _toggleAvailability(String id) {
    setState(() {
      final item = _items.firstWhere((i) => i['id'] == id);
      item['available'] = !(item['available'] as bool);
    });
  }

  void _deleteItem(String id) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title:   const Text('Delete Item'),
        content: const Text('Are you sure you want to delete this item?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() => _items.removeWhere((i) => i['id'] == id));
              Navigator.pop(context);
            },
            child: const Text('Delete',
                style: TextStyle(color: kErrorColor)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: widget.embedded ? null : AppBar(title: const Text('Menu')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, AddItemScreen.routeName),
        backgroundColor: kPrimaryColor,
        icon:  const Icon(Icons.add),
        label: const Text('Add Item'),
      ),
      body: Column(
        children: [
          if (widget.embedded)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  kDefaultPadding, kDefaultPadding, kDefaultPadding, 0),
              child: Row(
                children: [
                  const Text(
                    'Menu',
                    style: TextStyle(
                      fontSize:   22,
                      fontWeight: FontWeight.w800,
                      color:      kTextColor,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${_items.length} items',
                    style: const TextStyle(
                        fontSize: 13, color: kSubTextColor),
                  ),
                ],
              ),
            ),

          // Category tabs
          TabBar(
            controller:          _tabController,
            isScrollable:        true,
            indicatorColor:      kPrimaryColor,
            labelColor:          kPrimaryColor,
            unselectedLabelColor: kSubTextColor,
            labelStyle: const TextStyle(fontWeight: FontWeight.w600),
            tabs: _categories.map((c) => Tab(text: c)).toList(),
          ),

          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: _categories.map((cat) {
                final items = _filteredItems(cat);
                if (items.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.restaurant_menu_outlined,
                            size: 48, color: kBorderColor),
                        const SizedBox(height: 12),
                        const Text('No items in this category',
                            style: TextStyle(color: kSubTextColor)),
                      ],
                    ),
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.all(kDefaultPadding),
                  itemCount:     items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (_, i) => _MenuItemTile(
                    item:             items[i],
                    onEdit: () => Navigator.pushNamed(
                      context,
                      EditItemScreen.routeName,
                      arguments: items[i],
                    ),
                    onDelete:         () => _deleteItem(items[i]['id']),
                    onToggleAvailable: () => _toggleAvailability(items[i]['id']),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Menu Item Tile ────────────────────────────────────────
class _MenuItemTile extends StatelessWidget {
  const _MenuItemTile({
    required this.item,
    required this.onEdit,
    required this.onDelete,
    required this.onToggleAvailable,
  });

  final Map<String, dynamic> item;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onToggleAvailable;

  @override
  Widget build(BuildContext context) {
    final bool available = item['available'] as bool;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color:        Colors.white,
        borderRadius: BorderRadius.circular(14),
        border:       Border.all(color: kBorderColor),
      ),
      child: Row(
        children: [
          // Image placeholder
          Container(
            width:  64,
            height: 64,
            decoration: BoxDecoration(
              color:        kBorderColor.withOpacity(0.5),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.fastfood_rounded,
                color: kSubTextColor, size: 28),
          ),
          const SizedBox(width: 12),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['name'] as String,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize:   15,
                    color:      kTextColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${item['price']} DA',
                  style: const TextStyle(
                    fontSize:   14,
                    fontWeight: FontWeight.w600,
                    color:      kPrimaryColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item['category'] as String,
                  style: const TextStyle(
                    fontSize: 12,
                    color:    kSubTextColor,
                  ),
                ),
              ],
            ),
          ),

          // Actions
          Column(
            children: [
              // Available toggle
              Switch.adaptive(
                value:          available,
                onChanged:      (_) => onToggleAvailable(),
                activeColor:    kSuccessColor,
                inactiveThumbColor: kSubTextColor,
              ),
              Row(
                children: [
                  IconButton(
                    icon:    const Icon(Icons.edit_outlined, size: 20),
                    color:   kSecondaryColor,
                    onPressed: onEdit,
                  ),
                  IconButton(
                    icon:    const Icon(Icons.delete_outline, size: 20),
                    color:   kErrorColor,
                    onPressed: onDelete,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}