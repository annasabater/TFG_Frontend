import 'package:flutter/material.dart';

class DroneForm extends StatefulWidget {
  final void Function({
    required String model,
    required double price,
    String? description,
    String? type,
    String? condition,
    String? location,
    String? contact,
    String? category,
  })
  onSubmit;
  final Map<String, dynamic>? initialData;

  const DroneForm({super.key, required this.onSubmit, this.initialData});

  @override
  State<DroneForm> createState() => _DroneFormState();
}

class _DroneFormState extends State<DroneForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _modelCtrl;
  late final TextEditingController _priceCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _typeCtrl;
  late final TextEditingController _conditionCtrl;
  late final TextEditingController _locationCtrl;
  late final TextEditingController _contactCtrl;
  late final TextEditingController _categoryCtrl;

  @override
  void initState() {
    super.initState();
    final d = widget.initialData ?? {};
    _modelCtrl = TextEditingController(text: d['model'] ?? '');
    _priceCtrl = TextEditingController(text: d['price']?.toString() ?? '');
    _descCtrl = TextEditingController(text: d['description'] ?? '');
    _typeCtrl = TextEditingController(text: d['type'] ?? '');
    _conditionCtrl = TextEditingController(text: d['condition'] ?? '');
    _locationCtrl = TextEditingController(text: d['location'] ?? '');
    _contactCtrl = TextEditingController(text: d['contact'] ?? '');
    _categoryCtrl = TextEditingController(text: d['category'] ?? '');
  }

  @override
  void dispose() {
    _modelCtrl.dispose();
    _priceCtrl.dispose();
    _descCtrl.dispose();
    _typeCtrl.dispose();
    _conditionCtrl.dispose();
    _locationCtrl.dispose();
    _contactCtrl.dispose();
    _categoryCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    widget.onSubmit(
      model: _modelCtrl.text.trim(),
      price: double.tryParse(_priceCtrl.text.trim()) ?? 0,
      description: _descCtrl.text.trim(),
      type: _typeCtrl.text.trim(),
      condition: _conditionCtrl.text.trim(),
      location: _locationCtrl.text.trim(),
      contact: _contactCtrl.text.trim(),
      category: _categoryCtrl.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: ListView(
        shrinkWrap: true,
        children: [
          TextFormField(
            controller: _modelCtrl,
            decoration: const InputDecoration(labelText: 'Modelo'),
            validator: (v) => v == null || v.isEmpty ? 'Obligatorio' : null,
          ),
          TextFormField(
            controller: _priceCtrl,
            decoration: const InputDecoration(labelText: 'Precio'),
            keyboardType: TextInputType.number,
            validator:
                (v) =>
                    v == null || double.tryParse(v) == null
                        ? 'Precio inválido'
                        : null,
          ),
          TextFormField(
            controller: _descCtrl,
            decoration: const InputDecoration(labelText: 'Descripción'),
          ),
          TextFormField(
            controller: _typeCtrl,
            decoration: const InputDecoration(labelText: 'Tipo'),
          ),
          TextFormField(
            controller: _conditionCtrl,
            decoration: const InputDecoration(labelText: 'Condición'),
          ),
          TextFormField(
            controller: _locationCtrl,
            decoration: const InputDecoration(labelText: 'Ubicación'),
          ),
          TextFormField(
            controller: _contactCtrl,
            decoration: const InputDecoration(labelText: 'Contacto'),
          ),
          TextFormField(
            controller: _categoryCtrl,
            decoration: const InputDecoration(labelText: 'Categoría'),
          ),
          const SizedBox(height: 20),
          ElevatedButton(onPressed: _submit, child: const Text('Guardar')),
        ],
      ),
    );
  }
}
