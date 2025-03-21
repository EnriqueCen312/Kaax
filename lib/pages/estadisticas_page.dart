import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'plantas_page.dart';

class EstadisticasPage extends StatefulWidget {
  final bool showAppBar;
  
  const EstadisticasPage({
    super.key,
    this.showAppBar = true,
  });

  @override
  State<EstadisticasPage> createState() => _EstadisticasPageState();
}

class _EstadisticasPageState extends State<EstadisticasPage> with WidgetsBindingObserver {
  Map<String, dynamic> _planta = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _cargarPlanta();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Recargar cuando la página recibe el foco
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _cargarPlanta();
    });
  }

  Future<void> _cargarPlanta() async {
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.get(
        Uri.parse('https://api-kaax.onrender.com/kaax/plants/app/plant'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final dynamic data = jsonDecode(response.body);
        setState(() {
          if (data is Map<String, dynamic>) {
            _planta = data;
          } else if (data is List<dynamic> && data.isNotEmpty) {
            _planta = data.first;
          }
          _isLoading = false;
        });
      } else {
        print('Error al cargar planta: ${response.statusCode}');
        setState(() => _isLoading = false);
        _mostrarError('Error al cargar la planta');
      }
    } catch (e) {
      print('Error de conexión: $e');
      if (mounted) {
        setState(() => _isLoading = false);
        _mostrarError('Error de conexión');
      }
    }
  }

  void _mostrarError(String mensaje) {
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'Reintentar',
          onPressed: _cargarPlanta,
          textColor: Colors.white,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<PlantUpdateNotification>(
      onNotification: (notification) {
        setState(() {
          _planta = notification.planta;
        });
        return true;
      },
      child: Scaffold(
        appBar: widget.showAppBar ? AppBar(
          title: const Text('Estadísticas'),
          backgroundColor: Colors.green.shade50,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _cargarPlanta,
              tooltip: 'Recargar datos',
            ),
          ],
        ) : null,
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.green.shade50,
                Colors.white,
              ],
            ),
          ),
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _buildStatCard(
                      'Temperatura',
                      '24°C',
                      Icons.thermostat_outlined,
                      Colors.orange.shade400,
                      context,
                    ),
                    const SizedBox(height: 16),
                    _buildStatCard(
                      'Humedad Ambiental',
                      '65%',
                      Icons.water_drop_outlined,
                      Colors.blue.shade400,
                      context,
                    ),
                    const SizedBox(height: 16),
                    _buildStatCard(
                      'Humedad del Suelo',
                      '75%',
                      Icons.grass_outlined,
                      Colors.green.shade400,
                      context,
                    ),
                    const SizedBox(height: 16),
                    _buildSimplePlantInfoCard(context),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color, BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color.withOpacity(0.1),
              Colors.white,
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(
                  icon,
                  size: 40,
                  color: color,
                ),
              ),
              const SizedBox(width: 20),
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
                  const SizedBox(height: 4),
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
      ),
    );
  }

  Widget _buildSimplePlantInfoCard(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.green.shade50,
              Colors.white,
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.local_florist,
                    color: Colors.green.shade700,
                    size: 30,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _planta['name'] ?? 'Sin nombre',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _buildInfoRow('Tipo de Planta:', _planta['type'] ?? 'No especificado'),
              if (_planta['description'] != null && _planta['description'].toString().isNotEmpty)
                _buildInfoRow('Descripción:', _planta['description']),
              const SizedBox(height: 16),
              Center(
                child: ElevatedButton.icon(
                  onPressed: () {
                    _cargarPlanta();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Actualizando datos...'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Actualizar Datos'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade100,
                    foregroundColor: Colors.green.shade700,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.green.shade100.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                color: Colors.green.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }
} 