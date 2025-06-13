import 'package:flutter/material.dart';
import 'package:your_project_name/api/drone_api.dart';

class DroneForm extends StatefulWidget {
  final bool isEdit;
  final Drone? drone;

  DroneForm({required this.isEdit, this.drone});

  @override
  _DroneFormState createState() => _DroneFormState();
}

class _DroneFormState extends State<DroneForm> {
  final _formKey = GlobalKey<FormState>();
  final List<String> _currencies = [
    'EUR',
    'USD',
    'GBP',
    'JPY',
    'CHF',
    'CAD',
    'AUD',
    'CNY',
    'HKD',
    'NZD'
  ];

  double? _price;
  String _currency = 'EUR';

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    final droneData = <String, dynamic>{
      if (!widget.isEdit || _price != null) 'price': _price,
      if (!widget.isEdit || _currency.isNotEmpty) 'currency': _currency,
    };

    if (widget.isEdit) {
      await DroneApi.updateDrone(widget.drone!.id, droneData);
    } else {
      await DroneApi.createDrone(droneData);
    }
    Navigator.of(context).pop(
      true,
    );
  }

  @override
  void initState() {
    super.initState();
    _price = widget.drone?.price;
    _currency = widget.drone?.currency ?? _currencies.first;
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            initialValue: _price != null ? _price.toString() : '',
            decoration: InputDecoration(labelText: 'Precio'),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (!widget.isEdit && (value == null || value.isEmpty))
                return 'El precio es obligatorio';
              if (value != null && value.isNotEmpty) {
                final n = double.tryParse(value);
                if (n == null || n <= 0) return 'Introduce un precio válido';
              }
              return null;
            },
            onSaved: (value) {
              _price = (value != null && value.isNotEmpty)
                  ? double.tryParse(value)
                  : null;
            },
          ),
          DropdownButtonFormField<String>(
            value: _currency,
            decoration: InputDecoration(labelText: 'Divisa'),
            items: _currencies
                .map((c) => DropdownMenuItem(
                      value: c,
                      child: Text(c),
                    ))
                .toList(),
            onChanged: (val) {
              if (val != null) setState(() => _currency = val);
            },
            validator: (value) {
              if (!widget.isEdit && (value == null || value.isEmpty))
                return 'La divisa es obligatoria';
              if (value != null && !_currencies.contains(value))
                return 'Divisa no permitida';
              return null;
            },
            onSaved: (value) {
              if (value != null) _currency = value;
            },
          ),
          ElevatedButton(
            onPressed: _submit,
            child: Text(widget.isEdit ? 'Actualizar Dron' : 'Crear Dron'),
          ),
        ],
      ),
    );
  }
}
