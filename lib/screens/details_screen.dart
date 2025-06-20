// lib/screens/details_screen.dart
import 'package:flutter/material.dart';
import 'package:SkyNet/widgets/Layout.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';        
import '../provider/users_provider.dart';
import '../widgets/UserCard.dart';

class DetailsScreen extends StatefulWidget {
  const DetailsScreen({super.key});
  @override
  State<DetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
      Provider.of<UserProvider>(context, listen: false).loadUsers()
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<UserProvider>(context);

    return LayoutWrapper(
      title: 'Usuaris',
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  //  Estadístiques 
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Estadístiques d\'usuaris', style: Theme.of(context).textTheme.headlineSmall),
                          const SizedBox(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildStatCard(
                                context, 'Total',
                                provider.users.length.toString(),
                                Icons.people, Colors.blue
                              ),
                              _buildStatCard(
                                context, 'Rols únics',
                                provider.users.isEmpty
                                  ? 'N/A'
                                  : provider.users.map((u) => u.role).toSet().length.toString(),
                                Icons.badge, Colors.green
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  //  Cabecera lista con botones de Create/Delete 
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Llista d\'usuaris',
                          style: Theme.of(context).textTheme.headlineSmall),
                      Row(
                        children: [
                          ElevatedButton.icon(
                            icon: const Icon(Icons.person_add),
                            label: const Text('Afegir'),
                            onPressed: () => context.go('/editar'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).colorScheme.primary
                            ),
                          ),
                          const SizedBox(width: 12),
                          OutlinedButton.icon(
                            icon: const Icon(Icons.delete_outline),
                            label: const Text('Esborrar'),
                            onPressed: () => context.go('/borrar'),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  //  Lista o mensaje “no users” 
                  if (provider.isLoading)
                    const Center(child: CircularProgressIndicator()),
                  if (!provider.isLoading && provider.users.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32.0),
                        child: Column(
                          children: [
                            Icon(Icons.person_off, size: 64, color: Colors.grey),
                            SizedBox(height: 16),
                            Text('No s\'han trobat usuaris',
                              style: TextStyle(fontSize: 18, color: Colors.grey)),
                          ],
                        ),
                      ),
                    ),
                  if (provider.users.isNotEmpty)
                    ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: provider.users.length,
                      itemBuilder: (_, i) => UserCard(user: provider.users[i]),
                    ),

                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String value, IconData icon, Color color) {
    return Container(
      width: 150,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 40, color: color),
          const SizedBox(height: 12),
          Text(title,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color.withOpacity(0.8))),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }
}
