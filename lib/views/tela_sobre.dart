import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TelaSobre extends StatelessWidget {
  const TelaSobre({super.key});

  @override
  Widget build(BuildContext context) {
    // Cores e Estilos
    const Color corAzul = Color(0xFF2962C0);
    final TextStyle estiloTituloCard = GoogleFonts.outfit(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: corAzul,
    );
    final TextStyle estiloTextoCard = GoogleFonts.outfit(
      fontSize: 15,
      color: const Color(0xFF292A2E),
      height: 1.3,
    );

    // Dados da Equipe
    final pesquisadores = [
      "Prof. Dr. Glauber Carvalho Nobre",
      "Prof. Dr. Rodrigo Flores Sartori",
    ];
    final desenvolvedores = [
      "Francisco Andeson Sousa da Silva",
      "Lucas Silva Correa",
      "Maria Beatriz Rodrigues de Sousa Fernades",
      "Mateus Lima Rodrigues",
      "Raul Ronald Diniz Marinho",
    ];
    final gerente = ["Rubens Abraão da Silva Sousa", "Patrícia Alves de Sousa"];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          "Sobre",
          style: GoogleFonts.outfit(
            color: Colors.black,
            fontSize: 22,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- LOGO DO PROJETO ---
            Center(
              child: Container(
                height: 100,
                width: 100,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    )
                  ],
                ),
                child: Image.asset(
                  "assets/images/logo.jpg",
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.school, size: 40, color: corAzul),
                ),
              ),
            ),

            const SizedBox(height: 20),

            Center(
              child: Text(
                "GDPPI",
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: corAzul,
                  letterSpacing: 1,
                ),
              ),
            ),

            const SizedBox(height: 30),

            // --- DESCRIÇÃO ---
            Text(
              "O Que é o GoNoGo?",
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF292A2E),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "O aplicativo tem como finalidade auxiliar profissionais da neuropsicologia, da educação física e psicomotricidade quanto as avaliações do controle inibitório por meio do paradigma GoNoGo.\n\nFoi proposto pelo Laboratório de Aprendizagem de Máquina e Projetos Inovadores do IFCE, campus Canindé.",
              style: GoogleFonts.outfit(
                fontSize: 15,
                color: Colors.grey[700],
                height: 1.5,
              ),
              textAlign: TextAlign.justify,
            ),

            const SizedBox(height: 30),
            const Divider(),
            const SizedBox(height: 20),

            // --- EQUIPE ---
            Text(
              "Nossa Equipe",
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF292A2E),
              ),
            ),
            const SizedBox(height: 16),

            _buildInfoCard(
              title: "Pesquisadores",
              names: pesquisadores,
              icon: Icons.science_outlined,
              titleStyle: estiloTituloCard,
              textStyle: estiloTextoCard,
            ),
            const SizedBox(height: 12),
            _buildInfoCard(
              title: "Desenvolvedores",
              names: desenvolvedores,
              icon: Icons.code,
              titleStyle: estiloTituloCard,
              textStyle: estiloTextoCard,
            ),
            const SizedBox(height: 12),
            _buildInfoCard(
              title: "Gerente do Projeto",
              names: gerente,
              icon: Icons.manage_accounts_outlined,
              titleStyle: estiloTituloCard,
              textStyle: estiloTextoCard,
            ),

            const SizedBox(height: 30),

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
              child: Column(
                children: [
                  Text(
                    "Precisa de ajuda?",
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Entre em contato conosco:",
                    style: GoogleFonts.outfit(
                        fontSize: 14,
                        color: Colors.white.withValues(alpha: 0.9)),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: SelectableText(
                      "",
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // --- LOGO IFCE  ---
            Center(
              child: SizedBox(
                height: 80,
                child: Image.asset(
                  "assets/images/IFCE.png",
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return const SizedBox();
                  },
                ),
              ),
            ),

            const SizedBox(height: 10),

            Center(
              child: Text(
                "Versão 1.0.0",
                style: GoogleFonts.outfit(
                  fontSize: 12,
                  color: Colors.grey[400],
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required List<String> names,
    required IconData icon,
    required TextStyle titleStyle,
    required TextStyle textStyle,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: const Color(0xFF2962C0)),
              const SizedBox(width: 8),
              Text(title, style: titleStyle),
            ],
          ),
          const SizedBox(height: 12),
          ...names.map((name) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text("• $name", style: textStyle),
              )),
        ],
      ),
    );
  }
}
