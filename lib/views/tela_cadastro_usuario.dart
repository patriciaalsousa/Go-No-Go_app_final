import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gonogo/models/utils/rotas-app.dart';
import 'package:gonogo/models/utils/validator.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

class TelaCadastroUsuario extends StatefulWidget {
  const TelaCadastroUsuario({super.key});

  @override
  State<TelaCadastroUsuario> createState() => _TelaCadastroUsuarioState();
}

class _TelaCadastroUsuarioState extends State<TelaCadastroUsuario> {
  final _formKey = GlobalKey<FormState>();

  // Controladores
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _instituicaoController = TextEditingController();
  final _dataNascimentoController = TextEditingController();

  // Máscara para data: ##/##/####
  final _dataMask = MaskTextInputFormatter(
    mask: '##/##/####',
    filter: {"#": RegExp(r'[0-9]')},
    type: MaskAutoCompletionType.lazy,
  );

  String? _areaSelecionada;

  final List<String> _areas = [
    'Neuropsicologia Clínica',
    'Neuropsicologia Experimental',
    'Neuropsicologia Escolar',
    'Reabilitação Cognitiva',
    'Outra'
  ];

  String? _validarData(String? value) {
    if (value == null || value.isEmpty) {
      return 'Insira a data';
    }
    if (value.length != 10) {
      return 'Formato inválido (DD/MM/AAAA)';
    }

    try {
      final parts = value.split('/');
      final dia = int.parse(parts[0]);
      final mes = int.parse(parts[1]);
      final ano = int.parse(parts[2]);

      final dataDigitada = DateTime(ano, mes, dia);
      final hoje = DateTime.now();

      if (ano < 1900 || ano > hoje.year) return 'Ano inválido';
      if (mes < 1 || mes > 12) return 'Mês inválido';
      if (dia < 1 || dia > 31) return 'Dia inválido';

      // Verifica se a data é no futuro
      if (dataDigitada.isAfter(hoje)) return 'Data futura inválida';
    } catch (e) {
      return 'Data inválida';
    }
    return null;
  }

  void _avancarProximaEtapa() {
    if (_formKey.currentState!.validate()) {
      final dadosEtapa1 = {
        'name': _nomeController.text,
        'birthDate': _dataNascimentoController.text,
        'email': _emailController.text,
        'institution': _instituicaoController.text,
        'area': _areaSelecionada,
      };

      Navigator.pushNamed(context, RotasApp.cadastroEtapa2,
          arguments: dadosEtapa1);
    }
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
              minHeight: isWeb ? 600 : size.height * 0.8,
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
                          'Dados pessoais',
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
                      _buildProgressIndicator(active: false),
                      const SizedBox(width: 8),
                      _buildProgressIndicator(active: false),
                    ],
                  ),
                  const SizedBox(height: 32),
                  _buildTextField(
                    label: 'Nome Completo',
                    controller: _nomeController,
                    validator: (v) => v!.isEmpty ? 'Insira o nome' : null,
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _dataNascimentoController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [_dataMask],
                    validator: _validarData,
                    decoration: _inputDecoration('Data de Nascimento').copyWith(
                      suffixIcon: const Icon(Icons.calendar_today,
                          size: 20, color: Colors.grey),
                    ),
                    style: GoogleFonts.roboto(color: Colors.black87),
                  ),
                  const SizedBox(height: 20),
                  _buildTextField(
                    label: 'Email',
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    validator: Validator.validarEmail,
                  ),
                  const SizedBox(height: 20),
                  _buildTextField(
                    label: 'Instituição',
                    controller: _instituicaoController,
                    validator: (v) =>
                        v!.isEmpty ? 'Insira sua instituição' : null,
                  ),
                  const SizedBox(height: 20),
                  DropdownButtonFormField<String>(
                    initialValue: _areaSelecionada,
                    decoration: _inputDecoration('Área neuropsicológica'),
                    icon: const Icon(Icons.arrow_drop_down,
                        color: Color(0xFF2962C0)),
                    items: _areas.map((String area) {
                      return DropdownMenuItem<String>(
                        value: area,
                        child: Text(
                          area,
                          style: GoogleFonts.roboto(
                              fontSize: 14, color: Colors.black87),
                        ),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _areaSelecionada = newValue;
                      });
                    },
                    validator: (v) => v == null ? 'Selecione uma área' : null,
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

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      decoration: _inputDecoration(label),
      style: GoogleFonts.roboto(color: Colors.black87),
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
