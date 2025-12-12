import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gonogo/views/tela_menu.dart';
import 'package:gonogo/views/tela_criancas_cadastradas.dart';
import 'package:gonogo/views/tela_criancas_avaliadas.dart';
import 'package:gonogo/views/tela_editar_perfil.dart';

class TelaPrincipal extends StatefulWidget {
  const TelaPrincipal({super.key});

  @override
  State<TelaPrincipal> createState() => _TelaPrincipalState();
}

class _TelaPrincipalState extends State<TelaPrincipal> {
  int _indiceAtual = 0;
  DateTime pressionar = DateTime.now();
  bool _inicializado = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_inicializado) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is int) {
        setState(() {
          _indiceAtual = args;
        });
      }
      _inicializado = true;
    }
  }

  List<Widget> get _telas => [
        TelaMenu(
          onMudarTab: (indice) {
            _aoClicar(indice);
          },
        ),
        const TelaCriancasCadastradas(),
        const TelaCriancasAvaliadas(),
        const TelaEditarPerfil(),
      ];

  void _aoClicar(int index) {
    setState(() {
      _indiceAtual = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    const Color corAzulPrincipal = Color(0xFF2962C0);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, dynamic result) {
        if (didPop) return;

        if (_indiceAtual != 0) {
          setState(() {
            _indiceAtual = 0;
          });
          return;
        }

        final diferenca = DateTime.now().difference(pressionar);
        final avisoSair = diferenca >= const Duration(seconds: 2);
        pressionar = DateTime.now();

        if (avisoSair) {
          Fluttertoast.showToast(
            msg: "Pressione novamente para sair",
            fontSize: 16,
            backgroundColor: Colors.black54,
            textColor: Colors.white,
          );
        } else {
          Fluttertoast.cancel();
          if (Platform.isAndroid) {
            SystemNavigator.pop();
          } else {
            exit(0);
          }
        }
      },
      child: Scaffold(
        body: _telas[_indiceAtual],
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
            currentIndex: _indiceAtual,
            onTap: _aoClicar,
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.white,
            elevation: 0,
            selectedItemColor: corAzulPrincipal,
            unselectedItemColor: corAzulPrincipal.withValues(alpha: 0.5),
            selectedLabelStyle: GoogleFonts.outfit(
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
            unselectedLabelStyle: GoogleFonts.outfit(
              fontWeight: FontWeight.w400,
              fontSize: 12,
            ),
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home_outlined),
                label: 'Início',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.accessibility_new_outlined),
                activeIcon: Icon(Icons.accessibility_new_outlined),
                label: 'Crianças',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.assignment_outlined),
                activeIcon: Icon(Icons.assignment_outlined),
                label: 'Resultados',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_outline),
                activeIcon: Icon(Icons.person_outline),
                label: 'Perfil',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
