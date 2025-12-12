import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gonogo/controller/controller_children.dart';
import 'package:gonogo/models/child.dart';
import 'package:gonogo/models/utils/rotas-app.dart';
import 'package:gonogo/views/tela_avaliar.dart';
import 'package:gonogo/views/tela_avaliacoes.dart';

class TelaPerfilCriancaSelecionada extends StatefulWidget {
  final Child child;
  final int local;
  const TelaPerfilCriancaSelecionada(
      {super.key, required this.child, required this.local});

  @override
  State<TelaPerfilCriancaSelecionada> createState() =>
      _TelaPerfilCriancaSelecionadaState();
}

class _TelaPerfilCriancaSelecionadaState
    extends State<TelaPerfilCriancaSelecionada> {
  final Color corAzul = const Color(0xFF2962C0);
  final Color corTexto = const Color(0xFF292A2E);
  final Color corFundoIcone = const Color(0xFFE8F0FE);

  bool _excluindo = false; // Controle de loading para exclusão

  // --- Função de Exclusão ---
  Future<void> _confirmarExclusao() async {
    return showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text("Excluir Criança?",
            style: GoogleFonts.outfit(
                fontWeight: FontWeight.bold, color: Colors.redAccent)),
        content: Text(
            "Tem certeza que deseja excluir ${widget.child.completeName}?\nEssa ação não pode ser desfeita e todo o histórico será perdido.",
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(fontSize: 16)),
        actionsAlignment: MainAxisAlignment.spaceEvenly,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child:
                Text("Cancelar", style: GoogleFonts.outfit(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx); // Fecha o alerta
              setState(() => _excluindo = true); // Mostra loading (opcional)

              try {
                await ControllerChildren().deleteChild(widget.child.id);

                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text("Criança excluída com sucesso.")),
                  );
                  Navigator.pushNamedAndRemoveUntil(
                      context, RotasApp.menu, (route) => false);
                }
              } catch (e) {
                if (mounted) {
                  setState(() => _excluindo = false);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text("Erro: $e"), backgroundColor: Colors.red),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child:
                Text("Excluir", style: GoogleFonts.outfit(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_excluindo) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: Colors.redAccent)),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () {
            if (widget.local == 0) {
              Navigator.pop(context);
            } else {
              Navigator.pushNamed(context, RotasApp.criancasCadastradas);
            }
          },
        ),
        title: Text(
          'Perfil',
          style: GoogleFonts.outfit(
            color: corTexto,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        // --- BOTÃO DE EXCLUIR ---
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded,
                color: Colors.redAccent),
            tooltip: 'Excluir Criança',
            onPressed: _confirmarExclusao,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // --- CABEÇALHO DO PERFIL ---
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: corAzul,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: corAzul.withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  )
                ],
              ),
              child: Row(
                children: [
                  // FOTO DE PERFIL
                  CircleAvatar(
                    radius: 35,
                    backgroundColor: Colors.white.withValues(alpha: 0.2),
                    backgroundImage: widget.child.photoUrl.isNotEmpty
                        ? NetworkImage(widget.child.photoUrl)
                        : AssetImage(
                            widget.child.sex == "Masculino"
                                ? 'assets/images/menino.png'
                                : 'assets/images/menina.png',
                          ) as ImageProvider,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.child.completeName,
                          style: GoogleFonts.outfit(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Criança",
                          style: GoogleFonts.outfit(
                            fontSize: 14,
                            color: Colors.white.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),

            const SizedBox(height: 24),

            // --- LISTA DE OPÇÕES ---
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  )
                ],
              ),
              child: Column(
                children: [
                  // DADOS PESSOAIS
                  _buildListTile(
                    title: "Dados pessoais",
                    icon: Icons.face,
                    onTap: () async {
                      await Navigator.pushNamed(
                        context,
                        RotasApp.editarDadosCrianca,
                        arguments: widget.child,
                      );
                      setState(() {});
                    },
                  ),
                  const Divider(height: 1, indent: 60, endIndent: 20),

                  // DADOS FINANCEIROS
                  _buildListTile(
                    title: "Dados financeiro",
                    icon: Icons.attach_money,
                    onTap: () async {
                      await Navigator.pushNamed(
                        context,
                        RotasApp.editarFinanceiro,
                        arguments: widget.child,
                      );
                      setState(() {});
                    },
                  ),

                  const Divider(height: 1, indent: 60, endIndent: 20),

                  // DADOS AVALIATIVOS
                  _buildListTile(
                    title: "Dados avaliativos",
                    icon: Icons.assignment,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => TelaAvaliacoes(id: widget.child.id),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // --- BOTÃO AVALIAR ---
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _popUpConfirmation,
                style: ElevatedButton.styleFrom(
                  backgroundColor: corAzul,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  "Avaliar agora",
                  style: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.15),
              blurRadius: 5,
              offset: const Offset(0, -1),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: 1,
          onTap: (index) {
            if (index != 1) {
              Navigator.pushNamedAndRemoveUntil(
                  context, RotasApp.menu, (route) => false);
            }
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          elevation: 0,
          selectedItemColor: corAzul,
          unselectedItemColor: corAzul.withValues(alpha: 0.5),
          selectedLabelStyle:
              GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 12),
          unselectedLabelStyle:
              GoogleFonts.outfit(fontWeight: FontWeight.w400, fontSize: 12),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              label: 'Início',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.accessibility_new),
              label: 'Crianças',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.assignment_outlined),
              label: 'Resultados',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              label: 'Perfil',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListTile({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: corFundoIcone,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: corAzul, size: 20),
      ),
      title: Text(
        title,
        style: GoogleFonts.outfit(
          fontSize: 16,
          color: Colors.grey[700],
          fontWeight: FontWeight.w400,
        ),
      ),
      trailing: Icon(Icons.edit, size: 20, color: Colors.grey[600]),
      onTap: onTap,
    );
  }

  void _popUpConfirmation() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          "Iniciar Avaliação?",
          style:
              GoogleFonts.outfit(fontWeight: FontWeight.bold, color: corAzul),
          textAlign: TextAlign.center,
        ),
        content: Text(
          widget.child.boolTests == 1
              ? "Esta criança já possui testes. Deseja realizar uma nova avaliação?"
              : "Deseja iniciar a avaliação para ${widget.child.completeName}?",
          style: GoogleFonts.outfit(fontSize: 16),
          textAlign: TextAlign.center,
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Não", style: GoogleFonts.outfit(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _popUpChoice();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: corAzul,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: Text("Sim", style: GoogleFonts.outfit(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _popUpChoice() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          "Escolha o Tipo",
          style:
              GoogleFonts.outfit(fontWeight: FontWeight.bold, color: corAzul),
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => TelaAvaliar(
                        id: widget.child.id,
                        teste: 0,
                        boolTeste: widget.child.boolTests,
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.visibility, color: Colors.white),
                label: Text("Teste Visual",
                    style: GoogleFonts.outfit(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: corAzul,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => TelaAvaliar(
                        id: widget.child.id,
                        teste: 1,
                        boolTeste: widget.child.boolTests,
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.volume_up, color: Colors.white),
                label: Text("Teste de Áudio",
                    style: GoogleFonts.outfit(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
