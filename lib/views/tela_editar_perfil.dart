import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:gonogo/controller/controller_evaluator.dart';
import 'package:gonogo/models/utils/rotas-app.dart';
import 'package:get_it/get_it.dart';
import 'package:gonogo/layers/domain/repositories/cloudinary_repository.dart';

class TelaEditarPerfil extends StatefulWidget {
  const TelaEditarPerfil({super.key});

  @override
  State<TelaEditarPerfil> createState() => _TelaEditarPerfilState();
}

class _TelaEditarPerfilState extends State<TelaEditarPerfil> {
  // Controle de Estado
  bool _editando = false;
  bool _isLoading = true;
  bool _isSaving = false;

  // Dados
  XFile? _imagemSelecionada;
  String _urlImagemAtual = "";
  String _nomeAtual = "Usuário";
  String _emailAtualOriginal = "";

  // Controladores
  final _nomeController = TextEditingController();
  final _dataNascimentoController = TextEditingController();
  final _emailController = TextEditingController();
  final _instituicaoController = TextEditingController();

  String? _areaSelecionada;
  final List<String> _areas = [
    'Neuropsicologia Clínica',
    'Neuropsicologia Experimental',
    'Neuropsicologia Escolar',
    'Reabilitação Cognitiva',
    'Outra'
  ];

  final _dataMask = MaskTextInputFormatter(
    mask: '##/##/####',
    filter: {"#": RegExp(r'[0-9]')},
    type: MaskAutoCompletionType.lazy,
  );

  final _formKey = GlobalKey<FormState>();
  final Color corAzul = const Color(0xFF2962C0);

  @override
  void initState() {
    super.initState();
    _carregarDadosUsuario();
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _dataNascimentoController.dispose();
    _emailController.dispose();
    _instituicaoController.dispose();
    super.dispose();
  }

