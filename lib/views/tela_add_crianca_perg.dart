import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gonogo/controller/controller_children.dart';
import 'package:gonogo/models/utils/rotas-app.dart';

class TelaAddCriancaPerg1 extends StatefulWidget {
  final String id;
  const TelaAddCriancaPerg1({super.key, required this.id});

  @override
  State<TelaAddCriancaPerg1> createState() => _TelaAddCriancaPerg1State();
}

class _TelaAddCriancaPerg1State extends State<TelaAddCriancaPerg1> {
  int _indiceAtual = 0;
  bool _salvando = false;
  final List<int> _respostas = [];
  final List<String> _perguntas = [
    "Tem dificuldade de manter a atenção em tarefas ou atividades de lazer?",
    "Não segue instruções até o fim e não termina deveres de escola, tarefas ou obrigações?",
    "Tem dificuldade em se envolver em tarefas que exigem esforço mental prolongado?",
    "Responde as perguntas de forma precipitada antes delas terem sido terminadas?",
  ];

  Future<void> _salvarRespostas() async {
    setState(() => _salvando = true);

    try {
      await ControllerChildren().addPerguntas(widget.id, _respostas);

      if (mounted) {
        _popUpSucesso();
      }
    } catch (error) {
      if (mounted) {
        setState(() => _salvando = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erro ao salvar: $error")),
        );
      }
    }
  }

  void _selecionarResposta(int valor) {
    setState(() {
      _respostas.add(valor);
      if (_indiceAtual < _perguntas.length - 1) {
        _indiceAtual++;
      } else {
        _salvarRespostas();
      }
    });
  }

  Future<bool> _confirmarSair() async {
    return await showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Text("Sair?",
                style: GoogleFonts.outfit(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF2962C0))),
            content: Text(
                "Se sair agora, o progresso do questionário será perdido.",
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit()),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text("Cancelar"),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                style:
                    ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                child:
                    const Text("Sair", style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ) ??
        false;
  }

  void _popUpSucesso() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title:
            const Icon(Icons.check_circle, color: Color(0xFF48CC48), size: 60),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Concluído!",
                style: GoogleFonts.outfit(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF292A2E))),
            const SizedBox(height: 10),
            Text("Os dados comportamentais foram registrados com sucesso.",
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(fontSize: 16, color: Colors.grey)),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.pushNamedAndRemoveUntil(
                    context, RotasApp.menu, (route) => false);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2962C0),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: Text("Voltar ao Início",
                  style: GoogleFonts.outfit(fontSize: 18, color: Colors.white)),
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWeb = size.width > 800;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, dynamic result) async {
        if (didPop) return;
        final sair = await _confirmarSair();
        if (sair && context.mounted) {
          Navigator.pushNamedAndRemoveUntil(
              context, RotasApp.menu, (r) => false);
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.close, color: Colors.grey),
            onPressed: () async {
              final sair = await _confirmarSair();
              if (sair && context.mounted) {
                Navigator.pushNamedAndRemoveUntil(
                    context, RotasApp.menu, (r) => false);
              }
            },
          ),
          centerTitle: true,
          title: Text(
            "Questionário SNAP-IV",
            style: GoogleFonts.outfit(
                color: const Color(0xFF292A2E), fontWeight: FontWeight.w600),
          ),
        ),
        body: _salvando
            ? const Center(
                child: CircularProgressIndicator(color: Color(0xFF2962C0)))
            : Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Container(
                    width: isWeb ? 600 : size.width,
                    padding: const EdgeInsets.all(30),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        )
                      ],
                    ),
                    child: Column(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            value: (_indiceAtual + 1) / _perguntas.length,
                            backgroundColor: Colors.grey[200],
                            valueColor: const AlwaysStoppedAnimation<Color>(
                                Color(0xFF2962C0)),
                            minHeight: 8,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "Pergunta ${_indiceAtual + 1} de ${_perguntas.length}",
                          style: GoogleFonts.outfit(
                              color: Colors.grey, fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 40),
                        Text(
                          _perguntas[_indiceAtual],
                          textAlign: TextAlign.center,
                          style: GoogleFonts.outfit(
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF292A2E),
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 50),
                        Text(
                          "Selecione a frequência:",
                          style: GoogleFonts.outfit(
                              fontSize: 14, color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 20),
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          alignment: WrapAlignment.center,
                          children: List.generate(5, (index) {
                            final valor = index + 1;
                            return _buildOptionButton(valor);
                          }),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("1 = Nunca",
                                style: GoogleFonts.outfit(
                                    fontSize: 12, color: Colors.grey)),
                            Text("5 = Sempre",
                                style: GoogleFonts.outfit(
                                    fontSize: 12, color: Colors.grey)),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildOptionButton(int valor) {
    return SizedBox(
      width: 60,
      height: 60,
      child: ElevatedButton(
        onPressed: () => _selecionarResposta(valor),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF2962C0),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Color(0xFFE0E0E0)),
          ),
          padding: EdgeInsets.zero,
        ),
        child: Text(
          "$valor",
          style: GoogleFonts.outfit(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
