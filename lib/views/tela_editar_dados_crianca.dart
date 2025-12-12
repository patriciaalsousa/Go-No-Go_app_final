import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:get_it/get_it.dart';
import 'package:gonogo/controller/controller_children.dart';
import 'package:gonogo/models/child.dart';
import 'package:gonogo/layers/domain/repositories/cloudinary_repository.dart';

class TelaEditarDadosCrianca extends StatefulWidget {
  final Child child;
  const TelaEditarDadosCrianca({super.key, required this.child});

  @override
  State<TelaEditarDadosCrianca> createState() => _TelaEditarDadosCriancaState();
}

class _TelaEditarDadosCriancaState extends State<TelaEditarDadosCrianca> {
  final _formKey = GlobalKey<FormState>();

  final _nomeController = TextEditingController();
  final _nascimentoController = TextEditingController();

  String? _sexoSelecionado;
  String? _corSelecionada;

  XFile? _novaImagem;
  final ImagePicker _picker = ImagePicker();

  bool _salvando = false;

  final List<String> _cores = [
    "Branca",
    "Preta",
    "Parda",
    "Indígena",
    "Amarela"
  ];
  final List<String> _sexos = ['Masculino', 'Feminino'];

  final _dataMask = MaskTextInputFormatter(
    mask: '##/##/####',
    filter: {"#": RegExp(r'[0-9]')},
    type: MaskAutoCompletionType.lazy,
  );

  @override
  void initState() {
    super.initState();
    _nomeController.text = widget.child.completeName;
    _nascimentoController.text = widget.child.date;

    if (_sexos.contains(widget.child.sex)) {
      _sexoSelecionado = widget.child.sex;
    }
    if (_cores.contains(widget.child.color)) {
      _corSelecionada = widget.child.color;
    }
  }

  Future<void> _selecionarImagem() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          _novaImagem = image;
        });
      }
    } catch (e) {
      debugPrint("Erro ao selecionar imagem: $e");
    }
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _salvando = true);

    try {
      if (_novaImagem != null) {
        final cloudinaryRepo = GetIt.instance<CloudinaryRepository>();
        final url = await cloudinaryRepo.uploadImage(_novaImagem!);

        if (url != null) {
          widget.child.sPhotoUrl = url;
        }
      }

      widget.child.sCompleteName = _nomeController.text;
      widget.child.sDate = _nascimentoController.text;
      widget.child.sSex = _sexoSelecionado ?? widget.child.sex;
      widget.child.sColor = _corSelecionada ?? widget.child.color;

      await ControllerChildren().updateChild(widget.child);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Dados atualizados com sucesso!")),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erro ao atualizar: $e")),
        );
        setState(() => _salvando = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color corAzul = const Color(0xFF2962C0);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Editar Dados',
          style: GoogleFonts.outfit(
            color: const Color(0xFF292A2E),
            fontSize: 22,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Center(
                child: GestureDetector(
                  onTap: _selecionarImagem,
                  child: Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border:
                              Border.all(color: Colors.grey.shade200, width: 4),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            )
                          ],
                        ),
                        child: CircleAvatar(
                          radius: 60,
                          backgroundColor: Colors.grey[200],
                          backgroundImage: _novaImagem != null
                              ? FileImage(File(_novaImagem!.path))
                              : (widget.child.photoUrl.isNotEmpty
                                  ? NetworkImage(widget.child.photoUrl)
                                  : AssetImage(
                                      widget.child.sex == "Masculino"
                                          ? 'assets/images/menino.png'
                                          : 'assets/images/menina.png',
                                    )) as ImageProvider,
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: corAzul,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: const Icon(Icons.camera_alt,
                              color: Colors.white, size: 20),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),
              _buildTextField(
                label: "Nome Completo",
                controller: _nomeController,
                validator: (v) => v!.isEmpty ? "Insira o nome" : null,
              ),
              const SizedBox(height: 20),
              _buildTextField(
                label: "Data de Nascimento",
                controller: _nascimentoController,
                formatter: _dataMask,
                keyboardType: TextInputType.number,
                validator: (v) => v!.length < 10 ? "Data inválida" : null,
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                initialValue: _sexoSelecionado,
                decoration: _inputDecoration("Sexo"),
                items: _sexos
                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
                onChanged: (v) => setState(() => _sexoSelecionado = v),
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                initialValue: _corSelecionada,
                decoration: _inputDecoration("Cor / Raça"),
                items: _cores
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (v) => setState(() => _corSelecionada = v),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _salvando ? null : _salvar,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: corAzul,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _salvando
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text("Salvar Alterações",
                          style: GoogleFonts.outfit(
                              fontSize: 18, color: Colors.white)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    TextInputFormatter? formatter,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      inputFormatters: formatter != null ? [formatter] : [],
      keyboardType: keyboardType,
      validator: validator,
      decoration: _inputDecoration(label),
      style: GoogleFonts.outfit(fontSize: 16),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: GoogleFonts.outfit(color: Colors.grey[600]),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.grey)),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF2962C0), width: 2)),
      filled: true,
      fillColor: Colors.white,
    );
  }
}
