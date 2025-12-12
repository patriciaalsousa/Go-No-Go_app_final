import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:gonogo/controller/controller_children.dart';
import 'package:gonogo/models/utils/rotas-app.dart';
import 'package:gonogo/layers/domain/repositories/cloudinary_repository.dart';

class TelaAddCriancaEtapa3 extends StatefulWidget {
  final Map<String, dynamic> dadosAcumulados;
  const TelaAddCriancaEtapa3({super.key, required this.dadosAcumulados});

  @override
  State<TelaAddCriancaEtapa3> createState() => _TelaAddCriancaEtapa3State();
}

class _TelaAddCriancaEtapa3State extends State<TelaAddCriancaEtapa3> {
  final _key = GlobalKey<FormState>();
  final _tempoEletronicos = TextEditingController();
  final _tempoCasa = TextEditingController();
  final _tempoFora = TextEditingController();

  bool _salvando = false;

  Future<void> _finalizarCadastro() async {
    if (!_key.currentState!.validate()) return;

    setState(() => _salvando = true);

    try {
      String photoUrl = "";
      final XFile? photoFile = widget.dadosAcumulados['photo_file'];

      if (photoFile != null) {
        final cloudinaryRepo = GetIt.instance<CloudinaryRepository>();
        final url = await cloudinaryRepo.uploadImage(photoFile);
        if (url != null) photoUrl = url;
      }

      final dadosFinais = {
        ...widget.dadosAcumulados,
        "time_gadgets": _tempoEletronicos.text,
        "time_play": _tempoCasa.text,
        "time_out": _tempoFora.text,
        "photo_url": photoUrl,
      };

      final idCrianca = await ControllerChildren().registerChild(dadosFinais);

      if (mounted) {
        _popUpSucesso(idCrianca);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _salvando = false);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Erro: $e")));
      }
    }
  }

  void _popUpSucesso(String idCrianca) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text("Sucesso!",
            style: GoogleFonts.outfit(
                fontWeight: FontWeight.bold, color: const Color(0xFF2962C0))),
        content: Text(
            "Criança cadastrada.\nDeseja preencher o questionário SNAP-IV agora?",
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(fontSize: 16)),
        actionsAlignment: MainAxisAlignment.spaceEvenly,
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pushNamedAndRemoveUntil(
                context, RotasApp.menu, (r) => false),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child:
                Text("Depois", style: GoogleFonts.outfit(color: Colors.white)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pushNamed(context, RotasApp.addCriancaPerg,
                  arguments: idCrianca);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF48CC48),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: Text("Sim", style: GoogleFonts.outfit(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWeb = size.width > 800;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            width: isWeb ? 558 : size.width * 0.9,
            constraints: BoxConstraints(minHeight: size.height * 0.6),
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
                        Text('Dados da rotina',
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
                      _barraProgresso(true),
                      const SizedBox(width: 5),
                      _barraProgresso(true),
                    ],
                  ),
                  const SizedBox(height: 40),
                  _input("Tempo em frente de aparelhos eletrônicos (min)",
                      _tempoEletronicos),
                  const SizedBox(height: 16),
                  _input("Tempo que brinca em casa (min)", _tempoCasa),
                  const SizedBox(height: 16),
                  _input("Tempo que brinca fora de casa (min)", _tempoFora),
                  const SizedBox(height: 40),
                  SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _salvando ? null : _finalizarCadastro,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2962C0),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      child: _salvando
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text("Finalizar",
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

  Widget _input(String label, TextEditingController controller) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      validator: (v) => v!.isEmpty ? "Campo obrigatório" : null,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.roboto(color: Colors.grey[600]),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFF2962C0), width: 2)),
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
}
