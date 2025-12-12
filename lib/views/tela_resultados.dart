import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TelaResultados extends StatefulWidget {
  final Map result;
  const TelaResultados({super.key, required this.result});

  @override
  State<TelaResultados> createState() => _TelaResultadosState();
}

class _TelaResultadosState extends State<TelaResultados> {
  @override
  Widget build(BuildContext context) {
    final Color corAzul = const Color(0xFF2962C0);

    final String tipoTeste = widget.result["tipo"] ?? "Teste";
    final items = [
      {
        "titulo": "Erros",
        "valor": "${widget.result['erros']}/15",
        "cor": Colors.redAccent
      },
      {
        "titulo": "Omissões",
        "valor": "${widget.result['omissoes']}/45",
        "cor": Colors.orangeAccent
      },
      {
        "titulo": "Acertos",
        "valor": "${widget.result['acertos']}/45",
        "cor": Colors.green
      },
      {
        "titulo": "Cliques",
        "valor": "${widget.result['qtde_cliques']}/45",
        "cor": Colors.blueAccent
      },
    ];

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
          'Detalhes',
          style: GoogleFonts.outfit(
            color: const Color(0xFF292A2E),
            fontSize: 22,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Cabeçalho do Teste
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: corAzul,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: corAzul.withValues(alpha: 0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  )
                ],
              ),
              child: Column(
                children: [
                  Text(
                    "Tipo de Avaliação",
                    style: GoogleFonts.outfit(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    tipoTeste.toUpperCase(),
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // Grid de Resultados
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.1,
              ),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade100),
                    boxShadow: [
                      BoxShadow(
                        color: (item["cor"] as Color).withValues(alpha: 0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        item["titulo"] as String,
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        item["valor"] as String,
                        style: GoogleFonts.outfit(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: item["cor"] as Color,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
