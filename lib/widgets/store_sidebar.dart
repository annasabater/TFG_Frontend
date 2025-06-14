import 'package:flutter/material.dart';

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
  double _minRating = 0;

  void _resetFilters() {
    setState(() {
      _nameController.clear();
      _minPriceController.clear();
      _maxPriceController.clear();
      _selectedCategory = null;
      _selectedCondition = null;
      _minRating = 0;
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
      'minRating': _minRating,
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      children: [
        const Text(
          'Filtros',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        ),
        const SizedBox(height: 24),
        ExpansionTile(
          initiallyExpanded: true,
          title: const Text(
            'Búsqueda y precio',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Buscar por nombre'),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _minPriceController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Precio mínimo',
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _maxPriceController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Precio máximo',
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        ExpansionTile(
          initiallyExpanded: true,
          title: const Text(
            'Categoría y condición',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          children: [
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              items:
                  ['venta', 'alquiler']
                      .map(
                        (e) => DropdownMenuItem(
                          value: e,
                          child: Text(e[0].toUpperCase() + e.substring(1)),
                        ),
                      )
                      .toList(),
              onChanged: (v) => setState(() => _selectedCategory = v),
              decoration: const InputDecoration(), // Sin labelText
              hint: const Text('Selecciona categoría'),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _selectedCondition,
              items:
                  ['nuevo', 'usado']
                      .map(
                        (e) => DropdownMenuItem(
                          value: e,
                          child: Text(e[0].toUpperCase() + e.substring(1)),
                        ),
                      )
                      .toList(),
              onChanged: (v) => setState(() => _selectedCondition = v),
              decoration: const InputDecoration(), // Sin labelText
              hint: const Text('Selecciona condición'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ExpansionTile(
          initiallyExpanded: true,
          title: const Text(
            'Rating mínimo',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          children: [
            Row(
              children: [
                const Text('Mínimo rating:'),
                Expanded(
                  child: Slider(
                    value: _minRating,
                    min: 0,
                    max: 5,
                    divisions: 5,
                    label: _minRating.toStringAsFixed(0),
                    onChanged: (v) => setState(() => _minRating = v),
                  ),
                ),
                Text(_minRating.toStringAsFixed(0)),
              ],
            ),
          ],
        ),
        const SizedBox(height: 32),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.filter_alt),
                label: const Text('Aplicar filtros'),
                onPressed: _applyFilters,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                icon: const Icon(Icons.refresh),
                label: const Text('Resetear'),
                onPressed: _resetFilters,
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
