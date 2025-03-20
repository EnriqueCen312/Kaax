import 'package:http/http.dart' as http;
import 'dart:convert';

class AuthService {
  static const String baseUrl = 'https://api-kaax.onrender.com/kaax/users';
  String? _authToken;

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      print('Intentando login con: email: $email');
      
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_authToken',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      print('Código de estado: ${response.statusCode}');
      print('Respuesta del servidor: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        _authToken = responseData['token'];
        return {'success': true, 'data': responseData};
      } else {
        Map<String, dynamic> errorResponse = {};
        try {
          errorResponse = jsonDecode(response.body);
        } catch (e) {
          print('Error al decodificar respuesta: $e');
        }

        return {
          'success': false,
          'message': errorResponse['message'] ?? 'Credenciales inválidas. Por favor, verifica tus datos.'
        };
      }
    } catch (e) {
      print('Error en la petición: $e');
      return {
        'success': false,
        'message': 'Error de conexión. Por favor, verifica tu conexión a internet.'
      };
    }
  }

  Future<Map<String, dynamic>> register(
    String fullName,
    String email,
    String password,
    String birthDate,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'fullName': fullName,
          'email': email,
          'password': password,
          'birthDate': birthDate,
        }),
      );

      if (response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        _authToken = responseData['token'];
        return {'success': true, 'data': responseData};
      } else {
        return {
          'success': false,
          'message': 'Error en el registro. Por favor, intenta de nuevo.'
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error de conexión. Por favor, verifica tu conexión a internet.'
      };
    }
  }

  String? get token => _authToken;

  void logout() {
    _authToken = null;
  }
}