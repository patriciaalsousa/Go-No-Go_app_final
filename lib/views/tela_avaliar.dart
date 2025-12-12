import 'dart:async';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gonogo/controller/controller_children.dart';
import 'package:gonogo/models/sequencia.dart';
import '../models/utils/rotas-app.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class TelaAvaliar extends StatefulWidget {
  final String id;
  final int teste;
  final int boolTeste;
  const TelaAvaliar(
      {super.key,
      required this.id,
      required this.teste,
      required this.boolTeste});

  @override
  State<TelaAvaliar> createState() => _TelaAvaliarState();
}

class _TelaAvaliarState extends State<TelaAvaliar> with WidgetsBindingObserver {
  bool boolTeste = true;
  bool _carregar = false;
  bool mostrar = false;
  final FlutterTts flutterTts = FlutterTts();
  int i = 0;

  List<int> indices = [];
  bool _comecarLista = false;

  bool _isPaused = true;
  Timer? _visualTimer;
  bool _isDisposed = false;
  bool _isManuallyPaused = false;

  final Color corAzul = const Color(0xFF2962C0);
  final Color corVerde = const Color(0xFF48CC48);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final size = MediaQuery.of(context).size;
        _mostrarPopUpInicial(size);
      }
    });
  }

  @override
  void dispose() {
    _isDisposed = true;
    WidgetsBinding.instance.removeObserver(this);
    _visualTimer?.cancel();
    flutterTts.stop();
    flutterTts.setCompletionHandler(() {});
    flutterTts.setErrorHandler((_) {});
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (_isDisposed) return;

    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached) {
      debugPrint("App Pausado pelo Sistema: $state");
      _pauseTest(manual: false);
    } else if (state == AppLifecycleState.resumed && !_isManuallyPaused) {
      debugPrint("App Resumed (e não pausado manualmente)");
      if (!_isPaused) {
        _resumeTest();
      }
    }
  }

  _selecao() {
    late int numero;
    List<Color> cores = const [Color(0xFF292A2E), Color(0xFF292A2E)];
    if (i % 2 == 0) {
      numero = 0;
    } else {
      numero = 1;
    }
    return cores[numero];
  }

  void _pauseTest({bool manual = true}) {
    if (_isDisposed) return;
    debugPrint(
        "Chamada para _pauseTest (Manual: $manual). Parando TTS e Timers.");
    _visualTimer?.cancel();
    _visualTimer = null;
    flutterTts.stop();

    if (_isPaused) {
      if (manual && !_isManuallyPaused) {
        _isManuallyPaused = true;
        if (mounted) setState(() {});
      }
      return;
    }

    if (mounted) {
      setState(() {
        _isPaused = true;
        if (manual) _isManuallyPaused = true;
      });
    } else {
      _isPaused = true;
      if (manual) _isManuallyPaused = true;
    }
  }

  void _resumeTest() {
    if (_isDisposed || !_isPaused) return;

    if (mounted) {
      setState(() {
        _isPaused = false;
        _isManuallyPaused = false;
      });
    } else {
      _isPaused = false;
      _isManuallyPaused = false;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_isPaused || _isDisposed) return;
      if (boolTeste) {
        _testeAvaliacao();
      } else {
        _teste();
      }
    });
  }

  _testeAvaliacao() async {
    if (_isPaused || _isDisposed) return;

    if (widget.teste == 0) {
      if (i < 3) {
        _visualTimer?.cancel();
        _visualTimer = Timer(const Duration(seconds: 1), () {
          if (_isPaused || _isDisposed) return;
          if (mounted) {
            setState(() {
              i++;
            });
          } else {
            return;
          }
          _testeAvaliacao();
        });
      } else {
        _visualTimer?.cancel();
        final currentContext = context;
        final size = MediaQuery.of(currentContext).size;
        _visualTimer = Timer(
          const Duration(seconds: 1),
          () {
            if (_isPaused || _isDisposed) return;
            if (currentContext.mounted) {
              _mostrarPopUpPreparese(size);
            }
          },
        );
      }
    } else if (widget.teste == 1) {
      if (i < 4) {
        await _reproduzirTeste(sequenciaTeste[i].toString());
      } else {
        final currentContext = context;
        final size = MediaQuery.of(currentContext).size;
        Timer(const Duration(milliseconds: 500), () {
          if (_isPaused || _isDisposed) return;
          if (currentContext.mounted) {
            _mostrarPopUpPreparese(size);
          }
        });
      }
    }
  }

  _teste() async {
    if (_isPaused || _isDisposed) return;

    if (widget.teste == 0) {
      if (i < 59) {
        _visualTimer?.cancel();
        _visualTimer = Timer(const Duration(seconds: 1), () {
          if (_isPaused || _isDisposed) return;
          if (mounted) {
            setState(() {
              i++;
            });
          } else {
            return;
          }
          _teste();
        });
      } else {
        _visualTimer?.cancel();
        final currentContext = context;
        final size = MediaQuery.of(currentContext).size;
        _visualTimer =
            Timer(const Duration(seconds: 1, milliseconds: 500), () async {
          if (_isPaused || _isDisposed) return;
          await _salvarResultados("Visual Motor", currentContext, size);
        });
      }
    } else if (widget.teste == 1) {
      if (!_comecarLista) {
        if (mounted) {
          setState(() {
            _comecarLista = true;
          });
        } else {
          return;
        }
      }

      if (i < sequenciaLista.length) {
        await _reproduzirTeste(sequenciaLista[i].toString());
      } else {
        final currentContext = context;
        final size = MediaQuery.of(currentContext).size;
        Timer(const Duration(seconds: 1), () async {
          if (_isPaused || _isDisposed) return;
          await _salvarResultados("Áudio Motor", currentContext, size);
        });
      }
    }
  }

  Future<void> _salvarResultados(
      String tipoTeste, BuildContext capturedContext, Size size) async {
    try {
      if (!capturedContext.mounted || _isDisposed) return;
      if (capturedContext.mounted) {
        if (mounted) {
          setState(() {
            _carregar = true;
          });
        } else {
          return;
        }
      } else {
        return;
      }

      _popUpFinal("Salvando...", capturedContext, size);

      await ControllerChildren()
          .salvarTeste(widget.id, indices, tipoTeste, widget.boolTeste);

      if (!capturedContext.mounted || _isDisposed) return;

      Navigator.of(capturedContext).pop();
      await Future.delayed(const Duration(milliseconds: 100));
      if (!capturedContext.mounted || _isDisposed) return;

      _popUpFinal("Avaliação concluída com sucesso", capturedContext, size);
      if (mounted) {
        setState(() {
          _carregar = false;
        });
      }
    } catch (error) {
      if (!capturedContext.mounted || _isDisposed) return;
      try {
        Navigator.of(capturedContext).pop();
        await Future.delayed(const Duration(milliseconds: 100));
      } catch (_) {}
      if (!capturedContext.mounted || _isDisposed) return;

      _popUpFinal(error.toString(), capturedContext, size);
      if (mounted) {
        setState(() {
          _carregar = false;
        });
      }
    }
  }

  _reproduzir(String texto) async {
    await flutterTts.stop();
    await flutterTts.setLanguage("pt-BR");
    await flutterTts.setPitch(1);
    await flutterTts.setSpeechRate(0.5);
    await flutterTts.speak(texto);
  }

  _reproduzirTeste(String textoTeste) async {
    if (_isPaused || _isDisposed) return;

    await flutterTts.setLanguage("pt-BR");
    await flutterTts.setPitch(1);
    if (!kIsWeb) {
      await flutterTts.setSpeechRate(0.5);
    } else {
      await flutterTts.setSpeechRate(0.72);
    }

    flutterTts.setCompletionHandler(() {
      if (_isPaused || _isDisposed) return;

      Timer(const Duration(milliseconds: 435), () {
        if (_isPaused || _isDisposed) return;

        if (mounted) {
          setState(() {
            i++;
          });
        } else {
          return;
        }

        if (boolTeste) {
          _testeAvaliacao();
        } else {
          _teste();
        }
      });
    });

    flutterTts.setErrorHandler((msg) {
      if (msg != 'interrupted' && !_isPaused && !_isDisposed) {
        _pauseTest(manual: false);
      }
    });

    await flutterTts.speak(textoTeste);
  }

  Future<void> _pararTesteCompleto() async {
    _visualTimer?.cancel();
    _visualTimer = null;
    await flutterTts.stop();
    flutterTts.setCompletionHandler(() {});
    flutterTts.setErrorHandler((_) {});
  }

  void _mostrarPopUpInicial(Size size) {
    _reproduzir("Treino, ${listaTexto[widget.teste]}");

    popUpAlert(
      context: context,
      size: size,
      texto: listaTexto[widget.teste],
      textoBotao: 'COMEÇAR TREINO',
      onPressed: () async {
        await flutterTts.stop();
        await Future.delayed(const Duration(milliseconds: 50));
        if (mounted) Navigator.pop(context);
        if (mounted) {
          setState(() {
            mostrar = true;
          });
        }
        _resumeTest();
      },
    );
  }

  void _mostrarPopUpPreparese(Size size) {
    _pauseTest(manual: false);
    _reproduzir("Prepare-se, agora é pra valer!");

    popUpAlert(
      context: context,
      size: size,
      texto: "Prepare-se, agora é pra valer",
      textoBotao: 'COMEÇAR TESTE',
      onPressed: () async {
        await flutterTts.stop();
        await Future.delayed(const Duration(milliseconds: 50));

        if (mounted) Navigator.pop(context);
        if (mounted) {
          setState(() {
            i = 0;
            indices.clear();
            mostrar = true;
            boolTeste = false;
          });
        }
        _resumeTest();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWeb = size.width > 800;

    String tituloAppBar = boolTeste ? "TREINO" : "AVALIAÇÃO";
    if (widget.teste == 1) {
      tituloAppBar += " (Áudio)";
    } else {
      tituloAppBar += " (Visual)";
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, dynamic result) async {
        if (didPop) return;
        _pauseTest(manual: false);
        await _pararTesteCompleto();
        if (context.mounted) {
          Navigator.pushReplacementNamed(context, RotasApp.menu);
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.close, color: Color(0xFF292A2E), size: 28),
            onPressed: () async {
              _pauseTest(manual: false);
              await _pararTesteCompleto();
              if (context.mounted) {
                Navigator.pushReplacementNamed(context, RotasApp.menu);
              }
            },
          ),
          title: Text(
            tituloAppBar,
            style: GoogleFonts.outfit(
              color: const Color(0xFF292A2E),
              fontSize: 18,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: InkWell(
                onTap: () {
                  if (_isPaused) {
                    _resumeTest();
                  } else {
                    _pauseTest(manual: true);
                  }
                },
                borderRadius: BorderRadius.circular(30),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _isPaused ? corVerde : Colors.orangeAccent,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _isPaused ? Icons.play_arrow : Icons.pause,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ),
          ],
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                flex: 4,
                child: Center(
                  child: (widget.teste == 0 && mostrar)
                      ? Container(
                          width: isWeb ? 400 : size.width * 0.85,
                          height: isWeb ? 300 : size.height * 0.35,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              )
                            ],
                          ),
                          alignment: Alignment.center,
                          child: AutoSizeText(
                            (boolTeste
                                ? (i < sequenciaTeste.length
                                    ? sequenciaTeste[i].toString()
                                    : "")
                                : (i < sequenciaLista.length
                                    ? sequenciaLista[i].toString()
                                    : "")),
                            maxLines: 1,
                            style: GoogleFonts.outfit(
                              fontSize: 160,
                              fontWeight: FontWeight.bold,
                              color: _selecao(),
                            ),
                          ),
                        )
                      : (widget.teste == 1)
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.volume_up_rounded,
                                    size: 80, color: Colors.grey[400]),
                                const SizedBox(height: 10),
                                Text("Ouça com atenção...",
                                    style: GoogleFonts.outfit(
                                        color: Colors.grey, fontSize: 18))
                              ],
                            )
                          : const SizedBox(),
                ),
              ),
              Expanded(
                flex: 3,
                child: Container(
                  alignment: Alignment.topCenter,
                  padding: const EdgeInsets.only(top: 20),
                  child: SizedBox(
                    width: 250,
                    height: 200,
                    child: ElevatedButton(
                      onPressed: _isPaused
                          ? null
                          : () {
                              if (!boolTeste) {
                                indices.add(i);
                                debugPrint("Clique registrado no índice: $i");
                              }
                            },
                      style: ButtonStyle(
                        backgroundColor:
                            WidgetStateProperty.resolveWith<Color>((states) {
                          if (states.contains(WidgetState.pressed)) {
                            return Colors.grey.shade400;
                          }
                          return Colors.white;
                        }),
                        overlayColor: WidgetStateProperty.all(
                            Colors.grey.shade600.withValues(alpha: 0.3)),
                        elevation: WidgetStateProperty.resolveWith((states) {
                          return _isPaused ? 0.0 : 8.0;
                        }),
                        shadowColor: WidgetStateProperty.all(
                            Colors.black.withValues(alpha: 0.1)),
                        shape: WidgetStateProperty.all(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        padding:
                            WidgetStateProperty.all(const EdgeInsets.all(20)),
                      ),
                      child: Image.asset(
                        widget.teste == 0
                            ? 'assets/images/click.png'
                            : 'assets/images/Fala.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 20.0),
                child: Text(
                  boolTeste ? "Modo de Treinamento" : "Valendo!",
                  style: GoogleFonts.outfit(
                    color: Colors.grey[500],
                    fontSize: 14,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  final listaTexto = [
    "NÃO CLIQUE QUANDO APARECER O NÚMERO 6",
    "NÃO CLIQUE QUANDO OUVIR O NÚMERO 6",
  ];

  dynamic popUpAlert({
    required BuildContext context,
    required Size size,
    required String texto,
    required String textoBotao,
    required VoidCallback onPressed,
  }) {
    if (!context.mounted) return;

    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          contentPadding: const EdgeInsets.all(30),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: corAzul.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.info_outline, size: 40, color: corAzul),
              ),
              const SizedBox(height: 20),
              Text(
                texto,
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                    fontSize: 20,
                    color: const Color(0xFF292A2E),
                    fontWeight: FontWeight.w600,
                    height: 1.3),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: onPressed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: corAzul,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    textoBotao,
                    style: GoogleFonts.outfit(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              )
            ],
          ),
        );
      },
    );
  }

  dynamic _popUpFinal(String msg, BuildContext capturedContext, Size size) {
    if (!capturedContext.mounted) return;

    const valorSucesso = "Avaliação concluída com sucesso";
    bool sucesso = msg == valorSucesso;

    return showDialog(
      context: capturedContext,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: Colors.white,
        contentPadding: const EdgeInsets.all(30),
        content: Builder(
          builder: (builderContext) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _carregar
                    ? const SizedBox(
                        height: 100,
                        child: Center(
                            child: CircularProgressIndicator(
                                color: Color(0xFF2962C0))),
                      )
                    : Column(
                        children: [
                          Icon(
                            sucesso ? Icons.check_circle : Icons.error_outline,
                            color: sucesso ? corVerde : Colors.redAccent,
                            size: 60,
                          ),
                          const SizedBox(height: 20),
                          Text(
                            msg,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.outfit(
                              fontSize: 20,
                              color: const Color(0xFF292A2E),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 30),
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: () {
                                if (dialogContext.mounted) {
                                  Navigator.of(dialogContext).pop();
                                }
                                if (capturedContext.mounted) {
                                  Navigator.pushNamedAndRemoveUntil(
                                      capturedContext,
                                      RotasApp.menu,
                                      (route) => false,
                                      arguments: 1);
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    sucesso ? corVerde : Colors.grey,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                sucesso ? 'FINALIZAR' : 'FECHAR',
                                style: GoogleFonts.outfit(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
              ],
            );
          },
        ),
      ),
    );
  }
}
