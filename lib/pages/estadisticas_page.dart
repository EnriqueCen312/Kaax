import 'package:flutter/material.dart';

class EstadisticasPage extends StatelessWidget {
  final bool showAppBar;
  
  const EstadisticasPage({
    super.key,
    this.showAppBar = true,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: showAppBar ? AppBar(
        title: const Text('Estadísticas'),
      ) : null,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildStatCard(
            'Temperatura',
            '24°C',
            Icons.thermostat,
            Colors.orange,
          ),
          const SizedBox(height: 16),
          _buildStatCard(
            'Humedad Ambiental',
            '65%',
            Icons.water_drop,
            Colors.blue,
          ),
          const SizedBox(height: 16),
          _buildStatCard(
            'Humedad del Suelo',
            '75%',
            Icons.grass,
            Colors.green,
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Información de la Planta',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildInfoRow('Tipo de Planta:', 'Suculenta'),
                  _buildInfoRow('Última vez regada:', 'Hace 2 días'),
                  _buildInfoRow('Estado:', 'Saludable'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              icon,
              size: 40,
              color: color,
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          const SizedBox(width: 8),
          Text(value),
        ],
      ),
    );
  }
} 