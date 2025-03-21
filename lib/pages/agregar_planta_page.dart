import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AgregarPlantaPage extends StatefulWidget {
  final Map<String, dynamic>? plantaExistente;
  final String titulo;

  const AgregarPlantaPage({
    super.key,
    this.plantaExistente,
    this.titulo = 'Agregar Nueva Planta',
  });

  @override
  State<AgregarPlantaPage> createState() => _AgregarPlantaPageState();
}

class _AgregarPlantaPageState extends State<AgregarPlantaPage> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _tipoController = TextEditingController();
  final _descripcionController = TextEditingController();
  bool _isLoading = false;
  String? _plantaId;

  @override
  void initState() {
    super.initState();
    if (widget.plantaExistente != null) {
      _plantaId = widget.plantaExistente!['_id'] as String?;
      _nombreController.text = widget.plantaExistente!['nombre'] ?? widget.plantaExistente!['name'] ?? '';
      _tipoController.text = widget.plantaExistente!['tipo'] ?? widget.plantaExistente!['type'] ?? '';
      _descripcionController.text = widget.plantaExistente!['descripcion'] ?? widget.plantaExistente!['description'] ?? '';
    }
  }

  Future<void> _guardarPlanta() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      
      try {
        final planta = {
          'name': _nombreController.text,
          'type': _tipoController.text,
          'description': _descripcionController.text,
          // Valores por defecto para los campos adicionales
          'soilHumidity': 40,
          'ambientHumidity': 50,
          'ambientTemperature': 22,
          'shelterActive': true,
          'water': 60
        };
        
        // Si estamos editando, incluir el ID en el objeto
        if (_plantaId != null) {
          planta['_id'] = _plantaId as Object;
        }
        
        final url = 'https://api-kaax.onrender.com/kaax/plants/app/plant';
        print('URL: $url');
        print('Enviando datos de planta: ${jsonEncode(planta)}');
        print('Método: ${widget.plantaExistente != null ? "PUT" : "POST"}');
        
        final Uri uri = Uri.parse(url);
        final http.Response response;
        
        // Si estamos editando, usamos PUT, si es nueva, usamos POST
        if (widget.plantaExistente != null) {
          response = await http.put(
            uri,
            headers: {
              'Content-Type': 'application/json',
            },
            body: jsonEncode(planta),
          );
        } else {
          response = await http.post(
            uri,
            headers: {
              'Content-Type': 'application/json',
            },
            body: jsonEncode(planta),
          );
        }
        
        print('Código de respuesta: ${response.statusCode}');
        print('Respuesta completa: ${response.body}');
        
        if (response.statusCode == 200 || response.statusCode == 201) {
          if (!mounted) return;
          
          final mensaje = widget.plantaExistente != null 
              ? 'Planta actualizada exitosamente' 
              : 'Planta guardada exitosamente';
          
          // Intentar parsear la respuesta para obtener el ID si es una creación
          try {
            final responseData = jsonDecode(response.body);
            if (responseData['_id'] != null && _plantaId == null) {
              _plantaId = responseData['_id'];
            }
          } catch (e) {
            print('Error al parsear respuesta: $e');
          }
              
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(mensaje),
              backgroundColor: Colors.green,
            ),
          );
          
          Navigator.pop(context, {
            '_id': _plantaId,
            'nombre': _nombreController.text,
            'tipo': _tipoController.text,
            'descripcion': _descripcionController.text,
            'name': _nombreController.text,
            'type': _tipoController.text,
            'description': _descripcionController.text,
          });
        } else {
          if (!mounted) return;
          
          String errorMessage = widget.plantaExistente != null
              ? 'Error al actualizar la planta'
              : 'Error al guardar la planta';
              
          try {
            final responseData = jsonDecode(response.body);
            if (responseData['message'] != null) {
              errorMessage = 'Error: ${responseData['message']}';
            }
          } catch (e) {
            errorMessage = 'Error: ${response.body}';
          }
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 5),
            ),
          );
        }
      } catch (e) {
        print('Excepción al guardar planta: $e');
        if (!mounted) return;
        
        final mensaje = widget.plantaExistente != null
            ? 'Error al actualizar la planta: $e'
            : 'Error al guardar la planta: $e';
            
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(mensaje),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.titulo),
        backgroundColor: Colors.green.shade50,
      ),
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
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
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.green.shade100.withOpacity(0.3),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.local_florist,
                              size: 60,
                              color: Colors.green.shade700,
                            ),
                          ),
                          const SizedBox(height: 24),
                          _buildInputField(
                            controller: _nombreController,
                            label: 'Nombre de la planta',
                            icon: Icons.label_outline,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Por favor ingresa un nombre';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          _buildInputField(
                            controller: _tipoController,
                            label: 'Tipo de planta',
                            icon: Icons.category_outlined,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Por favor ingresa el tipo de planta';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          _buildInputField(
                            controller: _descripcionController,
                            label: 'Descripción',
                            icon: Icons.description_outlined,
                            maxLines: 3,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton.icon(
                        onPressed: _guardarPlanta,
                        icon: Icon(widget.plantaExistente != null ? Icons.save : Icons.add),
                        label: Text(
                          widget.plantaExistente != null ? 'Guardar Cambios' : 'Agregar Planta',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade400,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
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
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.green.shade100.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.green.shade600),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.green.shade200),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.green.shade200),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.green.shade400, width: 2),
          ),
          filled: true,
          fillColor: Colors.white,
        ),
        validator: validator,
      ),
    );
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _tipoController.dispose();
    _descripcionController.dispose();
    super.dispose();
  }
} 