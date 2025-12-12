import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gonogo/controller/controller_evaluator.dart';
import 'package:gonogo/models/utils/rotas-app.dart';
import 'package:gonogo/models/utils/validator.dart';

class TelaLogin extends StatefulWidget {
  const TelaLogin({super.key});

  @override
  State<TelaLogin> createState() => _TelaLoginState();
}

class _TelaLoginState extends State<TelaLogin> {
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _authData = {'email': '', 'senha': ''};

  bool _carregar = false;
  bool _senhaVisivel = false;

  Future _fazerLogin() async {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;

    _formKey.currentState?.save();
    final currentContext = context;

    setState(() {
      _carregar = true;
    });

    try {
      _popUp("");
      await ControllerEvaluator().login(_authData);

      if (currentContext.mounted) {
        Navigator.pop(currentContext);
        Navigator.pushReplacementNamed(currentContext, RotasApp.principal);
      }
    } catch (error) {
      if (currentContext.mounted) {
        Navigator.pop(currentContext);
        _popUp(error.toString());
      }
    } finally {
      if (mounted) {
        setState(() {
          _carregar = false;
        });
      }
    }
  }

  void _popUp(String msg) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        if (msg == "") {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF4285F4)),
          );
        } else {
          return AlertDialog(
            title: const Text('Ops! Ocorreu um erro'),
            content: Text(msg),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('FECHAR',
                    style: TextStyle(color: Color(0xFF4285F4))),
              ),
            ],
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWeb = size.width > 800;
    final double verticalPadding = isWeb ? 40 : 24;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Center(
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: Container(
            width: isWeb ? 558 : size.width * 0.9,
            constraints: BoxConstraints(
              minHeight: isWeb ? 580 : size.height * 0.7,
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
              horizontal: isWeb ? 103 : 24,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 132,
                    height: 40,
                    child: Image.asset(
                      'assets/images/gonogo_logo.png',
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return const Center(
                            child:
                                Icon(Icons.broken_image, color: Colors.grey));
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Olá, Bem-Vindo',
                    style: GoogleFonts.outfit(
                      fontSize: 32,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF292A2E),
                      height: 1.0,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'ao gonogo sistema de teste neuropsicologico',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF292A2E),
                      height: 1.0,
                    ),
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      hintText: 'Email',
                      hintStyle: GoogleFonts.roboto(color: Colors.grey),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFFB6B6BB)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFFB6B6BB)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                            color: Color(0xFF4285F4), width: 2),
                      ),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: Validator.validarEmail,
                    onSaved: (value) => _authData['email'] = value ?? '',
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _senhaController,
                    decoration: InputDecoration(
                      hintText: 'Senha',
                      hintStyle: GoogleFonts.roboto(color: Colors.grey),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 0),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _senhaVisivel
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: Colors.grey,
                        ),
                        onPressed: () {
                          setState(() {
                            _senhaVisivel = !_senhaVisivel;
                          });
                        },
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFFB6B6BB)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFFB6B6BB)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                            color: Color(0xFF4285F4), width: 2),
                      ),
                    ),
                    obscureText: !_senhaVisivel,
                    validator: Validator.validarSenha,
                    onSaved: (value) => _authData['senha'] = value ?? '',
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, RotasApp.recuperarSenha);
                      },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(0, 0),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        'Esqueceu a senha ?',
                        style: GoogleFonts.roboto(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF4285F4),
                          letterSpacing: 0.02,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 45,
                    child: ElevatedButton(
                      onPressed: _carregar ? null : _fazerLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4285F4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                      child: _carregar
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2))
                          : Text(
                              'Entrar',
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
                  Row(
                    children: [
                      const Expanded(child: Divider(color: Color(0xFFB6B6BB))),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text(
                          'ou',
                          style: GoogleFonts.roboto(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFFB6B6BB),
                          ),
                        ),
                      ),
                      const Expanded(child: Divider(color: Color(0xFFB6B6BB))),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Não tem conta? ',
                        style: GoogleFonts.roboto(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF5A5A5F),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, RotasApp.cadastro);
                        },
                        child: Text(
                          'Criar conta',
                          style: GoogleFonts.roboto(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF4285F4),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
