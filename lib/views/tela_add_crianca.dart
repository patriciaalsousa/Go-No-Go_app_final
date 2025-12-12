import 'dart:io';
import 'package:brasil_fields/brasil_fields.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gonogo/models/utils/rotas-app.dart';
import 'package:gonogo/models/utils/validator.dart';
import 'package:image_picker/image_picker.dart';

class TelaAddCrianca1 extends StatefulWidget {
  const TelaAddCrianca1({super.key});

  @override
  State<TelaAddCrianca1> createState() => _TelaAddCrianca1State();
}

class _TelaAddCrianca1State extends State<TelaAddCrianca1> {
  final _key = GlobalKey<FormState>();

  // Controladores
  final _nomeController = TextEditingController();
  final _dataNascimentoController = TextEditingController();
  final _dataAvaliacaoController = TextEditingController();

  // Variáveis
  XFile? _imagemSelecionada;
  String? _corSelecionada;
  final List<String> _cores = [
    "Branca",
    "Preta",
    "Parda",
    "Indígena",
    "Amarela"
  ];

  String? _sexoSelecionado;
  final List<String> _sexos = ['Masculino', 'Feminino'];
  Future<void> _selecionarImagem() async {
    final ImagePicker picker = ImagePicker();
    try {
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null) setState(() => _imagemSelecionada = image);
    } catch (e) {
      debugPrint("Erro ao selecionar imagem: $e");
    }
  }

  void _avancar() {
    if (_key.currentState!.validate()) {
      final dadosEtapa1 = {
        "photo_file": _imagemSelecionada,
        "name": _nomeController.text,
        "date_birth": _dataNascimentoController.text,
        "date_evaluation": _dataAvaliacaoController.text,
        "color": _corSelecionada,
        "sex": _sexoSelecionado ?? "Não informado",
      };

      Navigator.pushNamed(context, RotasApp.addCriancaEtapa2,
          arguments: dadosEtapa1);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWeb = size.width > 800;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Center(
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: Container(
            width: isWeb ? 558 : size.width * 0.9,
            constraints: BoxConstraints(minHeight: size.height * 0.8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: isWeb
                  ? [
                      BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 20)
                    ]
                  : null,
            ),
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _key,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back,
                          color: Color(0xFF292A2E)),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  Center(
                    child: Column(
                      children: [
                        Text('Adicionar Criança',
                            style: GoogleFonts.outfit(
                                fontSize: 24, color: const Color(0xFF292A2E))),
                        Text('Dados Pessoais',
                            style: GoogleFonts.outfit(
                                fontSize: 14, color: const Color(0xFF6C6A6A))),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _barraProgresso(true),
                      const SizedBox(width: 5),
                      _barraProgresso(false),
                      const SizedBox(width: 5),
                      _barraProgresso(false),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: GestureDetector(
                      onTap: _selecionarImagem,
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.grey[200],
                        backgroundImage: _imagemSelecionada != null
                            ? (kIsWeb
                                    ? NetworkImage(_imagemSelecionada!.path)
                                    : FileImage(File(_imagemSelecionada!.path)))
                                as ImageProvider
                            : null,
                        child: _imagemSelecionada == null
                            ? const Icon(Icons.camera_alt,
                                size: 30, color: Colors.grey)
                            : null,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  _input(
                      label: "Nome completo",
                      controller: _nomeController,
                      validator: Validator().validarNome),
                  const SizedBox(height: 16),
                  _input(
                      label: "Data de nascimento",
                      controller: _dataNascimentoController,
                      hint: "DD/MM/AAAA",
                      keyboardType: TextInputType.number,
                      formatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        DataInputFormatter()
                      ],
                      validator: Validator().validarDataNascimento),
                  const SizedBox(height: 16),
                  _input(
                      label: "Data de avaliação",
                      controller: _dataAvaliacaoController,
                      hint: "DD/MM/AAAA",
                      keyboardType: TextInputType.number,
                      formatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        DataInputFormatter()
                      ],
                      validator: Validator().validarDataNascimento),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: _corSelecionada,
                    decoration: _decoracao("Cor da pele"),
                    items: _cores
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                    onChanged: (v) => setState(() => _corSelecionada = v),
                    validator: (v) => v == null ? "Selecione a cor" : null,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: _sexoSelecionado,
                    decoration: _decoracao("Sexo"),
                    items: _sexos
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                    onChanged: (v) => setState(() => _sexoSelecionado = v),
                    validator: (v) => v == null ? "Selecione o sexo" : null,
                  ),
                  const SizedBox(height: 40),
                  SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _avancar,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2962C0),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      child: Text("Seguinte",
                          style: GoogleFonts.outfit(
                              fontSize: 18, color: Colors.white)),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _barraProgresso(bool active) {
    return Container(
      width: 40,
      height: 5,
      decoration: BoxDecoration(
        color: active ? const Color(0xFF2962C0) : const Color(0xFFC7D3EB),
        borderRadius: BorderRadius.circular(5),
      ),
    );
  }

  Widget _input(
      {required String label,
      required TextEditingController controller,
      String? hint,
      TextInputType? keyboardType,
      List<TextInputFormatter>? formatters,
      String? Function(String?)? validator}) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: formatters,
      validator: validator,
      decoration: _decoracao(label).copyWith(hintText: hint),
      style: GoogleFonts.roboto(),
    );
  }

  InputDecoration _decoracao(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: GoogleFonts.roboto(color: Colors.grey[600]),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.grey)),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF2962C0), width: 2)),
    );
  }
}
