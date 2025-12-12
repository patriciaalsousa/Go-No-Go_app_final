import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gonogo/controller/controller_evaluator.dart';
import 'package:gonogo/models/utils/rotas-app.dart';
import 'package:gonogo/models/utils/ver_login.dart';

class TelaMenu extends StatefulWidget {
  final Function(int) onMudarTab;

  const TelaMenu({
    super.key,
    required this.onMudarTab,
  });

  @override
  State<TelaMenu> createState() => _TelaMenuState();
}

class _TelaMenuState extends State<TelaMenu> {
  String nomeUsuario = "Avaliador";
  String urlImage = "";
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _carregarDados();
    VerLogin().resultado(context);
  }

  Future<void> _carregarDados() async {
    try {
      var dados = await ControllerEvaluator().seeProfile();
      if (mounted) {
        setState(() {
          if (dados.length > 1 && dados[1] is Map) {
            nomeUsuario = dados[1]["nome"] ?? "Avaliador";
            urlImage = dados[1]["foto_perfil"] ?? "";
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color corAzul = Color(0xFF2962C0);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: corAzul))
            : SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- CABEÇALHO ---
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Olá, $nomeUsuario",
                                style: GoogleFonts.outfit(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF292A2E),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                "Bem-vindo de volta!",
                                style: GoogleFonts.outfit(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        GestureDetector(
                          onTap: () async {
                            await Navigator.pushNamed(
                                context, RotasApp.editarPerfil);
                            _carregarDados();
                          },
                          child: CircleAvatar(
                            radius: 24,
                            backgroundColor: Colors.grey[200],
                            backgroundImage: urlImage.isNotEmpty
                                ? NetworkImage(urlImage)
                                : const AssetImage('assets/images/FotoAdd.jpg')
                                    as ImageProvider,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 30),

                    // --- CARD Nova Criança ---
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.person_add_alt_1,
                                color: Colors.white, size: 28),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            "Nova Criança",
                            style: GoogleFonts.outfit(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Cadastre um novo paciente para iniciar avaliações.",
                            style: GoogleFonts.outfit(
                              fontSize: 14,
                              color: Colors.white.withValues(alpha: 0.9),
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.pushNamed(
                                    context, RotasApp.addCrianca);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: corAzul,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: Text(
                                "Cadastrar Agora",
                                style: GoogleFonts.outfit(
                                    fontWeight: FontWeight.w600),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),

                    Text(
                      "Acesso Rápido",
                      style: GoogleFonts.outfit(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF292A2E),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // --- ATALHOS ---
                    Row(
                      children: [
                        Expanded(
                          child: _buildShortcutCard(
                            context,
                            title: "Avaliar",
                            icon: Icons.play_circle_outline,
                            color: const Color(0xFF48CC48),
                            onTap: () {
                              widget.onMudarTab(1);
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildShortcutCard(
                            context,
                            title: "Resultados",
                            icon: Icons.bar_chart,
                            color: const Color(0xFFFFA000),
                            onTap: () {
                              widget.onMudarTab(2);
                            },
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 40),

                    // Botão Sair
                    Center(
                      child: TextButton.icon(
                        onPressed: () {
                          Navigator.pushReplacementNamed(
                              context, RotasApp.login);
                        },
                        icon: const Icon(Icons.logout, color: Colors.redAccent),
                        label: Text(
                          "Sair da conta",
                          style: GoogleFonts.outfit(
                            color: Colors.redAccent,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildShortcutCard(BuildContext context,
      {required String title,
      required IconData icon,
      required Color color,
      required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 110,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: GoogleFonts.outfit(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF292A2E),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
