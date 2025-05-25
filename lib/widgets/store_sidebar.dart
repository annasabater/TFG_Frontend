import 'package:flutter/material.dart';

class StoreSidebar extends StatefulWidget {
  final void Function(Map<String, dynamic> filters) onApply;
  const StoreSidebar({Key? key, required this.onApply}) : super(key: key);

  @override
  State<StoreSidebar> createState() => _StoreSidebarState();
}

class _StoreSidebarState extends State<StoreSidebar> {
  final _nameController = TextEditingController();
  final _minPriceController = TextEditingController();
  final _maxPriceController = TextEditingController();
  String? _selectedModel;
  String? _selectedCategory;
  String? _selectedCondition;
  double _minRating = 0;

  @override
  void dispose() {
    _nameController.dispose();
    _minPriceController.dispose();
    _maxPriceController.dispose();
    super.dispose();
  }

  void _applyFilters() {
    widget.onApply({
      'name': _nameController.text,
      'minPrice': double.tryParse(_minPriceController.text),
      'maxPrice': double.tryParse(_maxPriceController.text),
      'model': _selectedModel,
      'category': _selectedCategory,
      'condition': _selectedCondition,
      'minRating': _minRating,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.teal,
            ),
            child: Text(
              'Filtros',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Búsqueda por nombre
                const Text('Buscar por nombre',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    hintText: 'Nombre del dron...',
                  ),
                ),
                const SizedBox(height: 24),

                // Rango de precio
                const Text('Precio mínimo-máximo',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _minPriceController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          hintText: 'Min',
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextField(
                        controller: _maxPriceController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          hintText: 'Max',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Modelo
                const Text('Modelo', style: TextStyle(fontWeight: FontWeight.bold)),
                DropdownButtonFormField<String>(
                  value: _selectedModel,
                  decoration: const InputDecoration(hintText: 'Seleccionar modelo'),
                  items: ['Otro', 'DJI', 'Parrot', 'Autel']
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (v) => setState(() => _selectedModel = v),
                ),
                const SizedBox(height: 24),

                // Categoría
                const Text('Categoría', style: TextStyle(fontWeight: FontWeight.bold)),
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  decoration: const InputDecoration(hintText: 'Seleccionar categoría'),
                  items: ['Juguete', 'Fotografía', 'Carreras', 'Otro']
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (v) => setState(() => _selectedCategory = v),
                ),
                const SizedBox(height: 24),

                // Condición
                const Text('Condición', style: TextStyle(fontWeight: FontWeight.bold)),
                DropdownButtonFormField<String>(
                  value: _selectedCondition,
                  decoration: const InputDecoration(hintText: 'Seleccionar condición'),
                  items: ['Nuevo', 'Como nuevo', 'Usado']
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (v) => setState(() => _selectedCondition = v),
                ),
                const SizedBox(height: 24),

                // Rating mínimo
                const Text('Rating mínimo', style: TextStyle(fontWeight: FontWeight.bold)),
                Row(
                  children: [
                    Expanded(
                      child: Slider(
                        value: _minRating,
                        min: 0,
                        max: 5,
                        divisions: 5,
                        label: _minRating.round().toString(),
                        onChanged: (v) => setState(() => _minRating = v),
                      ),
                    ),
                    Text(_minRating.round().toString(),
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 32),

                // Botón aplicar filtros
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _applyFilters,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Aplicar filtros'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
