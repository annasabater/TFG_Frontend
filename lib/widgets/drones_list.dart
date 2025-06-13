import 'package:flutter/material.dart';
import 'drone_form.dart';
import '../api/drone_api.dart';

class DronesList extends StatefulWidget {
  @override
  _DronesListState createState() => _DronesListState();
}

class _DronesListState extends State<DronesList> {
  List drones = [];

  @override
  void initState() {
    super.initState();
    _fetchDrones();
  }

  void _goToCreateDrone() async {
    final result = await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => DroneForm()));
    if (result == true) {
      // Si se creó un dron, recarga la lista
      await _fetchDrones();
    }
  }

  Future<void> _fetchDrones() async {
    final response = await DroneApi.getDrones();
    setState(() {
      drones = response;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Drones')),
      body: ListView.builder(
        itemCount: drones.length,
        itemBuilder: (context, index) {
          final drone = drones[index];
          return ListTile(title: Text(drone.name), subtitle: Text(drone.model));
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _goToCreateDrone,
        child: Icon(Icons.add),
      ),
    );
  }
}