  Future<void> _carregarDadosUsuario() async {
    try {
      final dados = await ControllerEvaluator().seeProfile();

      if (mounted) {
        setState(() {
          final mapDados = dados[1];

          _nomeController.text = mapDados["nome"] ?? "";
          _nomeAtual = mapDados["nome"] ?? "Usuário";

          _emailController.text = dados[0] ?? "";
          _emailAtualOriginal = dados[0] ?? "";

          _urlImagemAtual = mapDados["foto_perfil"] ?? "";

          _dataNascimentoController.text = mapDados["nascimento"] ?? "";
          _instituicaoController.text = mapDados["instituicao"] ?? "";

          String areaSalva = mapDados["area"] ?? "";
          if (_areas.contains(areaSalva)) {
            _areaSelecionada = areaSalva;
          }

          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _sairDoApp() {
    Navigator.pushNamedAndRemoveUntil(
        context, RotasApp.login, (route) => false);
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    try {
      String urlFinal = _urlImagemAtual;
      if (_imagemSelecionada != null) {
        final cloudinaryRepo = GetIt.instance<CloudinaryRepository>();
        final url = await cloudinaryRepo.uploadImage(_imagemSelecionada!);
        if (url != null) {
          urlFinal = url;
        }
      }
      await ControllerEvaluator().updateUser(
        nome: _nomeController.text,
        photoUrl: urlFinal,
        currentEmail: _emailAtualOriginal,
        newEmail: _emailController.text,
        newPassword: "******",
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Perfil atualizado com sucesso!")),
        );
        setState(() {
          _nomeAtual = _nomeController.text;
          _urlImagemAtual = urlFinal;
          _editando = false;
          _imagemSelecionada = null;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Erro: $e")));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _gerenciarFoto() {
    showModalBottomSheet(
        context: context,
        builder: (ctx) => Wrap(children: [
              ListTile(
                  leading: const Icon(Icons.visibility),
                  title: const Text('Visualizar foto'),
                  onTap: () {
                    Navigator.pop(ctx);
                    _visualizarFotoDialog();
                  }),
              ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: const Text('Alterar foto'),
                  onTap: () {
                    Navigator.pop(ctx);
                    _selecionarImagemGaleria();
                  }),
            ]));
  }

  void _visualizarFotoDialog() {
    showDialog(
        context: context,
        builder: (ctx) => Dialog(
              child: SizedBox(
                  width: 300,
                  height: 300,
                  child: _imagemSelecionada != null
                      ? Image.file(File(_imagemSelecionada!.path),
                          fit: BoxFit.cover)
                      : (_urlImagemAtual.isNotEmpty
                          ? Image.network(_urlImagemAtual, fit: BoxFit.cover)
                          : Image.asset('assets/images/FotoAdd.jpg',
                              fit: BoxFit.cover))),
            ));
  }

  Future<void> _selecionarImagemGaleria() async {
    final picker = ImagePicker();
    try {
      final imagem = await picker.pickImage(source: ImageSource.gallery);
      if (imagem != null) setState(() => _imagemSelecionada = imagem);
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    return _editando ? _buildFormularioEdicao() : _buildMenuInicial();
  }

  // Tela Inicial (Menu)
  Widget _buildMenuInicial() {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () {
            Navigator.pop(context, RotasApp.principal);
          },
        ),
        title: Text(
          "Configuração",
          style: GoogleFonts.outfit(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: corAzul))
          : Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4285F4),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF4285F4).withValues(alpha: 0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        )
                      ],
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: Colors.white.withValues(alpha: 0.2),
                          backgroundImage: _urlImagemAtual.isNotEmpty
                              ? NetworkImage(_urlImagemAtual)
                              : const AssetImage('assets/images/FotoAdd.jpg')
                                  as ImageProvider,
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _nomeAtual,
                              style: GoogleFonts.outfit(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              "Avaliador",
                              style: GoogleFonts.outfit(
                                color: Colors.white.withValues(alpha: 0.8),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildMenuButton(
                    icon: Icons.assignment_ind_outlined,
                    text: "Editar conta",
                    onTap: () {
                      setState(() {
                        _editando = true;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildMenuButton(
                    icon: Icons.info_outline,
                    text: "Sobre o App",
                    onTap: () {
                      Navigator.pushNamed(context, RotasApp.sobre);
                    },
                  ),
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _sairDoApp,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        "Sair",
                        style: GoogleFonts.outfit(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }

  Widget _buildMenuButton({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 5,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF4285F4).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: const Color(0xFF4285F4), size: 20),
            ),
            const SizedBox(width: 16),
            Text(
              text,
              style: GoogleFonts.outfit(
                fontSize: 16,
                color: Colors.grey[700],
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }

  Widget _buildFormularioEdicao() {
    return Scaffold(
      backgroundColor: Colors.white,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () {
            setState(() {
              _editando = false;
            });
          },
        ),
        centerTitle: true,
        title: Text(
          "Perfil",
          style: GoogleFonts.outfit(
            color: Colors.black,
            fontSize: 22,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: 280,
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.topCenter,
                children: [
                  Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: corAzul,
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(40),
                        bottomRight: Radius.circular(40),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 140,
                    child: GestureDetector(
                      onTap: _gerenciarFoto,
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 4),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            )
                          ],
                        ),
                        child: CircleAvatar(
                          radius: 60,
                          backgroundColor: Colors.grey[200],
                          backgroundImage: _imagemSelecionada != null
                              ? FileImage(File(_imagemSelecionada!.path))
                              : (_urlImagemAtual.isNotEmpty
                                      ? NetworkImage(_urlImagemAtual)
                                      : const AssetImage(
                                          'assets/images/FotoAdd.jpg'))
                                  as ImageProvider,
                          child: Stack(
                            children: [
                              Align(
                                alignment: Alignment.bottomRight,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: corAzul,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.edit,
                                      color: Colors.white, size: 20),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Text("Dados Pessoais",
                style: GoogleFonts.outfit(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF292A2E))),
            Text("Avaliador",
                style: GoogleFonts.outfit(fontSize: 14, color: Colors.grey)),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildTextField(
                        label: "Nome completo",
                        controller: _nomeController,
                        validator: (v) =>
                            v!.isEmpty ? "Campo obrigatório" : null),
                    const SizedBox(height: 16),
                    _buildTextField(
                        label: "Data nascimento",
                        controller: _dataNascimentoController,
                        formatter: _dataMask,
                        hint: "DD/MM/AAAA",
                        validator: (v) =>
                            v!.length < 10 ? "Data inválida" : null,
                        keyboardType: TextInputType.number),
                    const SizedBox(height: 16),
                    _buildTextField(
                        label: "E-mail",
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress),
                    const SizedBox(height: 16),
                    _buildTextField(
                        label: "Instituição",
                        controller: _instituicaoController),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: _areaSelecionada,
                      decoration:
                          _inputDecoration("Selecione a área neuropsicológica"),
                      icon: const Icon(Icons.arrow_drop_down),
                      items: _areas.map((String area) {
                        return DropdownMenuItem<String>(
                            value: area,
                            child: Text(area,
                                style: GoogleFonts.outfit(fontSize: 14)));
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _areaSelecionada = newValue;
                        });
                      },
                    ),
                    const SizedBox(height: 40),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _salvar,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: corAzul,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                        ),
                        child: _isSaving
                            ? const CircularProgressIndicator(
                                color: Colors.white)
                            : Text("Salvar Alterações",
                                style: GoogleFonts.outfit(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white)),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
      {required String label,
      required TextEditingController controller,
      String? hint,
      TextInputFormatter? formatter,
      String? Function(String?)? validator,
      TextInputType keyboardType = TextInputType.text,
      bool readOnly = false}) {
    return TextFormField(
      controller: controller,
      decoration: _inputDecoration(label, hint: hint),
      inputFormatters: formatter != null ? [formatter] : [],
      validator: validator,
      keyboardType: keyboardType,
      readOnly: readOnly,
      style: GoogleFonts.outfit(fontSize: 16),
    );
  }

  InputDecoration _inputDecoration(String label, {String? hint}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      labelStyle: GoogleFonts.outfit(color: Colors.grey[600]),
      alignLabelWithHint: true,
      floatingLabelBehavior: FloatingLabelBehavior.always,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.grey)),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.grey)),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF2962C0), width: 2)),
    );
  }
}
