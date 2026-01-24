import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/fridge_item.dart';
import '../services/fridge_service.dart';

class FridgeScreen extends StatefulWidget {
  const FridgeScreen({super.key});

  @override
  State<FridgeScreen> createState() => _FridgeScreenState();
}

class _FridgeScreenState extends State<FridgeScreen> {
  List<FridgeItem> _items = [];
  final nameCtrl = TextEditingController();
  final amountCtrl = TextEditingController();
  final unitCtrl = TextEditingController();
  final categoryCtrl = TextEditingController();

  DateTime selectedDate = DateTime.now().add(Duration(days: 7));
  String _searchQuery = '';
  String _selectedCategory = 'Alle';
  bool notificationsEnabled = true;

  final List<String> _categories = [
    'Alle',
    'Gemüse',
    'Obst',
    'Milchprodukte',
    'Fleisch',
    'Fisch',
    'Getränke',
    'Backwaren',
    'Gewürze',
    'Konserven',
    'Sonstiges',
  ];

  // Farben für Kategorien
  final Map<String, Color> _categoryColors = {
    'Gemüse': Color(0xFF4CAF50),
    'Obst': Color(0xFFFF9800),
    'Milchprodukte': Color(0xFF2196F3),
    'Fleisch': Color(0xFFE91E63),
    'Fisch': Color(0xFF00BCD4),
    'Getränke': Color(0xFF3F51B5),
    'Backwaren': Color(0xFFFF5722),
    'Gewürze': Color(0xFF9C27B0),
    'Konserven': Color(0xFF607D8B),
    'Sonstiges': Color(0xFF795548),
  };

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    final items = await FridgeService().getAllItems();
    setState(() {
      _items = items;
    });
  }

  Future<void> _saveItems() async {
    // Items are saved through FridgeService methods
  }

  List<FridgeItem> get _filteredItems {
    return _items.where((item) {
      final matchesSearch =
          _searchQuery.isEmpty ||
          item.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          item.category.toLowerCase().contains(_searchQuery.toLowerCase());

      final matchesCategory =
          _selectedCategory == 'Alle' || item.category == _selectedCategory;

      return matchesSearch && matchesCategory;
    }).toList();
  }

  int get _totalItems => _items.length;
  int get _expiringItems => _items
      .where(
        (item) => item.bestBeforeDate.difference(DateTime.now()).inDays <= 2,
      )
      .length;
  int get _expiredItems => _items
      .where((item) => item.bestBeforeDate.isBefore(DateTime.now()))
      .length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            SizedBox(height: 8),
            _buildSearchBar(),
            SizedBox(height: 12),
            _buildFilterChips(),
            SizedBox(height: 16),
            _buildStatistics(),
            SizedBox(height: 16),
            Expanded(child: _buildItemsList()),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddItemSheet,
        backgroundColor: Color.fromARGB(255, 26, 169, 48),
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Image.asset(
            'lib/images/schmackofatz_logo.png',
            height: 28,
            width: 28,
          ),
          SizedBox(width: 15),
          Expanded(
            child: Text(
              "Vorrat",
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.grey),
            onPressed: _loadItems,
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: TextField(
        decoration: InputDecoration(
          contentPadding: EdgeInsets.symmetric(vertical: 14, horizontal: 12),
          hintText: 'Suchen...',
          hintStyle: TextStyle(color: Colors.grey, fontSize: 15),
          prefixIcon: Icon(Icons.search, color: Colors.grey),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: Color.fromARGB(255, 26, 169, 48),
              width: 2,
            ),
          ),
        ),
        onChanged: (value) {
          setState(() => _searchQuery = value);
        },
      ),
    );
  }

  Widget _buildFilterChips() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: _categories.map((category) {
            final isSelected = _selectedCategory == category;
            return Padding(
              padding: EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(category),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() => _selectedCategory = category);
                },
                backgroundColor: Colors.grey[100],
                selectedColor: Color.fromARGB(255, 26, 169, 48),
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : Colors.black87,
                ),
                checkmarkColor: Colors.white,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildStatistics() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              'Gesamt',
              '$_totalItems',
              Color.fromARGB(255, 26, 169, 48),
            ),
          ),
          SizedBox(width: 10),
          Expanded(
            child: _buildStatCard('Läuft ab', '$_expiringItems', Colors.orange),
          ),
          SizedBox(width: 10),
          Expanded(
            child: _buildStatCard('Abgelaufen', '$_expiredItems', Colors.red),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemsList() {
    if (_filteredItems.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey[400]),
            SizedBox(height: 16),
            Text(
              _searchQuery.isNotEmpty || _selectedCategory != 'Alle'
                  ? 'Keine Artikel gefunden'
                  : 'Noch keine Artikel im Vorrat',
              style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey[600]),
            ),
            SizedBox(height: 8),
            Text(
              'Füge deinen ersten Artikel hinzu',
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 20),
      itemCount: _filteredItems.length,
      itemBuilder: (context, index) {
        final item = _filteredItems[index];
        return _buildItemCard(item, index);
      },
    );
  }

  Widget _buildItemCard(FridgeItem item, int index) {
    final daysUntilExpiration = item.daysUntilExpiration;
    final Color expirationColor =
        item.expirationStatus == ExpirationStatus.expired
        ? Colors.red
        : item.expirationStatus == ExpirationStatus.urgent
        ? Colors.orange
        : item.expirationStatus == ExpirationStatus.soon
        ? Colors.amber
        : Colors.green;

    final categoryColor = _categoryColors[item.category] ?? Colors.grey;

    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade300, width: 1),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 4,
              height: 60,
              decoration: BoxDecoration(
                color: expirationColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.name,
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: categoryColor.withOpacity(0.10),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: categoryColor.withOpacity(0.10),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: categoryColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                            SizedBox(width: 6),
                            Text(
                              item.category,
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: categoryColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Text(
                        '${item.amount} ${item.unit}',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      SizedBox(width: 16),
                      Icon(Icons.access_time, size: 16, color: expirationColor),
                      SizedBox(width: 4),
                      Text(
                        daysUntilExpiration < 0
                            ? 'Abgelaufen'
                            : daysUntilExpiration == 0
                            ? 'Heute'
                            : daysUntilExpiration == 1
                            ? 'Morgen'
                            : '$daysUntilExpiration Tage',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: expirationColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  if (item.tags.isNotEmpty) ...[
                    SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      children: item.tags.take(3).map((tag) {
                        return Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Color.fromARGB(
                              255,
                              26,
                              169,
                              48,
                            ).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            tag,
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              color: Color.fromARGB(255, 26, 169, 48),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ],
              ),
            ),
            SizedBox(width: 8),
            PopupMenuButton(
              color: Colors.white,
              itemBuilder: (context) => [
                PopupMenuItem(child: Text('Bearbeiten'), value: 'edit'),
                PopupMenuItem(child: Text('Verbrauchen'), value: 'consume'),
                PopupMenuItem(
                  child: Text('Löschen', style: TextStyle(color: Colors.red)),
                  value: 'delete',
                ),
              ],
              onSelected: (value) => _handleMenuAction(value, index),
            ),
          ],
        ),
      ),
    );
  }

  void _handleMenuAction(String action, int index) {
    switch (action) {
      case 'edit':
        _showEditItemDialog(index);
        break;
      case 'consume':
        _showConsumeDialog(index);
        break;
      case 'delete':
        _showDeleteConfirmation(index);
        break;
    }
  }

  void _showAddItemSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _AddEditItemSheet(
        onSave: (item) async {
          await FridgeService().addItem(item);
          await _loadItems();
          Navigator.pop(context);
        },
      ),
    );
  }

  void _showEditItemDialog(int index) {
    final item = _items[index];
    nameCtrl.text = item.name;
    amountCtrl.text = item.amount.toString();
    unitCtrl.text = item.unit;
    categoryCtrl.text = item.category;
    selectedDate = item.bestBeforeDate;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _AddEditItemSheet(
        existingItem: item,
        onSave: (updatedItem) async {
          await FridgeService().updateItem(updatedItem);
          await _loadItems();
          Navigator.pop(context);
        },
      ),
    );
  }

  void _showConsumeDialog(int index) {
    final item = _items[index];
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: Text(
          'Verbrauchen',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        content: Text(
          'Möchtest du den Artikel "${item.name}" wirklich verbrauchen?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Abbrechen',
              style: TextStyle(color: Color.fromARGB(255, 26, 169, 48)),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _items.removeAt(index);
              });
              _saveItems();
              Navigator.pop(context);
            },
            child: Text('Verbrauchen', style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color.fromARGB(255, 26, 169, 48),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(int index) {
    final item = _items[index];
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: Text(
          'Artikel löschen',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        content: Text(
          'Möchtest du den Artikel "${item.name}" wirklich löschen?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Abbrechen',
              style: TextStyle(color: Color.fromARGB(255, 26, 169, 48)),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              await FridgeService().removeItem(item.id);
              await _loadItems();
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Löschen', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class _AddEditItemSheet extends StatefulWidget {
  final FridgeItem? existingItem;
  final Function(FridgeItem) onSave;

  const _AddEditItemSheet({this.existingItem, required this.onSave});

  @override
  State<_AddEditItemSheet> createState() => _AddEditItemSheetState();
}

class _AddEditItemSheetState extends State<_AddEditItemSheet> {
  final _formKey = GlobalKey<FormState>();
  final nameCtrl = TextEditingController();
  final amountCtrl = TextEditingController();
  final unitCtrl = TextEditingController();
  final categoryCtrl = TextEditingController();

  DateTime _selectedDate = DateTime.now().add(Duration(days: 7));

  final List<String> _categories = [
    'Gemüse',
    'Obst',
    'Milchprodukte',
    'Fleisch',
    'Fisch',
    'Getränke',
    'Backwaren',
    'Gewürze',
    'Konserven',
    'Sonstiges',
  ];

  final List<String> _units = [
    'Stück',
    'g',
    'kg',
    'ml',
    'l',
    'TL',
    'EL',
    'Tasse',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.existingItem != null) {
      final item = widget.existingItem!;
      nameCtrl.text = item.name;
      amountCtrl.text = item.amount.toString();
      unitCtrl.text = item.unit;
      categoryCtrl.text = item.category;
      _selectedDate = item.bestBeforeDate;
    } else {
      unitCtrl.text = 'Stück';
      categoryCtrl.text = 'Sonstiges';
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.6,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SafeArea(
            top: false,
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                controller: scrollController,
                padding: EdgeInsets.fromLTRB(20, 12, 20, bottomInset + 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      width: 40,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      widget.existingItem != null
                          ? 'Artikel bearbeiten'
                          : 'Artikel hinzufügen',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 24),
                    _buildTextField(nameCtrl, 'Name'),
                    SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            amountCtrl,
                            'Menge',
                            isNumber: true,
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(child: _buildUnitDropdown()),
                      ],
                    ),
                    SizedBox(height: 16),
                    _buildCategoryDropdown(),
                    SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _saveItem,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromARGB(255, 26, 169, 48),
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        widget.existingItem != null
                            ? 'Aktualisieren'
                            : 'Hinzufügen',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    bool isNumber = false,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.black),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Color.fromARGB(255, 26, 169, 48),
            width: 2,
          ),
        ),
      ),
    );
  }

  Widget _buildUnitDropdown() {
    return DropdownButtonFormField<String>(
      value: unitCtrl.text.isNotEmpty ? unitCtrl.text : null,
      dropdownColor: Colors.white,
      decoration: InputDecoration(
        labelText: 'Einheit',
        labelStyle: TextStyle(color: Colors.black),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Color.fromARGB(255, 26, 169, 48),
            width: 2,
          ),
        ),
      ),
      items: _units.map((unit) {
        return DropdownMenuItem(value: unit, child: Text(unit));
      }).toList(),
      onChanged: (value) {
        setState(() {
          unitCtrl.text = value ?? '';
        });
      },
    );
  }

  Widget _buildCategoryDropdown() {
    return DropdownButtonFormField<String>(
      value: categoryCtrl.text.isNotEmpty ? categoryCtrl.text : null,
      dropdownColor: Colors.white,
      decoration: InputDecoration(
        labelText: 'Kategorie',
        labelStyle: TextStyle(color: Colors.black),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Color.fromARGB(255, 26, 169, 48),
            width: 2,
          ),
        ),
      ),
      items: _categories.map((category) {
        return DropdownMenuItem(value: category, child: Text(category));
      }).toList(),
      onChanged: (value) {
        setState(() {
          categoryCtrl.text = value ?? '';
        });
      },
    );
  }

  void _saveItem() {
    final amount = double.tryParse(amountCtrl.text);
    if (amount == null) return;

    final item = FridgeItem(
      id:
          widget.existingItem?.id ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      name: nameCtrl.text,
      category: categoryCtrl.text,
      amount: amount,
      unit: unitCtrl.text,
      bestBeforeDate: _selectedDate,
      addedDate: DateTime.now(),
      purchaseDate: DateTime.now(),
      originalAmount: amount,
    );

    widget.onSave(item);
  }
}
