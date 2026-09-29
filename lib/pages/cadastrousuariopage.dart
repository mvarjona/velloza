import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:velloza/pages/validacaodadospage.dart';

class CadastroUsuario extends StatefulWidget {
  const CadastroUsuario({super.key});

  @override
  State<CadastroUsuario> createState() => _CadastroUsuarioState();
}

class _CadastroUsuarioState extends State<CadastroUsuario> {
  final _formKey = GlobalKey<FormState>();

  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _enderecoController = TextEditingController();
  final _cpfController = TextEditingController();
  final _placaMotoController = TextEditingController();

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _enderecoController.dispose();
    _cpfController.dispose();
    _placaMotoController.dispose();
    super.dispose();
  }

  void _avancarParaValidacao() {
    if (_formKey.currentState!.validate()) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ValidacaoDadosPage(
            nome: _nomeController.text.trim(),
            email: _emailController.text.trim(),
            endereco: _enderecoController.text.trim(),
            cpf: _cpfController.text.trim(),
            placaMoto: _placaMotoController.text.toUpperCase().trim(),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color.fromARGB(255, 241, 79, 4);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadastro de Usuário'),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Step Indicator
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 6,
                      decoration: BoxDecoration(
                        color: primaryColor,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      height: 6,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'Passo 1 de 2 - Dados Cadastrais',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Form Header
              const Text(
                'Criar Nova Conta',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Preencha seus dados pessoais e as informações da sua moto.',
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),

              const SizedBox(height: 24),

              // Campo: Nome
              TextFormField(
                controller: _nomeController,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  labelText: 'Nome Completo',
                  prefixIcon: const Icon(Icons.person_outline, color: primaryColor),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: primaryColor, width: 2),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Por favor, informe seu nome completo.';
                  }
                  if (value.trim().split(' ').length < 2) {
                    return 'Informe nome e sobrenome.';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Campo: E-mail
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'E-mail',
                  prefixIcon: const Icon(Icons.email_outlined, color: primaryColor),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: primaryColor, width: 2),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Por favor, informe seu e-mail.';
                  }
                  final emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                  if (!emailRegExp.hasMatch(value.trim())) {
                    return 'Digite um e-mail válido (ex: usuario@email.com).';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Campo: Endereço
              TextFormField(
                controller: _enderecoController,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  labelText: 'Endereço Completo',
                  prefixIcon: const Icon(Icons.home_outlined, color: primaryColor),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: primaryColor, width: 2),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Por favor, informe seu endereço.';
                  }
                  if (value.trim().length < 5) {
                    return 'Digite o endereço completo (Rua, Número, Bairro).';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Campo: CPF
              TextFormField(
                controller: _cpfController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  CpfInputFormatter(),
                ],
                decoration: InputDecoration(
                  labelText: 'CPF',
                  hintText: '000.000.000-00',
                  prefixIcon: const Icon(Icons.badge_outlined, color: primaryColor),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: primaryColor, width: 2),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Por favor, informe seu CPF.';
                  }
                  final digitsOnly = value.replaceAll(RegExp(r'\D'), '');
                  if (digitsOnly.length != 11) {
                    return 'CPF deve conter 11 dígitos.';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Campo: Placa da Moto
              TextFormField(
                controller: _placaMotoController,
                textCapitalization: TextCapitalization.characters,
                inputFormatters: [
                  LengthLimitingTextInputFormatter(8),
                  PlacaMotoFormatter(),
                ],
                decoration: InputDecoration(
                  labelText: 'Placa da Moto',
                  hintText: 'ABC-1234 ou ABC1D23',
                  prefixIcon: const Icon(Icons.two_wheeler, color: primaryColor),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: primaryColor, width: 2),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Por favor, informe a placa da moto.';
                  }
                  final cleanPlaca = value.trim().replaceAll('-', '').toUpperCase();
                  final placaPattern = RegExp(r'^[A-Z]{3}[0-9][A-Z0-9][0-9]{2}$');
                  if (!placaPattern.hasMatch(cleanPlaca)) {
                    return 'Placa inválida. Use o formato Mercosul (ABC1D23) ou Padrão (ABC-1234).';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 32),

              // Botão Avançar
              ElevatedButton(
                onPressed: _avancarParaValidacao,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  minimumSize: const Size(double.infinity, 55),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Próximo: Validação',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward, color: Colors.white),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

/// Formata entrada de CPF no formato 000.000.000-00
class CpfInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll(RegExp(r'\D'), '');

    if (text.length > 11) {
      return oldValue;
    }

    final buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      if (i == 3 || i == 6) {
        buffer.write('.');
      } else if (i == 9) {
        buffer.write('-');
      }
      buffer.write(text[i]);
    }

    final formattedText = buffer.toString();
    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: formattedText.length),
    );
  }
}

/// Formata a placa da moto em caixa alta e insere o hífen caso seja o padrão antigo
class PlacaMotoFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String upper = newValue.text.toUpperCase().replaceAll(' ', '');

    if (upper.length > 8) {
      return oldValue;
    }

    // Auto-insere hífen no formato antigo ABC-1234 caso digite 7 caracteres sem hífen
    if (upper.length == 7 && !upper.contains('-') && RegExp(r'^[A-Z]{3}[0-9]{4}$').hasMatch(upper)) {
      upper = '${upper.substring(0, 3)}-${upper.substring(3)}';
    }

    return TextEditingValue(
      text: upper,
      selection: TextSelection.collapsed(offset: upper.length),
    );
  }
}