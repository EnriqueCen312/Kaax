import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ControlPage extends StatefulWidget {
  final bool showAppBar;
  
  const ControlPage({
    super.key,
    this.showAppBar = true,
  });

  @override
  _ControlPageState createState() => _ControlPageState();
}

class _ControlPageState extends State<ControlPage> {
  double _currentTemperature = 28.6; // Temperatura inicial
  double _tempPromedio = 30.0; // Temperatura promedio
  final TextEditingController _tempPromedioController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.showAppBar ? AppBar(
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
            TextField(
              controller: _tempPromedioController,
              decoration: const InputDecoration(
                labelText: 'Temperatura Promedio',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                _tempPromedio = double.tryParse(value) ?? 30.0;
              },
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
            const SizedBox(height: 16),
            const Text(
              'Ajustar Temperatura',
              style: TextStyle(fontSize: 18),
            ),
            Slider(
              value: _currentTemperature,
              min: 0,
              max: 100,
              divisions: 100,
              label: _currentTemperature.round().toString(),
              onChanged: (double value) {
                setState(() {
                  _currentTemperature = value;
                });
                _sendTemperatureData(value);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _sendTemperatureData(double temperature) async {
    final response = await http.post(
      Uri.parse('https://api-kaax.onrender.com/kaax/temperatures/temperatura'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, double>{
        'tempPromedio': _tempPromedio,
        'tempActual': temperature,
      }),
    );

    if (response.statusCode == 200) {
      // La solicitud fue exitosa
      print('Datos enviados: ${response.body}');
    } else {
      // Manejo de errores
      print('Error al enviar datos: ${response.statusCode}');
    }
  }
} 