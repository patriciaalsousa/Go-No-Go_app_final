import 'package:brasil_fields/brasil_fields.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gonogo/models/utils/rotas-app.dart';

class TelaAddCriancaEtapa2 extends StatefulWidget {
  final Map<String, dynamic> dadosEtapa1;
  const TelaAddCriancaEtapa2({super.key, required this.dadosEtapa1});

  @override
  State<TelaAddCriancaEtapa2> createState() => _TelaAddCriancaEtapa2State();
}

class _TelaAddCriancaEtapa2State extends State<TelaAddCriancaEtapa2> {
  final _key = GlobalKey<FormState>();
  final _rendaController = TextEditingController();

  void _avancar() {
    if (_key.currentState!.validate()) {
      final dadosEtapa2 = {
        ...widget.dadosEtapa1,
        "income": _rendaController.text,
      };
      Navigator.pushNamed(context, RotasApp.addCriancaEtapa3,
          arguments: dadosEtapa2);
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
                        Text('Dados financeiros',
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
                      _barraProgresso(false),
                    ],
                  ),
                  const SizedBox(height: 40),
                  TextFormField(
                    controller: _rendaController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      CentavosInputFormatter(moeda: true),
                    ],
                    validator: (v) => v!.isEmpty ? "Campo obrigatório" : null,
                    decoration: InputDecoration(
                      labelText: "Renda familiar",
                      hintText: "R\$ 0,00",
                      labelStyle: GoogleFonts.roboto(color: Colors.grey[600]),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8)),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                              color: Color(0xFF2962C0), width: 2)),
                    ),
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
}
