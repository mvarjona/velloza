import 'package:flutter/material.dart';
import 'package:gradient_icon/gradient_icon.dart';
import 'package:velloza/pages/cadastrousuariopage.dart';
import 'package:velloza/services/api_service.dart';

class PizzariaPage extends StatefulWidget {
  const PizzariaPage({super.key});

  @override
  State<PizzariaPage> createState() => _PizzariaPageState();
}

class _PizzariaPageState extends State<PizzariaPage> {
  final _userController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _userController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _efetuarLogin() async {
    final usuario = _userController.text.trim();
    final senha = _passwordController.text.trim();

    if (usuario.isEmpty || senha.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, preencha o usuário e a senha.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final response = await ApiService.login(
      usuario: usuario,
      senha: senha,
    );

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    if (response.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response.message),
          backgroundColor: Colors.green,
        ),
      );
      // Navegação para tela principal pós-login pode ser adicionada aqui
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response.message),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color.fromARGB(255, 241, 79, 4);

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Logo/Ícone
              const GradientIcon(
                icon: Icons.local_pizza,
                gradient: LinearGradient(
                  colors: [
                    primaryColor,
                    Colors.orange,
                  ],
                ),
                size: 110,
              ),

              const SizedBox(height: 12),
              const Text(
                'Pizzaria Delivery',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),

              const SizedBox(height: 48),

              // Campo de Usuário
              TextField(
                controller: _userController,
                decoration: InputDecoration(
                  labelText: 'Usuário ou E-mail',
                  prefixIcon: const Icon(Icons.person_outline, color: primaryColor),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: primaryColor, width: 2),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Campo de Senha
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Senha',
                  prefixIcon: const Icon(Icons.lock_outline, color: primaryColor),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: primaryColor, width: 2),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Botões esqueci minha senha / cadastre-se
              SizedBox(
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const CadastroUsuario(),
                          ),
                        );
                      },
                      child: const Text(
                        'Não tem uma conta? Cadastre-se',
                        style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Funcionalidade de recuperação em breve.')),
                        );
                      },
                      child: const Text(
                        'Esqueci minha senha',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Botão Entrar
              ElevatedButton(
                onPressed: _isLoading ? null : _efetuarLogin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  minimumSize: const Size(double.infinity, 55),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Entrar',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
