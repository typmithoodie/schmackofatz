import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/fridge_item.dart';

class FridgeScreen extends StatefulWidget {
  const FridgeScreen({super.key});

  @override
  State<FridgeScreen> createState() => _FridgeScreenState();
}

class _FridgeScreenState extends State<FridgeScreen> {
  final List<FridgeItem> _items = [];
  final nameCtrl = TextEditingController();
  final amountCtrl = TextEditingController();
  final unitCtrl = TextEditingController();
  final categoryCtrl = TextEditingController();
  final notesCtrl = TextEditingController();
  final tagsCtrl = TextEditingController();

  DateTime selectedDate = DateTime.now().add(Duration(days: 7));
  String _searchQuery = '';
  String _selectedCategory = 'Alle';

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

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  void _loadItems() {
    // Lade Beispiel-Items für Demo
    setState(() {
      _items.clear();
      // Keine automatischen Items - beginnt leer
    });
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
            SizedBox(height: 20),
            _buildHeader(),
            SizedBox(height: 20),
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
      padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
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

    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: expirationColor.withOpacity(0.3)),
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
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          item.category,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.grey[700],
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.scale_outlined,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      SizedBox(width: 4),
                      Text(
                        '${item.amount} ${item.unit}',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      SizedBox(width: 16),
                      Icon(
                        Icons.calendar_today_outlined,
                        size: 16,
                        color: expirationColor,
                      ),
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
        onSave: (item) {
          setState(() {
            _items.add(item);
          });
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
    notesCtrl.text = item.notes?.toString() ?? '';
    tagsCtrl.text = item.tags.join(', ');
    selectedDate = item.bestBeforeDate;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _AddEditItemSheet(
        existingItem: item,
        onSave: (updatedItem) {
          setState(() {
            _items[index] = updatedItem;
          });
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
        title: Text('Verbrauchen'),
        content: Text('Möchtest du "${item.name}" wirklich verbrauchen?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Abbrechen'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _items.removeAt(index);
              });
              Navigator.pop(context);
            },
            child: Text('Verbrauchen'),
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
        title: Text('Artikel löschen'),
        content: Text('Möchtest du "${item.name}" wirklich löschen?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Abbrechen'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _items.removeAt(index);
              });
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
  final notesCtrl = TextEditingController();
  final tagsCtrl = TextEditingController();

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
      notesCtrl.text = item.notes?.toString() ?? '';
      tagsCtrl.text = item.tags.join(', ');
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
                    _buildTextField(
                      nameCtrl,
                      'Name *',
                      Icons.label_outlined,
                      true,
                    ),
                    SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: _buildTextField(
                            amountCtrl,
                            'Menge *',
                            Icons.scale_outlined,
                            true,
                            isNumber: true,
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(child: _buildUnitDropdown()),
                      ],
                    ),
                    SizedBox(height: 16),
                    _buildCategoryDropdown(),
                    SizedBox(height: 16),
                    _buildDateSelector(),
                    SizedBox(height: 16),
                    _buildTextField(
                      tagsCtrl,
                      'Tags (kommagetrennt)',
                      Icons.sell_outlined,
                      false,
                    ),
                    SizedBox(height: 16),
                    _buildTextField(
                      notesCtrl,
                      'Notizen',
                      Icons.notes_outlined,
                      false,
                      maxLines: 3,
                    ),
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
    String label,
    IconData icon,
    bool required, {
    bool isNumber = false,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Color.fromARGB(255, 26, 169, 48),
            width: 2,
          ),
        ),
        suffixIcon: required
            ? Text('*', style: TextStyle(color: Colors.red))
            : null,
      ),
      validator: (value) {
        if (required && (value == null || value.isEmpty)) {
          return '$label ist erforderlich';
        }
        return null;
      },
    );
  }

  Widget _buildUnitDropdown() {
    return DropdownButtonFormField<String>(
      value: unitCtrl.text.isNotEmpty ? unitCtrl.text : null,
      decoration: InputDecoration(
        labelText: 'Einheit *',
        prefixIcon: Icon(Icons.straighten_outlined),
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
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Einheit ist erforderlich';
        }
        return null;
      },
    );
  }

  Widget _buildCategoryDropdown() {
    return DropdownButtonFormField<String>(
      value: categoryCtrl.text.isNotEmpty ? categoryCtrl.text : null,
      decoration: InputDecoration(
        labelText: 'Kategorie *',
        prefixIcon: Icon(Icons.category_outlined),
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
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Kategorie ist erforderlich';
        }
        return null;
      },
    );
  }

  Widget _buildDateSelector() {
    return InkWell(
      onTap: () async {
        final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: _selectedDate,
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(Duration(days: 365)),
        );
        if (picked != null) {
          setState(() => _selectedDate = picked);
        }
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'Haltbarkeitsdatum *',
          prefixIcon: Icon(Icons.calendar_today_outlined),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: Color.fromARGB(255, 26, 169, 48),
              width: 2,
            ),
          ),
          suffixIcon: Icon(Icons.arrow_drop_down),
        ),
        child: Text(
          '${_selectedDate.day}.${_selectedDate.month}.${_selectedDate.year}',
          style: GoogleFonts.poppins(),
        ),
      ),
    );
  }

  void _saveItem() {
    if (_formKey.currentState!.validate()) {
      final tags = tagsCtrl.text.isNotEmpty
          ? tagsCtrl.text
                .split(',')
                .map((tag) => tag.trim())
                .where((tag) => tag.isNotEmpty)
                .toList()
          : <String>[];

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
        notes: notesCtrl.text.isNotEmpty ? notesCtrl.text : null,
        tags: tags,
        originalAmount: amount,
      );

      widget.onSave(item);
    }
  }
}
