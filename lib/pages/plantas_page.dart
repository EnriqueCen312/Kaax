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
  final List<Map<String, String>> _plantas = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.showAppBar ? AppBar(
        title: const Text('Mis Plantas'),
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
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => _editarPlanta(context, index),
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              color: Colors.red,
              onPressed: () => _confirmarEliminar(index),
            ),
          ],
        ),
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
    final resultado = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AgregarPlantaPage(
          plantaExistente: _plantas[index],
          titulo: 'Editar Planta',
        ),
      ),
    );

    if (resultado != null && mounted) {
      setState(() {
        _plantas[index] = resultado as Map<String, String>;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Planta actualizada exitosamente'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  void _confirmarEliminar(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Eliminar Planta'),
          content: const Text('¿Estás seguro que deseas eliminar esta planta?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  _plantas.removeAt(index);
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Planta eliminada exitosamente'),
                    backgroundColor: Colors.red,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                );
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );
  }
} 