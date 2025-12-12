import 'package:brasil_fields/brasil_fields.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gonogo/controller/controller_children.dart';
import 'package:gonogo/models/child.dart';

class TelaEditarFinanceiro extends StatefulWidget {
  final Child child;
  const TelaEditarFinanceiro({super.key, required this.child});

  @override
  State<TelaEditarFinanceiro> createState() => _TelaEditarFinanceiroState();
}

class _TelaEditarFinanceiroState extends State<TelaEditarFinanceiro> {
  final _formKey = GlobalKey<FormState>();
  final _rendaController = TextEditingController();
  bool _salvando = false;

  @override
  void initState() {
    super.initState();
    _rendaController.text = widget.child.income;
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _salvando = true);

    try {
      widget.child.sIncome = _rendaController.text;

      await ControllerChildren().updateChild(widget.child);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Renda atualizada com sucesso!")),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erro: $e")),
        );
        setState(() => _salvando = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
          'Financeiro',
          style: GoogleFonts.outfit(
            color: const Color(0xFF292A2E),
            fontSize: 22,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _rendaController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  CentavosInputFormatter(moeda: true),
                ],
                validator: (v) => v!.isEmpty ? "Campo obrigatório" : null,
                decoration: InputDecoration(
                  labelText: "Renda Familiar",
                  labelStyle: GoogleFonts.outfit(color: Colors.grey[600]),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.grey)),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          const BorderSide(color: Color(0xFF2962C0), width: 2)),
                  filled: true,
                  fillColor: Colors.white,
                ),
                style: GoogleFonts.outfit(fontSize: 16),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _salvando ? null : _salvar,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2962C0),
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
}
