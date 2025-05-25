import 'package:flutter/material.dart';

class StoreSidebar extends StatefulWidget {
  final void Function(Map<String, dynamic> filters) onApply;
  final bool isMobile;
  const StoreSidebar({Key? key, required this.onApply, this.isMobile = false}) : super(key: key);

  @override
  State<StoreSidebar> createState() => _StoreSidebarState();
}

class _StoreSidebarState extends State<StoreSidebar> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _minPriceCtrl = TextEditingController();
  final TextEditingController _maxPriceCtrl = TextEditingController();
  final TextEditingController _nameCtrl = TextEditingController();
  String? _selectedModel;
  String? _selectedCategory;
  String? _selectedCondition;
  double _minRating = 0;

  @override
  void dispose() {
    _minPriceCtrl.dispose();
    _maxPriceCtrl.dispose();
    _nameCtrl.dispose();
    super.dispose();
  }

  void _applyFilters() {
    final filters = <String, dynamic>{
      'minPrice': _minPriceCtrl.text.isNotEmpty ? double.tryParse(_minPriceCtrl.text) : null,
      'maxPrice': _maxPriceCtrl.text.isNotEmpty ? double.tryParse(_maxPriceCtrl.text) : null,
      'name': _nameCtrl.text,
      'model': _selectedModel,
      'category': _selectedCategory,
      'condition': _selectedCondition,
      'minRating': _minRating,
    };
    widget.onApply(filters);
    if (widget.isMobile) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Text('Filtros', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(labelText: 'Buscar por nombre'),
              ),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _minPriceCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Precio mínimo'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: _maxPriceCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Precio máximo'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _selectedModel,
                items: ['DJI', 'Parrot', 'Autel', 'Otro'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                onChanged: (v) => setState(() => _selectedModel = v),
                decoration: const InputDecoration(labelText: 'Modelo'),
              ),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                items: ['Fotografía', 'Carreras', 'Juguete', 'Otro'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                onChanged: (v) => setState(() => _selectedCategory = v),
                decoration: const InputDecoration(labelText: 'Categoría'),
              ),
              DropdownButtonFormField<String>(
                value: _selectedCondition,
                items: ['Nuevo', 'Como nuevo', 'Usado'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                onChanged: (v) => setState(() => _selectedCondition = v),
                decoration: const InputDecoration(labelText: 'Condición'),
              ),
              const SizedBox(height: 12),
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
              const SizedBox(height: 20),
              ElevatedButton.icon(
                icon: const Icon(Icons.filter_alt),
                label: const Text('Aplicar filtros'),
                onPressed: _applyFilters,
                style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
