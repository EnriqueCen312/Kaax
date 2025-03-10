import 'package:flutter/material.dart';

class ControlPage extends StatelessWidget {
  final bool showAppBar;
  
  const ControlPage({
    super.key,
    this.showAppBar = true,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: showAppBar ? AppBar(
        title: const Text('Control de Riego'),
      ) : null,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildWaterLevelCard(),
          const SizedBox(height: 16),
          _buildWeatherCard(),
          const SizedBox(height: 16),
          _buildControlCard(),
        ],
      ),
    );
  }

  Widget _buildWaterLevelCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'Nivel de Agua',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: 0.75,
              minHeight: 20,
              backgroundColor: Colors.blue.shade100,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
            ),
            const SizedBox(height: 8),
            const Text(
              '75% Disponible',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Pronóstico',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Icon(Icons.cloud, size: 30),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Icon(Icons.warning, color: Colors.blue),
                  SizedBox(width: 8),
                  Text('Probabilidad de lluvia: 80%'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'Controles',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                // TODO: Implementar riego
              },
              icon: const Icon(Icons.water_drop),
              label: const Text('Regar Ahora'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
              ),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Cobertura Automática'),
              subtitle: const Text('Se activa cuando llueve'),
              value: true,
              onChanged: (bool value) {
                // TODO: Implementar control de cobertura
              },
            ),
          ],
        ),
      ),
    );
  }
} 