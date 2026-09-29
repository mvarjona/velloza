import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:velloza/services/api_service.dart';

class ValidacaoDadosPage extends StatefulWidget {
  final String nome;
  final String email;
  final String endereco;
  final String cpf;
  final String placaMoto;

  const ValidacaoDadosPage({
    super.key,
    required this.nome,
    required this.email,
    required this.endereco,
    required this.cpf,
    required this.placaMoto,
  });

  @override
  State<ValidacaoDadosPage> createState() => _ValidacaoDadosPageState();
}

class _ValidacaoDadosPageState extends State<ValidacaoDadosPage> {
  bool _rostoValidado = false;
  bool _processandoRosto = false;
  Uint8List? _rostoBytes;

  bool _cnhValidada = false;
  bool _processandoCnh = false;
  Uint8List? _cnhBytes;

  bool _motoValidada = false;
  bool _processandoMoto = false;
  Uint8List? _motoBytes;

  bool _enviandoCadastro = false;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _recuperarDadosPerdidosAndroid();
  }

  /// Recupera imagens no Android caso a Activity tenha sido recriada durante o uso da Câmera
  Future<void> _recuperarDadosPerdidosAndroid() async {
    try {
      final LostDataResponse response = await _picker.retrieveLostData();
      if (response.isEmpty || response.file == null) return;

      final bytes = await response.file!.readAsBytes();
      if (!mounted) return;

      setState(() {
        if (_rostoBytes == null) {
          _rostoBytes = bytes;
          _rostoValidado = true;
        } else if (_cnhBytes == null) {
          _cnhBytes = bytes;
          _cnhValidada = true;
        } else if (_motoBytes == null) {
          _motoBytes = bytes;
          _motoValidada = true;
        }
      });
    } catch (e) {
      debugPrint('Erro ao recuperar dados da câmera no Android: $e');
    }
  }

  Future<void> _capturarFotoRosto({bool useGallery = false}) async {
    if (!mounted) return;
    setState(() {
      _processandoRosto = true;
    });

    try {
      final XFile? photo = await _picker.pickImage(
        source: useGallery ? ImageSource.gallery : ImageSource.camera,
        maxWidth: 1000,
        maxHeight: 1000,
        imageQuality: 80,
      );

      if (photo != null) {
        final bytes = await photo.readAsBytes();
        if (mounted) {
          setState(() {
            _rostoBytes = bytes;
            _rostoValidado = true;
            _processandoRosto = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Foto do rosto capturada com sucesso!'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        }
      } else {
        if (mounted) {
          setState(() {
            _processandoRosto = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _processandoRosto = false;
        });
        _exibirDialogoOpcoesOuErro(
          tipo: 'Rosto',
          erro: e.toString(),
          onTentarCultura: () => _capturarFotoRosto(useGallery: false),
          onUsarGaleria: () => _capturarFotoRosto(useGallery: true),
        );
      }
    }
  }

  Future<void> _capturarFotoCnh({bool useGallery = false}) async {
    if (!mounted) return;
    setState(() {
      _processandoCnh = true;
    });

    try {
      final XFile? photo = await _picker.pickImage(
        source: useGallery ? ImageSource.gallery : ImageSource.camera,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 80,
      );

      if (photo != null) {
        final bytes = await photo.readAsBytes();
        if (mounted) {
          setState(() {
            _cnhBytes = bytes;
            _cnhValidada = true;
            _processandoCnh = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Foto da CNH capturada com sucesso!'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        }
      } else {
        if (mounted) {
          setState(() {
            _processandoCnh = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _processandoCnh = false;
        });
        _exibirDialogoOpcoesOuErro(
          tipo: 'CNH / Documento',
          erro: e.toString(),
          onTentarCultura: () => _capturarFotoCnh(useGallery: false),
          onUsarGaleria: () => _capturarFotoCnh(useGallery: true),
        );
      }
    }
  }

  Future<void> _capturarFotoMoto({bool useGallery = false}) async {
    if (!mounted) return;
    setState(() {
      _processandoMoto = true;
    });

    try {
      final XFile? photo = await _picker.pickImage(
        source: useGallery ? ImageSource.gallery : ImageSource.camera,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 80,
      );

      if (photo != null) {
        final bytes = await photo.readAsBytes();
        if (mounted) {
          setState(() {
            _motoBytes = bytes;
            _motoValidada = true;
            _processandoMoto = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Foto do Documento da Moto capturada com sucesso!'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        }
      } else {
        if (mounted) {
          setState(() {
            _processandoMoto = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _processandoMoto = false;
        });
        _exibirDialogoOpcoesOuErro(
          tipo: 'Documento da Moto',
          erro: e.toString(),
          onTentarCultura: () => _capturarFotoMoto(useGallery: false),
          onUsarGaleria: () => _capturarFotoMoto(useGallery: true),
        );
      }
    }
  }

  void _exibirDialogoOpcoesOuErro({
    required String tipo,
    required String erro,
    required VoidCallback onTentarCultura,
    required VoidCallback onUsarGaleria,
  }) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Capturar $tipo',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Ocorreu uma observação ao abrir a câmera diretamente. Escolha como deseja capturar a imagem:',
              style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Color.fromARGB(255, 241, 79, 4)),
              title: const Text('Abrir Câmera novamente'),
              onTap: () {
                Navigator.pop(ctx);
                onTentarCultura();
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: Colors.blue),
              title: const Text('Escolher foto da Galeria / Arquivos'),
              onTap: () {
                Navigator.pop(ctx);
                onUsarGaleria();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _finalizarCadastro() async {
    if (!_rostoValidado || _rostoBytes == null || !_cnhValidada || _cnhBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('É obrigatório capturar as fotos solicitadas para prosseguir!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (!mounted) return;
    setState(() {
      _enviandoCadastro = true;
    });

    try {
      final response = await ApiService.cadastrarUsuario(
        nome: widget.nome,
        email: widget.email,
        endereco: widget.endereco,
        cpf: widget.cpf,
        placaMoto: widget.placaMoto,
        rostoValidado: _rostoValidado,
        cnhValidada: _cnhValidada,
        bytesFotoRosto: _rostoBytes,
        bytesFotoCnh: _cnhBytes,
        bytesFotoMoto: _motoBytes ?? _cnhBytes,
      );

      if (!mounted) return;

      setState(() {
        _enviandoCadastro = false;
      });

      if (response.success) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Column(
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 70),
                SizedBox(height: 12),
                Text(
                  'Cadastro Concluído!',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Seu cadastro foi enviado e registrado com sucesso, ${widget.nome.split(' ').first}!'),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('• CPF: ${widget.cpf}', style: const TextStyle(fontSize: 13)),
                      Text('• Moto: ${widget.placaMoto}', style: const TextStyle(fontSize: 13)),
                      const Text('• Foto do Rosto: Capturada ✔', style: TextStyle(fontSize: 13, color: Colors.green)),
                      const Text('• Documento CNH: Capturado ✔', style: TextStyle(fontSize: 13, color: Colors.green)),
                      const Text('• Documento Moto: Capturado ✔', style: TextStyle(fontSize: 13, color: Colors.green)),
                      const Text('• Status API: Enviado ✔', style: TextStyle(fontSize: 13, color: Colors.blue)),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 241, 79, 4),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text(
                    'Ir para a Tela Inicial',
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Atenção: ${response.message}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'Reenviar',
              textColor: Colors.white,
              onPressed: () {
                if (mounted) {
                  _finalizarCadastro();
                }
              },
            ),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _enviandoCadastro = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao comunicar com a API: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    bool tudoValidado = _rostoValidado && _rostoBytes != null && _cnhValidada && _cnhBytes != null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Validação de Segurança'),
        backgroundColor: const Color.fromARGB(255, 241, 79, 4),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Step Progress Bar
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 6,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    height: 6,
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 241, 79, 4),
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
                'Passo 2 de 2 - Verificação de Identidade',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Card 1: Validação Facial (Rosto)
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade50,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.face_retouching_natural,
                            color: _rostoValidado ? Colors.green : const Color.fromARGB(255, 241, 79, 4),
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Reconhecimento Facial',
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                _rostoValidado ? 'Rosto capturado com sucesso' : 'Abra a câmera para tirar uma selfie (Obrigatório)',
                                style: TextStyle(
                                  color: _rostoValidado ? Colors.green : Colors.red.shade700,
                                  fontSize: 13,
                                  fontWeight: _rostoValidado ? FontWeight.normal : FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (_rostoValidado)
                          const Icon(Icons.check_circle, color: Colors.green, size: 28),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Camera / Photo Preview Container
                    Container(
                      height: 200,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade900,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          if (_rostoBytes != null)
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.memory(
                                _rostoBytes!,
                                width: double.infinity,
                                height: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),

                          // Oval frame line overlay
                          Container(
                            width: 120,
                            height: 150,
                            decoration: BoxDecoration(
                              shape: BoxShape.rectangle,
                              borderRadius: const BorderRadius.all(Radius.elliptical(120, 150)),
                              border: Border.all(
                                color: _rostoValidado
                                    ? Colors.green
                                    : (_processandoRosto ? Colors.orange : Colors.white),
                                width: 3,
                              ),
                            ),
                          ),

                          if (_processandoRosto)
                            Container(
                              color: Colors.black54,
                              child: const Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    CircularProgressIndicator(color: Colors.orange),
                                    SizedBox(height: 12),
                                    Text(
                                      'Abrindo câmera...',
                                      style: TextStyle(color: Colors.white, fontSize: 13),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          else if (_rostoBytes == null)
                            const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.camera_front, color: Colors.white54, size: 40),
                                SizedBox(height: 8),
                                Text(
                                  'Abra a câmera para foto do rosto',
                                  style: TextStyle(color: Colors.white70, fontSize: 12),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    ElevatedButton.icon(
                      onPressed: _processandoRosto ? null : () => _capturarFotoRosto(useGallery: false),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _rostoValidado ? Colors.green : const Color.fromARGB(255, 241, 79, 4),
                        minimumSize: const Size(double.infinity, 45),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      icon: Icon(
                        _rostoValidado ? Icons.refresh : Icons.camera_alt,
                        color: Colors.white,
                      ),
                      label: Text(
                        _rostoValidado ? 'Refazer Foto da Selfie' : 'Abrir Câmera para Selfie',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Card 2: Validação da CNH
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade50,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.badge,
                            color: _cnhValidada ? Colors.green : const Color.fromARGB(255, 241, 79, 4),
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Validação de Habilitação (CNH)',
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                _cnhValidada ? 'Documento capturado com sucesso' : 'Abra a câmera para fotografar a CNH (Obrigatório)',
                                style: TextStyle(
                                  color: _cnhValidada ? Colors.green : Colors.red.shade700,
                                  fontSize: 13,
                                  fontWeight: _cnhValidada ? FontWeight.normal : FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (_cnhValidada)
                          const Icon(Icons.check_circle, color: Colors.green, size: 28),
                      ],
                    ),

                    const SizedBox(height: 16),

                    Container(
                      height: 180,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _cnhValidada
                              ? Colors.green
                              : (_processandoCnh ? Colors.orange : Colors.grey.shade300),
                          width: 2,
                        ),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          if (_cnhBytes != null)
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.memory(
                                _cnhBytes!,
                                width: double.infinity,
                                height: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),

                          if (_processandoCnh)
                            Container(
                              color: Colors.white70,
                              child: const Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    CircularProgressIndicator(color: Colors.orange),
                                    SizedBox(height: 12),
                                    Text(
                                      'Abrindo câmera...',
                                      style: TextStyle(color: Colors.black87, fontSize: 13),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          else if (_cnhBytes == null)
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.credit_card, color: Colors.grey.shade400, size: 45),
                                const SizedBox(height: 8),
                                Text(
                                  'Fotografar CNH com a Câmera',
                                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    ElevatedButton.icon(
                      onPressed: _processandoCnh ? null : () => _capturarFotoCnh(useGallery: false),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _cnhValidada ? Colors.green : const Color.fromARGB(255, 241, 79, 4),
                        minimumSize: const Size(double.infinity, 45),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      icon: Icon(
                        _cnhValidada ? Icons.refresh : Icons.camera_alt,
                        color: Colors.white,
                      ),
                      label: Text(
                        _cnhValidada ? 'Refazer Foto da CNH' : 'Abrir Câmera para CNH',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Card 3: Documento da Moto (CRLV)
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade50,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.two_wheeler,
                            color: _motoValidada ? Colors.green : const Color.fromARGB(255, 241, 79, 4),
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Documento da Moto (CRLV)',
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                _motoValidada ? 'Documento da moto capturado com sucesso' : 'Fotografe o documento/CRLV da moto',
                                style: TextStyle(
                                  color: _motoValidada ? Colors.green : Colors.grey.shade700,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (_motoValidada)
                          const Icon(Icons.check_circle, color: Colors.green, size: 28),
                      ],
                    ),

                    const SizedBox(height: 16),

                    Container(
                      height: 180,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _motoValidada
                              ? Colors.green
                              : (_processandoMoto ? Colors.orange : Colors.grey.shade300),
                          width: 2,
                        ),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          if (_motoBytes != null)
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.memory(
                                _motoBytes!,
                                width: double.infinity,
                                height: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),

                          if (_processandoMoto)
                            Container(
                              color: Colors.white70,
                              child: const Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    CircularProgressIndicator(color: Colors.orange),
                                    SizedBox(height: 12),
                                    Text(
                                      'Abrindo câmera...',
                                      style: TextStyle(color: Colors.black87, fontSize: 13),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          else if (_motoBytes == null)
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.file_present, color: Colors.grey.shade400, size: 45),
                                const SizedBox(height: 8),
                                Text(
                                  'Fotografar CRLV / Documento da Moto',
                                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    ElevatedButton.icon(
                      onPressed: _processandoMoto ? null : () => _capturarFotoMoto(useGallery: false),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _motoValidada ? Colors.green : const Color.fromARGB(255, 241, 79, 4),
                        minimumSize: const Size(double.infinity, 45),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      icon: Icon(
                        _motoValidada ? Icons.refresh : Icons.camera_alt,
                        color: Colors.white,
                      ),
                      label: Text(
                        _motoValidada ? 'Refazer Foto da Moto' : 'Abrir Câmera para Doc. Moto',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Submit Button
            ElevatedButton(
              onPressed: (tudoValidado && !_enviandoCadastro) ? _finalizarCadastro : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 241, 79, 4),
                disabledBackgroundColor: Colors.grey.shade300,
                minimumSize: const Size(double.infinity, 55),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: tudoValidado ? 4 : 0,
              ),
              child: _enviandoCadastro
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text(
                      'Concluir e Enviar Cadastro',
                      style: TextStyle(
                        color: tudoValidado ? Colors.white : Colors.grey.shade600,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}


