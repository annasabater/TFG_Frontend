import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../provider/users_provider.dart';
import '../provider/cart_provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // Añadido para dotenv

class BalanceForm extends StatefulWidget {
  const BalanceForm({super.key});

  @override
  State<BalanceForm> createState() => _BalanceFormState();
}

class _BalanceFormState extends State<BalanceForm> {
  final _formKey = GlobalKey<FormState>();
  String _selectedCurrency = 'EUR';
  double _amount = 0;
  Map<String, dynamic> _balances = {};
  bool _loading = false;
  bool _submitting = false;

  static const List<String> _currencies = [
    'EUR',
    'USD',
    'GBP',
    'JPY',
    'CHF',
    'CAD',
    'AUD',
    'CNY',
    'HKD',
    'NZD',
  ];

  @override
  void initState() {
    super.initState();
    _fetchBalances();
  }

  Future<void> _fetchBalances() async {
    setState(() => _loading = true);
    try {
      final userId = context.read<UserProvider>().currentUser?.id;
      if (userId == null) {
        setState(() => _balances = {});
        return;
      }
      final serverUrl = dotenv.env['SERVER_URL'] ?? 'http://localhost:9000/api';
      final url = Uri.parse('$serverUrl/users/$userId/balance');
      final res = await http.get(url);
      if (res.statusCode == 200) {
        setState(() {
          _balances = json.decode(res.body);
        });
      } else {
        setState(() => _balances = {});
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al obtener saldo: ${res.statusCode}')),
        );
      }
    } catch (e) {
      setState(() => _balances = {});
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al obtener saldo: $e')));
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _addBalance() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);
    try {
      final userId = context.read<UserProvider>().currentUser?.id;
      if (userId == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Usuario no válido')));
        setState(() => _submitting = false);
        return;
      }
      final serverUrl = dotenv.env['SERVER_URL'] ?? 'http://localhost:9000';
      final url = Uri.parse('$serverUrl/api/users/$userId/balance');
      final res = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'currency': _selectedCurrency, 'amount': _amount}),
      );
      if (res.statusCode == 200) {
        await _fetchBalances();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Saldo añadido correctamente')),
        );
        // Refrescar balances globales si es posible
        try {
          final cartProv = Provider.of<CartProvider>(context, listen: false);
          await cartProv.fetchUserBalances(userId);
        } catch (_) {}
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al añadir saldo: ${res.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ingresar saldo')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child:
            _loading
                ? const Center(child: CircularProgressIndicator())
                : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Saldo actual:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    if (_balances.isEmpty)
                      const Text('No tienes saldo en ninguna moneda.')
                    else
                      Wrap(
                        spacing: 12,
                        children:
                            _balances.entries
                                .map(
                                  (e) =>
                                      Chip(label: Text('${e.key}: ${e.value}')),
                                )
                                .toList(),
                      ),
                    const Divider(height: 32),
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          DropdownButtonFormField<String>(
                            value: _selectedCurrency,
                            items:
                                _currencies
                                    .map(
                                      (c) => DropdownMenuItem(
                                        value: c,
                                        child: Text(c),
                                      ),
                                    )
                                    .toList(),
                            onChanged: (val) {
                              setState(() {
                                _selectedCurrency = val!;
                              });
                            },
                            decoration: const InputDecoration(
                              labelText: 'Moneda',
                            ),
                          ),
                          TextFormField(
                            decoration: const InputDecoration(
                              labelText: 'Cantidad',
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty)
                                return 'Introduce una cantidad';
                              if (double.tryParse(value) == null)
                                return 'Cantidad inválida';
                              if (double.tryParse(value)! <= 0)
                                return 'Debe ser mayor que 0';
                              return null;
                            },
                            onChanged: (value) {
                              _amount = double.tryParse(value) ?? 0;
                            },
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: _submitting ? null : _addBalance,
                            icon:
                                _submitting
                                    ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                    : const Icon(Icons.add),
                            label: const Text('Ingresar saldo'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
      ),
    );
  }
}
