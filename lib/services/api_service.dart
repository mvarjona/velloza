import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// Resultado padronizado para as chamadas de API
class ApiResponse {
  final bool success;
  final String message;
  final dynamic data;
  final int? statusCode;

  ApiResponse({
    required this.success,
    required this.message,
    this.data,
    this.statusCode,
  });
}

class ApiService {
  /// URL base da API backend (C:\Projetos\Pizzaria)
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://192.168.222.243:5050';
    } else if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://192.168.222.243:5050';
    }
    return 'http://192.168.222.243:5050';
  }

  /// Timeout padrão para requisições de rede (10 segundos)
  static const Duration _timeoutDuration = Duration(seconds: 10);

  /// Headers padrões das requisições JSON
  static Map<String, String> get _headers => {
    'Content-Type': 'application/json; charset=UTF-8',
    'Accept': 'application/json',
  };

  /// Método para realizar o cadastro do usuário/entregador
  static Future<ApiResponse> cadastrarUsuario({
    required String nome,
    required String email,
    required String endereco,
    required String cpf,
    required String placaMoto,
    String? senha,
    bool rostoValidado = false,
    bool cnhValidada = false,
    List<int>? bytesFotoRosto,
    List<int>? bytesFotoCnh,
    List<int>? bytesFotoMoto,
  }) async {
    final url = Uri.parse('$baseUrl/api/entregadores/cadastrar');

    try {
      final request = http.MultipartRequest('POST', url);

      // Campos de texto do formulário (com aliases em PascalCase e camelCase para C#)
      final senhaFinal = (senha != null && senha.isNotEmpty) ? senha : 'senha123';
      
      request.fields['nome'] = nome;
      request.fields['Nome'] = nome;

      request.fields['email'] = email;
      request.fields['Email'] = email;

      request.fields['endereco'] = endereco;
      request.fields['Endereco'] = endereco;

      request.fields['cpf'] = cpf;
      request.fields['Cpf'] = cpf;

      request.fields['placaMoto'] = placaMoto;
      request.fields['PlacaMoto'] = placaMoto;
      request.fields['placaDaMoto'] = placaMoto;
      request.fields['PlacaDaMoto'] = placaMoto;
      request.fields['placa'] = placaMoto;
      request.fields['Placa'] = placaMoto;

      request.fields['senha'] = senhaFinal;
      request.fields['Senha'] = senhaFinal;

      request.fields['telefone'] = '11999999999';
      request.fields['Telefone'] = '11999999999';

      request.fields['tipoVeiculo'] = 'Moto';
      request.fields['TipoVeiculo'] = 'Moto';

      request.fields['rostoValidado'] = rostoValidado.toString();
      request.fields['RostoValidado'] = rostoValidado.toString();

      request.fields['cnhValidada'] = cnhValidada.toString();
      request.fields['CnhValidada'] = cnhValidada.toString();

      // Imagem padrão JPEG em bytes para validação
      final dummyJpg = <int>[
        255,
        216,
        255,
        224,
        0,
        10,
        74,
        70,
        73,
        70,
        0,
        1,
        1,
        1,
        0,
        96,
        0,
        96,
        0,
        0,
        255,
        219,
      ];

      final rostoBytes = (bytesFotoRosto != null && bytesFotoRosto.isNotEmpty)
          ? bytesFotoRosto
          : (bytesFotoCnh ?? dummyJpg);
      final cnhBytes = (bytesFotoCnh != null && bytesFotoCnh.isNotEmpty)
          ? bytesFotoCnh
          : (bytesFotoRosto ?? dummyJpg);
      final motoBytes = (bytesFotoMoto != null && bytesFotoMoto.isNotEmpty)
          ? bytesFotoMoto
          : (bytesFotoCnh ?? bytesFotoRosto ?? dummyJpg);

      // Foto do Rosto (com aliases)
      request.files.add(
        http.MultipartFile.fromBytes(
          'fotoRosto',
          rostoBytes,
          filename: 'rosto.jpg',
        ),
      );
      request.files.add(
        http.MultipartFile.fromBytes(
          'fotoPerfil',
          rostoBytes,
          filename: 'rosto.jpg',
        ),
      );

      // Foto da CNH / Habilitação (com aliases)
      request.files.add(
        http.MultipartFile.fromBytes(
          'fotoHabilitacao',
          cnhBytes,
          filename: 'cnh.jpg',
        ),
      );
      request.files.add(
        http.MultipartFile.fromBytes(
          'cnh',
          cnhBytes,
          filename: 'cnh.jpg',
        ),
      );

      // Foto do Documento da Moto (com todos os aliases esperados pelo backend C#)
      request.files.add(
        http.MultipartFile.fromBytes(
          'fotoDocumentoMoto',
          motoBytes,
          filename: 'moto.jpg',
        ),
      );
      request.files.add(
        http.MultipartFile.fromBytes(
          'fotoMoto',
          motoBytes,
          filename: 'moto.jpg',
        ),
      );
      request.files.add(
        http.MultipartFile.fromBytes(
          'documentoMoto',
          motoBytes,
          filename: 'moto.jpg',
        ),
      );
      request.files.add(
        http.MultipartFile.fromBytes(
          'fotoVeiculo',
          motoBytes,
          filename: 'moto.jpg',
        ),
      );
      request.files.add(
        http.MultipartFile.fromBytes(
          'documentoVeiculo',
          motoBytes,
          filename: 'moto.jpg',
        ),
      );

      if (kDebugMode) {
        debugPrint('[ApiService] Enviando Multipart POST para $url');
        debugPrint('[ApiService] Fields: ${request.fields}');
      }

      final streamedResponse = await request.send().timeout(_timeoutDuration);
      final response = await http.Response.fromStream(streamedResponse);

      if (kDebugMode) {
        debugPrint('[ApiService] Resposta Status: ${response.statusCode}');
        debugPrint('[ApiService] Resposta Body: ${response.body}');
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        dynamic data;
        try {
          data = jsonDecode(response.body);
        } catch (_) {
          data = response.body;
        }

        return ApiResponse(
          success: true,
          message: (data is Map && data['message'] != null)
              ? data['message']
              : 'Cadastro realizado com sucesso!',
          data: data,
          statusCode: response.statusCode,
        );
      } else {
        dynamic errorData;
        try {
          errorData = jsonDecode(response.body);
        } catch (_) {}

        final errorMessage =
            errorData != null &&
                errorData is Map &&
                errorData['message'] != null
            ? errorData['message']
            : 'Erro no servidor (${response.statusCode})';

        return ApiResponse(
          success: false,
          message: errorMessage,
          statusCode: response.statusCode,
        );
      }
    } on SocketException catch (e) {
      if (kDebugMode) debugPrint('[ApiService] SocketException: $e');
      return ApiResponse(
        success: false,
        message:
            'Não foi possível conectar ao servidor em $baseUrl. Verifique se a API backend está rodando.',
      );
    } on http.ClientException catch (e) {
      if (kDebugMode) debugPrint('[ApiService] ClientException: $e');
      return ApiResponse(
        success: false,
        message:
            'Erro de conexão HTTP (${e.message}). Se estiver na Web, verifique se o servidor backend em $baseUrl está ativo e com CORS liberado.',
      );
    } catch (e) {
      if (kDebugMode) debugPrint('[ApiService] Erro inesperado: $e');
      return ApiResponse(
        success: false,
        message: 'Falha inesperada ao cadastrar: $e',
      );
    }
  }

  /// Método para autenticar/login do usuário
  static Future<ApiResponse> login({
    required String usuario,
    required String senha,
  }) async {
    final url = Uri.parse('$baseUrl/api/login');

    final body = jsonEncode({'usuario': usuario, 'senha': senha});

    try {
      final response = await http
          .post(url, headers: _headers, body: body)
          .timeout(_timeoutDuration);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return ApiResponse(
          success: true,
          message: data['message'] ?? 'Login realizado com sucesso!',
          data: data,
          statusCode: response.statusCode,
        );
      } else {
        dynamic errorData;
        try {
          errorData = jsonDecode(response.body);
        } catch (_) {}

        final errorMessage = errorData != null && errorData['message'] != null
            ? errorData['message']
            : 'Usuário ou senha incorretos (${response.statusCode})';

        return ApiResponse(
          success: false,
          message: errorMessage,
          statusCode: response.statusCode,
        );
      }
    } on SocketException {
      return ApiResponse(
        success: false,
        message:
            'Não foi possível conectar ao servidor em $baseUrl. Verifique se a API backend está rodando.',
      );
    } on http.ClientException catch (e) {
      return ApiResponse(
        success: false,
        message: 'Erro na conexão HTTP: ${e.message}',
      );
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Falha inesperada ao efetuar login: $e',
      );
    }
  }
}
