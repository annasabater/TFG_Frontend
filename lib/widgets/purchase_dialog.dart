//lib/widgets/purchase_dialog.dart
import 'package:flutter/material.dart';
import '../models/shipping_info.dart';

Future<ShippingInfo?> showPurchaseDialog(BuildContext ctx) {
  final full = TextEditingController();
  final addr = TextEditingController();
  final city = TextEditingController();
  final tel  = TextEditingController();

  return showDialog<ShippingInfo>(
    context: ctx,
    builder: (_) => AlertDialog(
      title: const Text('Confirmar compra'),
      content: SingleChildScrollView(
        child: Column(
          children: [
            TextField(controller: full, decoration: const InputDecoration(labelText: 'Nom complet')),
            TextField(controller: addr, decoration: const InputDecoration(labelText: 'Adreça')),
            TextField(controller: city, decoration: const InputDecoration(labelText: 'Ciutat')),
            TextField(controller: tel,  decoration: const InputDecoration(labelText: 'Telèfon')),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel·lar')),
        ElevatedButton(
          onPressed: () {
            if (full.text.isEmpty || addr.text.isEmpty) return;
            Navigator.pop(
              ctx,
              ShippingInfo(
                address : addr.text.trim(),
                phone   : tel.text.trim(),
              ),
            );
          },
          child: const Text('Confirmar'),
        ),
      ],
    ),
  );
}
