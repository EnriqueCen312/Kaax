import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

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
  Map<String, dynamic> _weatherData = {};
  bool _isLoading = true;
  String _selectedCity = 'Merida';
  bool _isWatering = false;
  Timer? _refreshTimer;
  double _waterLevel = 1.0; // 100% inicial
  
  final List<Map<String, String>> _cities = [
    {'name': 'Mérida', 'query': 'Merida'},
    {'name': 'Cancún', 'query': 'Cancun'},
    {'name': 'Ciudad de México', 'query': 'Mexico City'},
    {'name': 'Guadalajara', 'query': 'Guadalajara'},
    {'name': 'Monterrey', 'query': 'Monterrey'},
    {'name': 'Puebla', 'query': 'Puebla'},
    {'name': 'Tijuana', 'query': 'Tijuana'},
    {'name': 'Progreso', 'query': 'Progreso,MX'},
    {'name': 'Valladolid', 'query': 'Valladolid,MX'},
  ];

  @override
  void initState() {
    super.initState();
    _cargarPronostico();
    _obtenerEstadoRiego();
    // Configurar un timer para actualizar el estado cada 2 segundos
    _refreshTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      _obtenerEstadoRiego();
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _cargarPronostico() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final apiKey = 'e87750ed4384c2b65d89dd3bdefa9334';
      final ciudad = Uri.encodeComponent(_selectedCity);
      
      print('Consultando pronóstico para: $ciudad');
      
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final response = await http.get(
        Uri.parse('https://api.openweathermap.org/data/2.5/forecast?q=$ciudad,MX&appid=$apiKey&units=metric&lang=es&cnt=8&t=$timestamp'),
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw TimeoutException('La conexión tardó demasiado');
        },
      );

      print('Respuesta del servidor: ${response.statusCode}');

      if (response.statusCode == 200) {
        final decodedData = jsonDecode(response.body);
        
        // Obtenemos la lista de pronósticos
        final forecasts = decodedData['list'] as List;
        print('Número de pronósticos recibidos: ${forecasts.length}');
        
        // Encontramos la probabilidad más alta en las próximas 24 horas
        num maxPop = 0;
        for (var forecast in forecasts) {
          final pop = forecast['pop'] as num;
          print('Probabilidad encontrada: ${(pop * 100).round()}%');
          if (pop > maxPop) maxPop = pop;
        }
        
        print('Probabilidad máxima de lluvia: ${(maxPop * 100).round()}%');
        
        // Usamos el primer pronóstico para los datos actuales
        final firstForecast = forecasts[0];
        setState(() {
          _weatherData = {
            'main': firstForecast['main'],
            'weather': firstForecast['weather'],
            'name': decodedData['city']['name'],
            'pop': maxPop.toDouble(), // Convertimos a double después de encontrar el máximo
          };
          _isLoading = false;
        });
      } else if (response.statusCode == 401) {
        print('Error de autenticación: API key inválida');
        setState(() => _isLoading = false);
        _mostrarError('Error de autenticación con el servicio meteorológico');
      } else if (response.statusCode == 404) {
        print('Ciudad no encontrada');
        setState(() => _isLoading = false);
        _mostrarError('No se encontró la ciudad especificada');
      } else {
        print('Error al obtener el pronóstico: ${response.statusCode}');
        print('Mensaje de error: ${response.body}');
        setState(() => _isLoading = false);
        _mostrarError('Error al cargar el pronóstico: ${response.statusCode}');
      }
    } on TimeoutException {
      print('Error: Tiempo de espera agotado');
      setState(() => _isLoading = false);
      _mostrarError('La conexión tardó demasiado. Intenta de nuevo.');
    } catch (e) {
      print('Error de conexión: $e');
      setState(() => _isLoading = false);
      _mostrarError('Error de conexión: Verifica tu conexión a internet');
    }
  }

  Future<void> _obtenerEstadoRiego() async {
    try {
      print('Obteniendo estado del riego...');
      final response = await http.get(
        Uri.parse('https://api-kaax.onrender.com/kaax/plants/esp/plant'),
      );

      print('Respuesta del servidor (GET estado): ${response.statusCode}');
      print('Cuerpo de la respuesta (GET estado): ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _isWatering = data['waterRelayActive'] ?? false;
        });
        print('Estado del riego actualizado: $_isWatering');
      } else {
        print('Error al obtener estado del riego: ${response.statusCode}');
      }
    } catch (e) {
      print('Error al obtener estado del riego: $e');
    }
  }

  void _mostrarError(String mensaje) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'Reintentar',
          onPressed: _cargarPronostico,
          textColor: Colors.white,
        ),
      ),
    );
  }

  Future<void> _activarRiego() async {
    if (_waterLevel <= 0.1) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('No hay suficiente agua para regar'),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }

    try {
      print('Iniciando proceso de riego...');
      
      // Mostrar mensaje de inicio
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Iniciando riego...'),
          backgroundColor: Colors.green.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );

      print('Enviando petición para activar el riego (waterRelayActive: true)');
      // Activar el riego (waterRelayActive = true)
      final response = await http.put(
        Uri.parse('https://api-kaax.onrender.com/kaax/plants/esp/plant'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "waterRelayActive": true
        }),
      );

      print('Respuesta del servidor (activar): ${response.statusCode}');
      print('Cuerpo de la respuesta (activar): ${response.body}');

      if (response.statusCode != 200) {
        throw Exception('Error al activar el riego: ${response.statusCode}');
      }

      // Reducir el nivel de agua
      setState(() {
        _waterLevel = (_waterLevel - 0.1).clamp(0.0, 1.0);
      });

      print('Riego activado exitosamente. Esperando 1.5 segundos...');
      // Esperar 1.5 segundos
      await Future.delayed(const Duration(milliseconds: 1500));

      print('Enviando petición para desactivar el riego (waterRelayActive: false)');
      // Desactivar el riego (waterRelayActive = false)
      final responseDesactivar = await http.put(
        Uri.parse('https://api-kaax.onrender.com/kaax/plants/esp/plant'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "waterRelayActive": false
        }),
      );

      print('Respuesta del servidor (desactivar): ${responseDesactivar.statusCode}');
      print('Cuerpo de la respuesta (desactivar): ${responseDesactivar.body}');

      if (responseDesactivar.statusCode != 200) {
        throw Exception('Error al desactivar el riego: ${responseDesactivar.statusCode}');
      }

      print('Riego desactivado exitosamente');
      if (!mounted) return;

      // Mostrar mensaje de finalización
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Riego completado'),
          backgroundColor: Colors.green.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );

      print('Proceso de riego completado exitosamente');

    } catch (e) {
      print('Error en el proceso de riego:');
      print('Tipo de error: ${e.runtimeType}');
      print('Mensaje de error: $e');
      
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  void _rellenarTanque() {
    setState(() {
      _waterLevel = 1.0;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('¡Tanque rellenado exitosamente!'),
        backgroundColor: Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.showAppBar ? AppBar(
        title: const Text('Control de Riego'),
        backgroundColor: Colors.green.shade50,
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
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildWaterLevelCard(),
            const SizedBox(height: 16),
            _buildWeatherCard(),
            const SizedBox(height: 16),
            _buildSimpleControlCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildWaterLevelCard() {
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
              Colors.blue.shade50,
              Colors.white,
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                children: [
                  Icon(
                    Icons.water_drop,
                    color: Colors.blue.shade700,
                    size: 30,
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Nivel de Agua',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.shade100.withOpacity(0.5),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: LinearProgressIndicator(
                    value: _waterLevel,
                    minHeight: 25,
                    backgroundColor: Colors.blue.shade100,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _waterLevel <= 0.1 ? Colors.red.shade400 : Colors.blue.shade400
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                '${(_waterLevel * 100).round()}% Disponible',
                style: TextStyle(
                  fontSize: 18,
                  color: _waterLevel <= 0.1 ? Colors.red.shade700 : Colors.blue.shade700,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (_waterLevel <= 0.1) ...[
                const SizedBox(height: 16),
                Text(
                  '¡No olvides llenar tu tanque!',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.red.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: _rellenarTanque,
                  icon: const Icon(Icons.water),
                  label: const Text('Rellenar Tanque'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade400,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWeatherCard() {
    if (_isLoading) {
      return Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          height: 200,
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
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    // Obtener los datos del clima
    final temp = _weatherData['main']?['temp']?.round() ?? 0;
    final humidity = _weatherData['main']?['humidity'] ?? 0;
    final description = _weatherData['weather']?[0]?['description'] ?? 'No disponible';
    final icon = _weatherData['weather']?[0]?['icon'] ?? '01d';
    final cityName = _weatherData['name'] ?? _selectedCity;
    // Probabilidad de lluvia (viene como decimal entre 0 y 1)
    final rainProbability = ((_weatherData['pop'] ?? 0) * 100).round();

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
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.cloud,
                        color: Colors.green.shade700,
                        size: 30,
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Pronóstico',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: _cargarPronostico,
                    color: Colors.green.shade700,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _cities.firstWhere((city) => city['query'] == _selectedCity)['query'],
                    isExpanded: true,
                    icon: Icon(Icons.location_on, color: Colors.green.shade700),
                    items: _cities.map((city) {
                      return DropdownMenuItem(
                        value: city['query'],
                        child: Text(city['name']!),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          _selectedCity = newValue;
                        });
                        _cargarPronostico();
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      Image.network(
                        'https://openweathermap.org/img/w/$icon.png',
                        width: 50,
                        height: 50,
                      ),
                      Text(
                        description,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Text(
                        '$temp°C',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange.shade700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Temperatura',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Text(
                        '$humidity%',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Humedad',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.water_drop,
                      color: Colors.blue.shade700,
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Probabilidad de lluvia: $rainProbability%',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.blue.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSimpleControlCard() {
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
            children: [
              Row(
                children: [
                  Icon(
                    Icons.settings,
                    color: Colors.green.shade700,
                    size: 30,
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Controles',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _activarRiego,
                icon: Icon(
                  _isWatering ? Icons.water_drop : Icons.water_drop_outlined,
                  size: 24,
                ),
                label: Text(
                  _isWatering ? 'Regando...' : 'Regar Ahora',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isWatering ? Colors.blue.shade400 : Colors.green.shade400,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 