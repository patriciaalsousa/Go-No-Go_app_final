import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gonogo/controller/controller_children.dart';
import 'package:gonogo/models/child.dart';
import 'package:gonogo/views/tela_avaliacoes.dart';

class TelaCriancasAvaliadas extends StatefulWidget {
  const TelaCriancasAvaliadas({super.key});

  @override
  State<TelaCriancasAvaliadas> createState() => _TelaCriancasAvaliadasState();
}

class _TelaCriancasAvaliadasState extends State<TelaCriancasAvaliadas> {
  final _controller = StreamController<QuerySnapshot>.broadcast();
  final List<Child> _criancas = [];
  List<Child> _pesquisa = [];
  final TextEditingController _pesquisarCrianca = TextEditingController();

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
      _pesquisa = _criancas
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
        automaticallyImplyLeading: false,
        title: Text(
          'Resultados',
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
                  QuerySnapshot querySnapshot = snapshot.data as QuerySnapshot;
                  List<DocumentSnapshot> docs = querySnapshot.docs.toList();

                  if (_pesquisarCrianca.text.isEmpty) {
                    _criancas.clear();
                    for (var doc in docs) {
                      if (doc["boolTestes"] == 1) {
                        Map<String, dynamic> data =
                            doc.data() as Map<String, dynamic>;

                        _criancas.add(Child(
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
                }

                final listaExibicao =
                    _pesquisarCrianca.text.isEmpty ? _criancas : _pesquisa;

                if (listaExibicao.isEmpty) {
                  return Center(
                    child: Text("Nenhuma avaliação encontrada",
                        style: GoogleFonts.outfit(color: Colors.grey)),
                  );
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(20),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: isWeb ? 3 : 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: isWeb ? 0.9 : 0.70,
                  ),
                  itemCount: listaExibicao.length,
                  itemBuilder: (context, index) {
                    final child = listaExibicao[index];
                    return _buildCard(child);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(Child child) {
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
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 10),
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
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
            ),
            const SizedBox(height: 4),
            Text(
              "Avaliação disponível",
              style: GoogleFonts.outfit(fontSize: 11, color: corSubtitulo),
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
                      builder: (_) => TelaAvaliacoes(id: child.id),
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
    );
  }
}
