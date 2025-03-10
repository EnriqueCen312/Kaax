import 'package:flutter/material.dart';
import 'agregar_planta_page.dart';

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
  final List<Map<String, String>> _plantas = [
    {
      'nombre': 'Planta 1',
      'tipo': 'Suculenta',
      'descripcion': '',
    },
    {
      'nombre': 'Planta 2',
      'tipo': 'Helecho',
      'descripcion': '',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.showAppBar ? AppBar(
        title: const Text('Mis Plantas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _agregarPlanta(context),
          ),
        ],
      ) : null,
      body: _plantas.isEmpty
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
                    planta['nombre'] ?? '',
                    planta['tipo'] ?? '',
                  ),
                );
              },
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
        _plantas.add(resultado as Map<String, String>);
      });

      // Mostrar mensaje de éxito
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Planta agregada exitosamente'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          action: SnackBarAction(
            label: 'OK',
            textColor: Colors.white,
            onPressed: () {},
          ),
        ),
      );
    }
  }

  Widget _buildPlantCard(String name, String type) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
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
          onPressed: () {
            // TODO: Implementar edición de planta
          },
        ),
      ),
    );
  }
} 