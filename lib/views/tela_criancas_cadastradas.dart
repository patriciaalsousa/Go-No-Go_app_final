import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gonogo/controller/controller_children.dart';
import 'package:gonogo/models/child.dart';
import 'package:gonogo/models/utils/export.dart';
import 'package:gonogo/views/tela_perfil_crianca.dart';
import '../models/utils/rotas-app.dart';

class TelaCriancasCadastradas extends StatefulWidget {
  const TelaCriancasCadastradas({super.key});

  @override
  State<TelaCriancasCadastradas> createState() =>
      _TelaCriancasCadastradasState();
}

class _TelaCriancasCadastradasState extends State<TelaCriancasCadastradas> {
  final _controller = StreamController<QuerySnapshot>.broadcast();
  final TextEditingController _pesquisarCrianca = TextEditingController();

  List<Child> children = [];
  List<Child> search = [];

  final Color corAzul = const Color(0xFF2962C0);
  final Color corTexto = const Color(0xFF292A2E);
  final Color corSubtitulo = const Color(0xFF9E9E9E);

  void _carregarCriancas() async {
    final stream = await ControllerChildren().loadChildren();
    stream.listen((event) {
      if (mounted) _controller.add(event);
    });
  }

  _pesquisar() {
    setState(() {
      search.clear();
      search = children
          .where((element) => element.completeName
              .toLowerCase()
              .contains(_pesquisarCrianca.text.toString().toLowerCase()))
          .toList();
    });
  }

  @override
  void initState() {
    super.initState();
    _carregarCriancas();
  }

  @override
  void dispose() {
    _controller.close();
    _pesquisarCrianca.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWeb = size.width > 800;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              Navigator.pushReplacementNamed(context, RotasApp.menu);
            }
          },
        ),
        title: Text(
          'Crianças',
          style: GoogleFonts.outfit(
            color: corTexto,
            fontSize: 24,
            fontWeight: FontWeight.w600,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: Colors.blue.withValues(alpha: 0.2),
            height: 1.0,
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  )
                ],
              ),
              child: TextFormField(
                controller: _pesquisarCrianca,
                onChanged: (value) => _pesquisar(),
                decoration: InputDecoration(
                  hintText: 'Pesquisar por nome',
                  hintStyle:
                      GoogleFonts.outfit(color: Colors.grey, fontSize: 14),
                  prefixIcon:
                      const Icon(Icons.search, color: Colors.grey, size: 20),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
                style: GoogleFonts.outfit(fontSize: 16),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _controller.stream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                      child: CircularProgressIndicator(color: corAzul));
                }

                if (snapshot.hasData) {
                  List<DocumentSnapshot> docs = snapshot.data!.docs;
                  if (_pesquisarCrianca.text.isEmpty) {
                    children.clear();
                    for (var doc in docs) {
                      Map<String, dynamic> data =
                          doc.data() as Map<String, dynamic>;

                      children.add(Child(
                        doc.id,
                        data["nome"] ?? "",
                        data["data_de_nascimento"] ?? "",
                        data["cor"] ?? "",
                        data["sexo"] ?? "",
                        data["renda"] ?? "",
                        data["tempo_aparelhos"] ?? "",
                        data["tempo_em_casa"] ?? "",
                        data["tempo_fora"] ?? "",
                        data["boolTestes"] ?? 0,
                        data["foto_perfil"] ?? "",
                      ));
                    }
                  }
                }

                final listaExibicao =
                    _pesquisarCrianca.text.isEmpty ? children : search;

                return GridView.builder(
                  padding: const EdgeInsets.all(20),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: isWeb ? 3 : 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: isWeb ? 1.0 : 0.68,
                  ),
                  itemCount: listaExibicao.length + 1,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return _buildNewChildCard();
                    }
                    final child = listaExibicao[index - 1];
                    return _buildChildCard(child);
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: Export(
        size: MediaQuery.of(context).size,
        children: children,
      ),
    );
  }

  Widget _buildNewChildCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 80,
            width: 80,
            decoration: BoxDecoration(
              color: corAzul,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: corAzul.withValues(alpha: 0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                )
              ],
            ),
            child: const Icon(Icons.person_add_alt_1,
                color: Colors.white, size: 36),
          ),
          const SizedBox(height: 16),
          Text(
            "Nova Criança",
            style: GoogleFonts.outfit(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: corTexto,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: 120,
            height: 36,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, RotasApp.addCrianca);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: corAzul,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Text(
                "Adicionar",
                style: GoogleFonts.outfit(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildChildCard(Child child) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: 4,
            right: 4,
            child: IconButton(
              icon: Icon(Icons.settings_outlined,
                  size: 20, color: Colors.grey.shade400),
              onPressed: () {
                Navigator.pushNamed(context, RotasApp.editarDadosCrianca,
                    arguments: child);
              },
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 35,
                    backgroundColor: Colors.grey.shade200,
                    backgroundImage: child.photoUrl.isNotEmpty
                        ? NetworkImage(child.photoUrl)
                        : AssetImage(
                            child.sex == "Masculino"
                                ? 'assets/images/menino.png'
                                : 'assets/images/menina.png',
                          ) as ImageProvider,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    child.completeName,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.outfit(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: corTexto,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    child.boolTests == 1
                        ? "Avaliação realizada"
                        : "Sem testes realizados",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.outfit(
                      fontSize: 11,
                      color: corSubtitulo,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: 120,
                    height: 36,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => TelaPerfilCriancaSelecionada(
                              child: child,
                              local: 0,
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: corAzul,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: Text(
                        "Visualizar",
                        style: GoogleFonts.outfit(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
