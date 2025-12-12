import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gonogo/controller/controller_evaluator.dart';
import 'package:gonogo/models/utils/rotas-app.dart';

class TelaCadastroEtapa3 extends StatefulWidget {
  final Map<String, dynamic> dadosCompletos;

  const TelaCadastroEtapa3({super.key, required this.dadosCompletos});

  @override
  State<TelaCadastroEtapa3> createState() => _TelaCadastroEtapa3State();
}

class _TelaCadastroEtapa3State extends State<TelaCadastroEtapa3> {
  bool _isLoading = true;
  String _statusMessage = "Criando sua conta...";
  User? _currentUser;
  Timer? _timerVerificacao;

  @override
  void initState() {
    super.initState();
    _criarContaEEnviarEmail();
  }

  @override
  void dispose() {
    _timerVerificacao?.cancel();
    super.dispose();
  }

  Future<void> _criarContaEEnviarEmail() async {
    try {
      await ControllerEvaluator().register(widget.dadosCompletos);

      _currentUser = FirebaseAuth.instance.currentUser;

      if (_currentUser != null && !_currentUser!.emailVerified) {
        await _currentUser!.sendEmailVerification();

        if (mounted) {
          setState(() {
            _isLoading = false;
            _statusMessage = "";
          });
        }

        _timerVerificacao = Timer.periodic(
            const Duration(seconds: 3), (_) => _checarVerificacao());
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _statusMessage = "Erro: ${e.message}";
        });
        _mostrarErro(e.message ?? "Erro desconhecido");
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _statusMessage = "Erro ao criar conta.";
        });
      }
    }
  }

  Future<void> _checarVerificacao() async {
    _currentUser = FirebaseAuth.instance.currentUser;
    await _currentUser?.reload();

    if (_currentUser != null && _currentUser!.emailVerified) {
      _timerVerificacao?.cancel();
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(
          context, RotasApp.menu, (route) => false);
    }
  }

  void _mostrarErro(String msg) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Atenção'),
        content: Text(msg),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: const Text('Voltar e Corrigir'),
          )
        ],
      ),
    );
  }

  Future<void> _reenviarEmail() async {
    if (_currentUser != null) {
      await _currentUser!.sendEmailVerification();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text(
                  'E-mail reenviado! Verifique sua caixa de entrada (e spam).')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWeb = size.width > 800;
    final double verticalPadding = isWeb ? 40 : 24;
    final emailUsuario = widget.dadosCompletos['email'] ?? 'seuemail@gmail.com';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Center(
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: Container(
            width: isWeb ? 558 : size.width * 0.9,
            constraints: BoxConstraints(
              minHeight: isWeb ? 500 : size.height * 0.6,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: isWeb
                  ? [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      )
                    ]
                  : null,
            ),
            padding: EdgeInsets.symmetric(
              vertical: verticalPadding,
              horizontal: isWeb ? 60 : 24,
            ),
            child: _isLoading
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CircularProgressIndicator(color: Color(0xFF2962C0)),
                      const SizedBox(height: 20),
                      Text(_statusMessage,
                          style: GoogleFonts.outfit(fontSize: 18)),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: Column(
                          children: [
                            Text(
                              'Cadastro',
                              style: GoogleFonts.outfit(
                                fontSize: 24,
                                fontWeight: FontWeight.w400,
                                color: const Color(0xFF292A2E),
                                height: 1.0,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Verificação',
                              style: GoogleFonts.outfit(
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                color: const Color(0xFF6C6A6A),
                                height: 1.0,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildProgressIndicator(active: true),
                          const SizedBox(width: 8),
                          _buildProgressIndicator(active: true),
                          const SizedBox(width: 8),
                          _buildProgressIndicator(active: true),
                        ],
                      ),
                      const SizedBox(height: 40),
                      Text(
                        'Verifique seu e-mail',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.outfit(
                          fontSize: 24,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF2962C0),
                          height: 1.0,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Por favor clique no link de verificação que foi enviado para seu e-mail:\n$emailUsuario',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.outfit(
                          fontSize: 20,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFF292A2E),
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 40),
                      const Icon(
                        Icons.mark_email_unread_outlined,
                        size: 80,
                        color: Color(0xFF2962C0),
                      ),
                      const SizedBox(height: 40),
                      SizedBox(
                        width: double.infinity,
                        height: 45,
                        child: ElevatedButton(
                          onPressed: () async {
                            await _checarVerificacao();

                            if (!mounted) return;

                            if (_currentUser != null &&
                                !_currentUser!.emailVerified) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text(
                                        'Ainda não verificado. Clique no link do e-mail.')),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2962C0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            'Já verifiquei',
                            style: GoogleFonts.outfit(
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                              letterSpacing: 0.02,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: _reenviarEmail,
                        child: Text(
                          'Não recebeu o código? Reenviar e-mail',
                          style: GoogleFonts.roboto(
                            color: const Color(0xFF6C6A6A),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildProgressIndicator({required bool active}) {
    return Container(
      width: 43,
      height: 6,
      decoration: BoxDecoration(
        color: active ? const Color(0xFF2962C0) : const Color(0xFFC7D3EB),
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}
