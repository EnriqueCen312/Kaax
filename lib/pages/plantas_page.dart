import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'agregar_planta_page.dart';

// Clase para manejar eventos de actualización de plantas
class PlantUpdateNotification extends Notification {
  final Map<String, dynamic> planta;
  PlantUpdateNotification(this.planta);
}

class PlantasPage extends StatefulWidget {
  final bool showAppBar;
  
  const PlantasPage({
    super.key,
    this.showAppBar = true,
  });

  @override
  State<PlantasPage> createState() => _PlantasPageState();
}

class _PlantasPageState extends State<PlantasPage> {
  final List<Map<String, dynamic>> _plantas = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargarPlantas();
  }

  Future<void> _cargarPlantas() async {
    setState(() {
      _isLoading = true;
    });

    try {
      print('Iniciando carga de plantas...');
      final response = await http.get(
        Uri.parse('https://api-kaax.onrender.com/kaax/plants/app/plant'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw TimeoutException('La conexión tardó demasiado tiempo');
        },
      );

      print('Código de estado: ${response.statusCode}');
      print('Cuerpo de la respuesta: ${response.body}');

      if (response.statusCode == 200) {
        if (response.body.isEmpty) {
          print('La respuesta está vacía');
          setState(() {
            _plantas.clear();
            _isLoading = false;
          });
          _mostrarMensaje('No hay plantas registradas', Colors.blue);
          return;
        }

        try {
          final dynamic data = jsonDecode(response.body);
          print('Datos recibidos: $data');
          
          setState(() {
            _plantas.clear();
            // Si es un objeto único, lo convertimos en una lista de un elemento
            if (data is Map<String, dynamic>) {
              print('Procesando planta única: ${data['name']}');
              _plantas.add({
                '_id': data['_id'],
                'nombre': data['name'],
                'tipo': data['type'],
                'descripcion': data['description'],
                'name': data['name'],
                'type': data['type'],
                'description': data['description'],
              });
            } 
            // Si es una lista, procesamos cada elemento
            else if (data is List<dynamic>) {
              for (var planta in data) {
                print('Procesando planta: ${planta['name']}');
                _plantas.add({
                  '_id': planta['_id'],
                  'nombre': planta['name'],
                  'tipo': planta['type'],
                  'descripcion': planta['description'],
                  'name': planta['name'],
                  'type': planta['type'],
                  'description': planta['description'],
                });
              }
            }
            _isLoading = false;
          });
          
          if (_plantas.isEmpty) {
            _mostrarMensaje('No hay plantas registradas', Colors.blue);
          } else {
            _mostrarMensaje('${_plantas.length} plantas cargadas', Colors.green);
          }
        } catch (e) {
          print('Error al procesar JSON: $e');
          _mostrarMensaje('Error al procesar los datos de las plantas', Colors.orange);
          setState(() => _isLoading = false);
        }
      } else {
        print('Error del servidor: ${response.statusCode}');
        _mostrarMensaje('Error al cargar plantas: ${response.statusCode}', Colors.orange);
        setState(() => _isLoading = false);
      }
    } catch (e) {
      print('Error de conexión: $e');
      _mostrarMensaje('Error de conexión: $e', Colors.red);
      setState(() => _isLoading = false);
    }
  }

  void _mostrarMensaje(String mensaje, Color color) {
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        action: color != Colors.green ? SnackBarAction(
          label: 'Reintentar',
          onPressed: _cargarPlantas,
          textColor: Colors.white,
        ) : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.showAppBar ? AppBar(
        title: const Text('Mis Plantas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _cargarPlantas,
            tooltip: 'Recargar plantas',
          ),
        ],
      ) : null,
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : _plantas.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.local_florist_outlined,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No hay plantas agregadas',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () => _agregarPlanta(context),
                        icon: const Icon(Icons.add),
                        label: const Text('Agregar Planta'),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _plantas.length,
                  itemBuilder: (context, index) {
                    final planta = _plantas[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _buildPlantCard(
                        index,
                        planta['nombre'] ?? '',
                        planta['tipo'] ?? '',
                      ),
                    );
                  },
                ),
      floatingActionButton: _plantas.isNotEmpty ? FloatingActionButton(
        onPressed: () => _agregarPlanta(context),
        child: const Icon(Icons.add),
      ) : null,
    );
  }

  Widget _buildPlantCard(int index, String name, String type) {
    final planta = _plantas[index];
    
    // Convertir las fechas de string a DateTime
    final DateTime createdAt = DateTime.parse(planta['createdAt'] ?? DateTime.now().toIso8601String());
    final DateTime updatedAt = DateTime.parse(planta['updatedAt'] ?? DateTime.now().toIso8601String());
    
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              child: Icon(
                Icons.local_florist,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            title: Text(
              name,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            subtitle: Text(type),
            trailing: IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => _editarPlanta(context, index),
            ),
          ),
          if (planta['description'] != null && planta['description'].toString().isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                planta['description'],
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          'Creada: ${_formatDate(createdAt)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.update, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          'Actualizada: ${_formatDate(updatedAt)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                _buildEstadoIndicator(planta),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  Widget _buildEstadoIndicator(Map<String, dynamic> planta) {
    final bool waterRelayActive = planta['waterRelayActive'] ?? false;
    
    final Color color = waterRelayActive ? Colors.blue : Colors.green;
    final String estado = waterRelayActive ? 'Regando' : 'Normal';
    final IconData icon = waterRelayActive ? Icons.water_drop : Icons.check_circle;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            estado,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _agregarPlanta(BuildContext context) async {
    final resultado = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AgregarPlantaPage()),
    );

    if (resultado != null && mounted) {
      setState(() {
        _plantas.add(resultado as Map<String, dynamic>);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Planta agregada exitosamente'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  Future<void> _editarPlanta(BuildContext context, int index) async {
    // Mostrar indicador de carga
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Cargando datos de la planta...'),
        duration: Duration(seconds: 1),
      ),
    );
    
    final planta = _plantas[index];
    Map<String, dynamic> plantaCompleta = {...planta};
    
    // Si la planta tiene ID, obtener los detalles completos de la API
    if (planta['_id'] != null) {
      try {
        final response = await http.get(
          Uri.parse('https://api-kaax.onrender.com/kaax/plants/app/plant/${planta['_id']}'),
          headers: {
            'Content-Type': 'application/json',
          },
        );
        
        if (response.statusCode == 200) {
          final responseData = jsonDecode(response.body);
          plantaCompleta = responseData;
          // Asegurar que los campos locales estén presentes
          plantaCompleta['nombre'] = plantaCompleta['name'];
          plantaCompleta['tipo'] = plantaCompleta['type'];
          plantaCompleta['descripcion'] = plantaCompleta['description'];
        } else {
          print('Error al obtener datos de la planta: ${response.statusCode}');
          print('Respuesta: ${response.body}');
        }
      } catch (e) {
        print('Error al conectar con el servidor: $e');
      }
    }
    
    if (!mounted) return;
    
    final resultado = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AgregarPlantaPage(
          plantaExistente: plantaCompleta,
          titulo: 'Editar Planta',
        ),
      ),
    );

    if (resultado != null && mounted) {
      setState(() {
        _plantas[index] = resultado as Map<String, dynamic>;
      });

      // Mostrar mensaje de éxito
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Planta actualizada exitosamente'),
          backgroundColor: Colors.green,
        ),
      );

      // Recargar los datos
      _cargarPlantas();
    }
  }
} 
