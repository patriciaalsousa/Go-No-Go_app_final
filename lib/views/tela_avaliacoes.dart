import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gonogo/controller/controller_children.dart';
import 'package:gonogo/views/tela_resultados.dart';

class TelaAvaliacoes extends StatefulWidget {
  final String id;
  const TelaAvaliacoes({super.key, required this.id});

  @override
  State<TelaAvaliacoes> createState() => _TelaAvaliacoesState();
}

class _TelaAvaliacoesState extends State<TelaAvaliacoes> {
  final _controller = StreamController<QuerySnapshot>.broadcast();

  final Color corAzul = const Color(0xFF2962C0);

  _carregarAvaliacoes() async {
    final stream = await ControllerChildren().loadReviews(widget.id);
    stream.listen((event) {
      if (mounted) _controller.add(event);
    });
  }

  @override
  void initState() {
    super.initState();
    _carregarAvaliacoes();
  }

  @override
  void dispose() {
    _controller.close();
    super.dispose();
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
          'Histórico',
          style: GoogleFonts.outfit(
            color: const Color(0xFF292A2E),
            fontSize: 22,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _controller.stream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: corAzul));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                "Nenhuma avaliação encontrada.",
                style: GoogleFonts.outfit(color: Colors.grey, fontSize: 16),
              ),
            );
          }

          QuerySnapshot querySnapshot = snapshot.data as QuerySnapshot;
          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: querySnapshot.docs.length,
            itemBuilder: (context, index) {
              var dados = querySnapshot.docs[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => TelaResultados(
                          result: {
                            "tipo": dados["tipo"],
                            "erros": dados["erros"],
                            "acertos": dados["acertos"],
                            "omissoes": dados["omissoes"],
                            "qtde_cliques": dados["qtde_cliques"],
                          },
                        ),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        )
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: corAzul.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.calendar_today,
                                  color: corAzul, size: 20),
                            ),
                            const SizedBox(width: 16),
                            Text(
                              dados["data_avaliacao"],
                              style: GoogleFonts.outfit(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF292A2E),
                              ),
                            ),
                          ],
                        ),
                        Icon(Icons.arrow_forward_ios,
                            size: 16, color: Colors.grey.shade400),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
