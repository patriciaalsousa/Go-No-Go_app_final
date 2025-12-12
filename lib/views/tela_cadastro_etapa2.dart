import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gonogo/models/utils/rotas-app.dart';
import 'package:gonogo/models/utils/validator.dart';

class TelaCadastroEtapa2 extends StatefulWidget {
  final Map<String, dynamic> dadosEtapa1;

  const TelaCadastroEtapa2({super.key, required this.dadosEtapa1});

  @override
  State<TelaCadastroEtapa2> createState() => _TelaCadastroEtapa2State();
}

class _TelaCadastroEtapa2State extends State<TelaCadastroEtapa2> {
  final _formKey = GlobalKey<FormState>();

  // Controladores
  final _senhaController = TextEditingController();
  final _confirmaSenhaController = TextEditingController();

  // Controle de visibilidade
  bool _senhaVisivel = false;
  bool _confirmaSenhaVisivel = false;

  void _avancarProximaEtapa() {
    if (_formKey.currentState!.validate()) {
      // Junta dados da etapa 1 + senha da etapa 2
      final dadosCompletos = {
        ...widget.dadosEtapa1,
        'password': _senhaController.text,
      };
      Navigator.pushNamed(context, RotasApp.cadastroEtapa3,
          arguments: dadosCompletos);
    }
  }

  String? _validarConfirmacao(String? value) {
    if (value == null || value.isEmpty) {
      return 'Confirme sua senha';
    }
    if (value != _senhaController.text) {
      return 'As senhas não coincidem';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWeb = size.width > 800;
    final double verticalPadding = isWeb ? 40 : 24;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Center(
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: Container(
            width: isWeb ? 558 : size.width * 0.9,
            constraints: BoxConstraints(
              minHeight: isWeb ? 500 : size.height * 0.6,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: isWeb
                  ? [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      )
                    ]
                  : null,
            ),
            padding: EdgeInsets.symmetric(
              vertical: verticalPadding,
              horizontal: isWeb ? 60 : 24,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(Icons.arrow_back,
                          color: Color(0xFF292A2E)),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Center(
                    child: Column(
                      children: [
                        Text(
                          'Cadastro',
                          style: GoogleFonts.outfit(
                            fontSize: 24,
                            fontWeight: FontWeight.w400,
                            color: const Color(0xFF292A2E),
                            height: 1.0,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Dados cadastrais',
                          style: GoogleFonts.outfit(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: const Color(0xFF6C6A6A),
                            height: 1.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildProgressIndicator(active: true),
                      const SizedBox(width: 8),
                      _buildProgressIndicator(active: true),
                      const SizedBox(width: 8),
                      _buildProgressIndicator(active: false),
                    ],
                  ),
                  const SizedBox(height: 32),
                  TextFormField(
                    controller: _senhaController,
                    obscureText: !_senhaVisivel,
                    validator: Validator.validarSenha,
                    decoration: _inputDecoration('Senha').copyWith(
                      suffixIcon: IconButton(
                        icon: Icon(
                          _senhaVisivel
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: Colors.grey,
                        ),
                        onPressed: () =>
                            setState(() => _senhaVisivel = !_senhaVisivel),
                      ),
                    ),
                    style: GoogleFonts.roboto(color: Colors.black87),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _confirmaSenhaController,
                    obscureText: !_confirmaSenhaVisivel,
                    validator: _validarConfirmacao,
                    decoration: _inputDecoration('Confirmar Senha').copyWith(
                      suffixIcon: IconButton(
                        icon: Icon(
                          _confirmaSenhaVisivel
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: Colors.grey,
                        ),
                        onPressed: () => setState(() =>
                            _confirmaSenhaVisivel = !_confirmaSenhaVisivel),
                      ),
                    ),
                    style: GoogleFonts.roboto(color: Colors.black87),
                  ),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    height: 45,
                    child: ElevatedButton(
                      onPressed: _avancarProximaEtapa,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2962C0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'Seguinte',
                        style: GoogleFonts.outfit(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                          letterSpacing: 0.02,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProgressIndicator({required bool active}) {
    return Container(
      width: 43,
      height: 6,
      decoration: BoxDecoration(
        color: active ? const Color(0xFF2962C0) : const Color(0xFFC7D3EB),
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: GoogleFonts.roboto(color: Colors.grey[600], fontSize: 16),
      floatingLabelBehavior: FloatingLabelBehavior.auto,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFB6B6BB)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFB6B6BB)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFF2962C0), width: 2),
      ),
      errorStyle: const TextStyle(height: 0.8),
    );
  }
}
