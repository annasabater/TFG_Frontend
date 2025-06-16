import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class StoreSidebar extends StatefulWidget {
  final void Function(Map<String, dynamic> filters) onApply;
  const StoreSidebar({super.key, required this.onApply});

  @override
  State<StoreSidebar> createState() => _StoreSidebarState();
}

class _StoreSidebarState extends State<StoreSidebar> {
  final _nameController = TextEditingController();
  final _minPriceController = TextEditingController();
  final _maxPriceController = TextEditingController();
  String? _selectedCategory;
  String? _selectedCondition;

  void _resetFilters() {
    setState(() {
      _nameController.clear();
      _minPriceController.clear();
      _maxPriceController.clear();
      _selectedCategory = null;
      _selectedCondition = null;
    });
    widget.onApply({});
  }

  void _applyFilters() {
    widget.onApply({
      'name': _nameController.text,
      'minPrice': double.tryParse(_minPriceController.text),
      'maxPrice': double.tryParse(_maxPriceController.text),
      'category': _selectedCategory,
      'condition': _selectedCondition,
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = theme.colorScheme;
    return Material(
      color: color.surface,
      elevation: 0,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        children: [
          Row(
            children: [
              const Icon(Icons.filter_alt, size: 28, color: Colors.blueAccent),
              const SizedBox(width: 8),
              Text(
                AppLocalizations.of(context)!.filters,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Card(
            elevation: 1,
            margin: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context)!.searchAndPrice,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.searchByName,
                      prefixIcon: const Icon(Icons.search),
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _minPriceController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: AppLocalizations.of(context)!.minPrice,
                            prefixIcon: const Icon(Icons.arrow_downward),
                            border: const OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _maxPriceController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: AppLocalizations.of(context)!.maxPrice,
                            prefixIcon: const Icon(Icons.arrow_upward),
                            border: const OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Card(
            elevation: 1,
            margin: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context)!.categoryAndCondition,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: _selectedCategory,
                    items:
                        ['venta', 'alquiler']
                            .map(
                              (e) => DropdownMenuItem(
                                value: e,
                                child: Text(
                                  e[0].toUpperCase() + e.substring(1),
                                ),
                              ),
                            )
                            .toList(),
                    onChanged: (v) => setState(() => _selectedCategory = v),
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.category,
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.category),
                    ),
                    hint: Text(AppLocalizations.of(context)!.selectCategory),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _selectedCondition,
                    items:
                        ['nuevo', 'usado']
                            .map(
                              (e) => DropdownMenuItem(
                                value: e,
                                child: Text(
                                  e[0].toUpperCase() + e.substring(1),
                                ),
                              ),
                            )
                            .toList(),
                    onChanged: (v) => setState(() => _selectedCondition = v),
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.condition,
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.check_circle_outline),
                    ),
                    hint: Text(AppLocalizations.of(context)!.selectCondition),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.filter_alt),
                  label: Text(AppLocalizations.of(context)!.applyFilters),
                  onPressed: _applyFilters,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                    backgroundColor: Colors.blueAccent,
                    foregroundColor: Colors.white,
                    textStyle: const TextStyle(fontWeight: FontWeight.bold),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.refresh),
                  label: Text(AppLocalizations.of(context)!.resetFilters),
                  onPressed: _resetFilters,
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                    foregroundColor: Colors.blueAccent,
                    textStyle: const TextStyle(fontWeight: FontWeight.bold),
                    side: const BorderSide(color: Colors.blueAccent),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
