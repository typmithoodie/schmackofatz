import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';

/// Einfaches ShoppingItem Modell mit Kategorien und Preisen
class ShoppingItem {
  final String id;
  String name;
  String amount;
  String category;
  double price;
  bool done;

  ShoppingItem({
    required this.id,
    required this.name,
    required this.amount,
    required this.category,
    required this.price,
    this.done = false,
  });
}

class ShoppingScreen extends StatefulWidget {
  const ShoppingScreen({super.key});

  @override
  State<ShoppingScreen> createState() => _ShoppingScreenState();
}

class _ShoppingScreenState extends State<ShoppingScreen> {
  final List<ShoppingItem> _items = [];
  final nameCtrl = TextEditingController();
  final amountCtrl = TextEditingController();
  final categoryCtrl = TextEditingController();
  final priceCtrl = TextEditingController();

  String _searchQuery = '';
  String _selectedCategory = 'Alle';
  final List<String> _defaultCategories = [
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

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  void _loadItems() {
    setState(() {
      // Lade aus SharedPreferences oder anderer lokaler Speicherung
    });
  }

  void _saveItems() {
    // Speichere in SharedPreferences oder anderer lokaler Speicherung
  }

  List<String> get _availableCategories {
    final categories = Set<String>.from(_defaultCategories);
    categories.addAll(_items.map((item) => item.category));
    categories.remove(
      'Sonstiges',
    ); // entferne Standard-Kategorie, füge sie am Ende wieder hinzu
    final sortedCategories = categories.toList()..sort();
    sortedCategories.insert(0, 'Sonstiges');
    return sortedCategories;
  }

  List<ShoppingItem> get _filteredItems {
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

  double get _totalPrice => _items.fold(0, (sum, item) => sum + item.price);
  int get _doneCount => _items.where((item) => item.done).length;
  double get _completedPrice => _items
      .where((item) => item.done)
      .fold(0, (sum, item) => sum + item.price);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20),
              buildHeader(),
              SizedBox(height: 20),
              buildQuickActions(),
              SizedBox(height: 20),
              buildSearchAndFilter(),
              SizedBox(height: 15),
              buildProgressCard(),
              SizedBox(height: 20),
              buildShoppingListSection(),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildHeader() {
    return Row(
      children: [
        SizedBox(width: 20),
        Image.asset('lib/images/schmackofatz_logo.png', height: 28, width: 28),
        SizedBox(width: 15),
        Expanded(
          child: Text(
            'Einkaufsliste',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
        IconButton(
          icon: Icon(Icons.refresh, color: Colors.green),
          onPressed: _loadItems,
        ),
      ],
    );
  }

  Widget buildQuickActions() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _showAddItemSheet,
                  icon: Icon(Icons.add, color: Colors.white),
                  label: Text(
                    'Artikel hinzufügen',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromARGB(255, 26, 169, 48),
                  ),
                ),
              ),
              SizedBox(width: 15),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _shareList,
                  icon: Icon(Icons.share_outlined, color: Colors.black),
                  label: Text(
                    'Liste teilen',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: Colors.black,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.grey),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildProgressCard() {
    final totalCount = _items.length;
    final progress = totalCount > 0 ? _doneCount / totalCount : 0.0;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Card(
        elevation: 0,
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Fortschritt',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    '${_totalPrice.toStringAsFixed(2)} €',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 26, 169, 48),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 6),
              Text(
                '$_doneCount von $totalCount erledigt (${_completedPrice.toStringAsFixed(2)} €)',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: 10),
              LinearProgressIndicator(
                color: Color.fromARGB(255, 26, 169, 48),
                backgroundColor: Colors.grey[300],
                value: progress,
                minHeight: 6,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildSearchAndFilter() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            decoration: InputDecoration(
              hintText: 'Artikel suchen...',
              prefixIcon: Icon(Icons.search),
              filled: true,
              fillColor: Colors.grey[100],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
            onChanged: (value) {
              setState(() => _searchQuery = value);
            },
          ),
          SizedBox(height: 12),
          _buildFilterChips(),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    final categories = [
      'Alle',
      ..._availableCategories.where((cat) => cat != 'Alle'),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: categories.map((category) {
          final isSelected = _selectedCategory == category;
          return Padding(
            padding: EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(
                category,
                style: GoogleFonts.poppins(fontSize: 12, color: Colors.white),
              ),
              selected: isSelected,
              selectedColor: Color.fromARGB(255, 26, 169, 48),
              checkmarkColor: Colors.white,
              backgroundColor: Colors.grey[400],
              onSelected: (_) {
                setState(() => _selectedCategory = category);
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget buildShoppingListSection() {
    final filteredItems = _filteredItems;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Einkaufsliste (${filteredItems.length})',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
        SizedBox(height: 12),
        if (filteredItems.isEmpty)
          _buildEmptyState()
        else
          ...filteredItems.map((item) => _buildItemCard(item)),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_cart_outlined, size: 64, color: Colors.grey[400]),
          SizedBox(height: 16),
          Text(
            _searchQuery.isNotEmpty || _selectedCategory != 'Alle'
                ? 'Keine Artikel gefunden'
                : 'Keine Artikel in der Einkaufsliste',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Fügen Sie Artikel hinzu, um zu beginnen',
            style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildItemCard(ShoppingItem item) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _showItemDetails(item),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              Checkbox(
                activeColor: Colors.green,
                checkColor: Colors.white,
                value: item.done,
                onChanged: (val) {
                  _toggleItem(item);
                },
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: GoogleFonts.poppins(
                        color: item.done ? Colors.grey[300] : Colors.black,
                        decoration: item.done
                            ? TextDecoration.lineThrough
                            : null,
                        decorationColor: Colors.grey[300],
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        if (item.amount.isNotEmpty) ...[
                          Text(
                            item.amount,
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          SizedBox(width: 12),
                        ],
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            item.category,
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${item.price.toStringAsFixed(2)} €',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      color: item.done ? Colors.grey[300] : Colors.black,
                    ),
                  ),
                  SizedBox(height: 4),
                  PopupMenuButton(
                    color: Colors.white,
                    itemBuilder: (context) => [
                      PopupMenuItem(child: Text('Bearbeiten'), value: 'edit'),
                      PopupMenuItem(
                        child: Text(
                          'Löschen',
                          style: TextStyle(color: Colors.red),
                        ),
                        value: 'delete',
                      ),
                    ],
                    onSelected: (value) => _handleMenuAction(value, item),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddItemSheet() {
    _clearInputs();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildAddEditItemSheet(),
    );
  }

  void _showEditItemSheet(ShoppingItem item) {
    nameCtrl.text = item.name;
    amountCtrl.text = item.amount;
    categoryCtrl.text = item.category;
    priceCtrl.text = item.price.toString();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildAddEditItemSheet(existingItem: item),
    );
  }

  Widget _buildAddEditItemSheet({ShoppingItem? existingItem}) {
    return DraggableScrollableSheet(
      initialChildSize: 0.8,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  existingItem != null
                      ? 'Artikel bearbeiten'
                      : 'Artikel hinzufügen',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 24),
                TextField(
                  controller: nameCtrl,
                  decoration: InputDecoration(
                    labelText: 'Artikelname *',
                    labelStyle: TextStyle(color: Colors.black),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Color.fromARGB(255, 26, 169, 48),
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  autofocus: existingItem == null,
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: amountCtrl,
                        decoration: InputDecoration(
                          labelText: 'Menge',
                          labelStyle: TextStyle(color: Colors.black),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Color.fromARGB(255, 26, 169, 48),
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: TextField(
                        controller: priceCtrl,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Preis (€)',
                          labelStyle: TextStyle(color: Colors.black),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Color.fromARGB(255, 26, 169, 48),
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                TextField(
                  controller: categoryCtrl,
                  decoration: InputDecoration(
                    labelText: 'Kategorie *',
                    labelStyle: TextStyle(color: Colors.black),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Color.fromARGB(255, 26, 169, 48),
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    suffixIcon: PopupMenuButton<String>(
                      color: Colors.white,
                      icon: Icon(Icons.arrow_drop_down),
                      onSelected: (String category) {
                        categoryCtrl.text = category;
                      },
                      itemBuilder: (BuildContext context) {
                        return _availableCategories.map((String category) {
                          return PopupMenuItem<String>(
                            value: category,
                            child: Text(category),
                          );
                        }).toList();
                      },
                    ),
                  ),
                ),
                SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => existingItem != null
                      ? _updateItem(existingItem)
                      : _addItem(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromARGB(255, 26, 169, 48),
                    padding: EdgeInsets.all(16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    existingItem != null ? 'Aktualisieren' : 'Hinzufügen',
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
        );
      },
    );
  }

  void _showItemDetails(ShoppingItem item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.8,
        expand: false,
        builder: (context, scrollController) {
          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: SingleChildScrollView(
              controller: scrollController,
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 40,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.name,
                          style: GoogleFonts.poppins(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Checkbox(
                        activeColor: Colors.green,
                        checkColor: Colors.white,
                        value: item.done,
                        onChanged: (val) {
                          _toggleItem(item);
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  _buildDetailRow('Menge', item.amount),
                  _buildDetailRow('Kategorie', item.category),
                  _buildDetailRow(
                    'Preis',
                    '${item.price.toStringAsFixed(2)} €',
                  ),
                  _buildDetailRow('Status', item.done ? 'Erledigt' : 'Offen'),
                  SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            _showEditItemSheet(item);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color.fromARGB(255, 26, 169, 48),
                          ),
                          child: Text(
                            'Bearbeiten',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            _deleteItem(item);
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                          ),
                          child: Text(
                            'Löschen',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _addItem() {
    if (nameCtrl.text.trim().isEmpty || categoryCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Bitte füllen Sie alle Pflichtfelder aus!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final newItem = ShoppingItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: nameCtrl.text.trim(),
      amount: amountCtrl.text.trim(),
      category: categoryCtrl.text.trim(),
      price: double.tryParse(priceCtrl.text) ?? 0.0,
    );

    setState(() {
      _items.add(newItem);
    });

    _saveItems();
    _clearInputs();
    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Artikel hinzugefügt!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _updateItem(ShoppingItem existingItem) {
    if (nameCtrl.text.trim().isEmpty || categoryCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Bitte füllen Sie alle Pflichtfelder aus!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      existingItem.name = nameCtrl.text.trim();
      existingItem.amount = amountCtrl.text.trim();
      existingItem.category = categoryCtrl.text.trim();
      existingItem.price = double.tryParse(priceCtrl.text) ?? 0.0;
    });

    _saveItems();
    _clearInputs();
    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Artikel aktualisiert!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _toggleItem(ShoppingItem item) {
    setState(() {
      item.done = !item.done;
    });
    _saveItems();
  }

  void _deleteItem(ShoppingItem item) {
    setState(() {
      _items.removeWhere((i) => i.id == item.id);
    });
    _saveItems();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${item.name} entfernt'),
        backgroundColor: Colors.orange,
        action: SnackBarAction(
          label: 'Rückgängig',
          textColor: Colors.white,
          onPressed: () {
            setState(() {
              _items.add(item);
            });
            _saveItems();
          },
        ),
      ),
    );
  }

  void _handleMenuAction(String action, ShoppingItem item) {
    switch (action) {
      case 'edit':
        _showEditItemSheet(item);
        break;
      case 'delete':
        _deleteItem(item);
        break;
    }
  }

  void _clearInputs() {
    nameCtrl.clear();
    amountCtrl.clear();
    categoryCtrl.clear();
    priceCtrl.clear();
  }

  void _shareList() {
    if (_items.isEmpty) {
      Share.share('Meine Einkaufsliste ist leer 🛒');
      return;
    }

    final buffer = StringBuffer();
    buffer.writeln('🛒 Meine Einkaufsliste:\n');

    for (final item in _items) {
      final status = item.done ? '✅' : '⏳';
      buffer.writeln(
        '$status ${item.name} (${item.amount}) – ${item.price.toStringAsFixed(2)} € [${item.category}]',
      );
    }

    buffer.writeln('\n💰 Gesamt: ${_totalPrice.toStringAsFixed(2)} €');
    buffer.writeln('✅ Erledigt: ${_doneCount}/${_items.length} Artikel');

    Share.share(buffer.toString());
  }
}
